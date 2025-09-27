# Britive Broker Docker Container

A containerized version of the Britive Broker service for easy deployment and scaling.

## Prerequisites

- Docker and Docker Compose
- Britive tenant subdomain and authentication token

## Quick Start

### 1. Create Environment File

Create a `.env` file with your Britive credentials:

```env
TENANT_SUBDOMAIN=your-tenant-subdomain
AUTHENTICATION_TOKEN=your-authentication-token
```

### 2. Build and Run

```bash
# Build the image
docker build -t britive-broker:latest .

# Run single instance
docker-compose up -d

# Or run multiple instances (recommended for high availability)
docker-compose up -d --scale britive-broker=2
```

### 3. Monitor

```bash
# View all logs
docker-compose logs -f

# Check status
docker-compose ps

# View individual container logs
docker logs -f britive-broker
```

## Configuration

### Required Environment Variables

- `TENANT_SUBDOMAIN`: Your Britive tenant subdomain (e.g., "company-name")
- `AUTHENTICATION_TOKEN`: Your Britive authentication token

### Optional Environment Variables

- `JAVA_OPTS`: JVM options (default: `-Xmx512m -Xms256m`)

## Scaling

Run multiple broker instances for high availability:

```bash
# Scale to 3 instances
docker-compose up -d --scale britive-broker=3

# Scale back to 1 instance
docker-compose up -d --scale britive-broker=1
```

## Logs

Logs are available in multiple ways:

- **Docker logs**: `docker-compose logs -f`
- **Log files**: Mounted to `./logs/` directory on host
- **Individual containers**: `docker logs -f <container-name>`

Log files are automatically rotated:
- Maximum size: 100MB per file
- Retention: 5 files
- Archive location: `./logs/archive/`

## Management

### Start/Stop Services

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart
```

### View Container Status

```bash
# All containers
docker-compose ps

# Specific service
docker ps --filter "name=britive-broker"
```

### Update and Rebuild

```bash
# Rebuild image
docker-compose build

# Recreate containers with new image
docker-compose up -d --force-recreate
```

## File Structure

```
britive-broker/
├── Dockerfile                    # Container definition
├── docker-compose.yml           # Service orchestration
├── docker-compose.local.yml     # Alternative local setup
├── docker-entrypoint.sh         # Container startup script
├── .dockerignore                # Build exclusions
├── britive-broker-1.0.0.jar    # Application JAR file
├── config/                      # Configuration files
│   ├── broker-config.yml        # Runtime configuration
│   ├── broker-config-template.yml
│   └── logback.xml             # Logging configuration
├── logs/                        # Log files (created at runtime)
└── README.md                   # This file
```

## Troubleshooting

### Common Issues

1. **Container exits immediately**
   - Check that both `TENANT_SUBDOMAIN` and `AUTHENTICATION_TOKEN` are set
   - Verify credentials are correct

2. **Network connectivity issues**
   - Ensure the container can reach the internet
   - Check DNS resolution: `docker exec britive-broker nslookup google.com`

3. **Out of memory errors**
   - Increase memory allocation: `JAVA_OPTS="-Xmx1024m -Xms512m"`

### Debug Commands

```bash
# Interactive shell access
docker exec -it britive-broker /bin/bash

# View detailed logs
docker-compose logs --tail=100 -f

# Check network connectivity
docker exec britive-broker ping -c 3 google.com

# Test DNS resolution
docker exec britive-broker nslookup your-tenant.britive-app.com
```

## Production Deployment

For production environments:

1. Use specific version tags instead of `latest`
2. Set appropriate resource limits
3. Configure log rotation and monitoring
4. Use Docker Swarm or Kubernetes for orchestration
5. Implement health checks and auto-restart policies

## Support

- Application logs: `./logs/britive-broker.log`
- Container logs: `docker-compose logs`
- Britive documentation: https://docs.britive.com