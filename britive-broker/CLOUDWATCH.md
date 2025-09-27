# CloudWatch Configuration for Britive Broker

This document provides instructions for setting up CloudWatch logging for the Britive Broker Docker container.

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. IAM permissions for CloudWatch Logs
3. Docker with awslogs logging driver support

## Required IAM Permissions

Your AWS credentials need the following CloudWatch Logs permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
```

## Environment Variables for CloudWatch

Create a `.env` file with the following variables:

```env
# Required Britive configuration
TENANT_SUBDOMAIN=your-tenant-subdomain
AUTHENTICATION_TOKEN=your-authentication-token

# AWS CloudWatch configuration
AWS_REGION=us-east-1
CLOUDWATCH_LOG_GROUP=/aws/docker/britive-broker
CLOUDWATCH_LOG_STREAM=britive-broker-production

# Optional: Enable stdout logging (default: true)
LOG_TO_STDOUT=true
```

## Running with CloudWatch Logging

### Method 1: Using Docker Compose (Recommended)

```bash
# Make sure AWS credentials are available
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=us-east-1

# Run with CloudWatch logging
docker-compose up -d
```

### Method 2: Using Docker CLI

```bash
docker run -d \
  --name britive-broker \
  --log-driver=awslogs \
  --log-opt awslogs-region=us-east-1 \
  --log-opt awslogs-group=/aws/docker/britive-broker \
  --log-opt awslogs-stream=britive-broker-$(hostname) \
  --log-opt awslogs-create-group=true \
  -e TENANT_SUBDOMAIN=your-tenant-subdomain \
  -e AUTHENTICATION_TOKEN=your-authentication-token \
  -e AWS_REGION=us-east-1 \
  -e LOG_TO_STDOUT=true \
  britive-broker:latest
```

### Method 3: Local Development (No CloudWatch)

For local development without CloudWatch:

```bash
docker-compose -f docker-compose.local.yml up -d
```

## Viewing Logs

### CloudWatch Console
1. Open AWS CloudWatch Console
2. Navigate to "Logs" > "Log groups"
3. Find your log group (e.g., `/aws/docker/britive-broker`)
4. Click on the log stream to view logs

### AWS CLI
```bash
# List log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/docker/britive-broker"

# View recent log events
aws logs tail /aws/docker/britive-broker --follow

# View specific log stream
aws logs get-log-events --log-group-name /aws/docker/britive-broker --log-stream-name britive-broker-production
```

### Docker Commands
```bash
# View container logs (will show stdout output)
docker logs -f britive-broker

# Access log files directly
docker exec britive-broker tail -f /app/logs/britive-broker.log
docker exec britive-broker tail -f /var/log/britive-broker.log
```

## Log Rotation and Retention

### CloudWatch Log Retention
Set retention policy for your log group:

```bash
aws logs put-retention-policy \
  --log-group-name /aws/docker/britive-broker \
  --retention-in-days 30
```

### Local Log Rotation
The application uses built-in log rotation:
- Maximum file size: 100MB
- Maximum history: 7 days
- Total size cap: 1GB
- Archived logs: `/app/logs/archive/`

## Troubleshooting

### Common Issues

1. **AWS credentials not found**:
   ```bash
   # Check AWS credentials
   aws sts get-caller-identity
   
   # Set credentials as environment variables
   export AWS_ACCESS_KEY_ID=your-key
   export AWS_SECRET_ACCESS_KEY=your-secret
   ```

2. **Permission denied for CloudWatch**:
   - Verify IAM permissions listed above
   - Check if the AWS region is correct

3. **Log group creation failed**:
   - Manually create the log group:
   ```bash
   aws logs create-log-group --log-group-name /aws/docker/britive-broker
   ```

4. **Logs not appearing in CloudWatch**:
   - Check Docker daemon CloudWatch logging driver support
   - Verify container is running: `docker ps`
   - Check container logs: `docker logs britive-broker`

### Debug Mode

Run container interactively to debug logging:

```bash
docker run -it --rm \
  -e TENANT_SUBDOMAIN=your-tenant-subdomain \
  -e AUTHENTICATION_TOKEN=your-authentication-token \
  -e LOG_TO_STDOUT=true \
  britive-broker:latest /bin/bash
```

## Cost Optimization

To minimize CloudWatch costs:

1. Set appropriate log retention periods
2. Use log filters to reduce noise
3. Consider using log sampling for high-volume applications
4. Monitor your CloudWatch Logs usage in AWS Billing

## Integration with Other Tools

### ECS/Fargate
When running on ECS/Fargate, the awslogs driver is automatically configured. Just set the environment variables.

### Kubernetes
For Kubernetes deployments, use Fluent Bit or similar log shipping solutions instead of the Docker awslogs driver.

### Log Analysis
Consider using:
- CloudWatch Insights for log analysis
- AWS Elasticsearch Service for advanced searching
- Third-party tools like Datadog or Splunk for comprehensive monitoring