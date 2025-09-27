# Britive Broker Docker Container

This repository contains the Docker configuration for containerizing the Britive Broker application.

## Prerequisites

- Docker and Docker Compose installed on your system
- Britive tenant subdomain and authentication token

## Quick Start

### Using Docker Compose (Recommended)

1. **Create an environment file** (`.env`) in the same directory as `docker-compose.yml`:

```env
TENANT_SUBDOMAIN=your-tenant-subdomain
AUTHENTICATION_TOKEN=your-authentication-token
```

2. **Build and run the container**:

```bash
docker-compose up -d
```

### Using Docker Commands

1. **Build the image**:

```bash
docker build -t britive-broker:latest .
```

2. **Run the container**:

```bash
docker run -d \
  --name britive-broker \
  -e TENANT_SUBDOMAIN=your-tenant-subdomain \
  -e AUTHENTICATION_TOKEN=your-authentication-token \
  -v britive-logs:/app/logs \
  -v britive-cache:/app/cache \
  britive-broker:latest
```

## Configuration

### Required Environment Variables

- `TENANT_SUBDOMAIN`: Your Britive tenant subdomain
- `AUTHENTICATION_TOKEN`: Your Britive authentication token

### Optional Environment Variables

- `JAVA_OPTS`: JVM options (default: `-Xmx512m -Xms256m`)

## Volumes

The container creates two volumes for persistent data:

- `/app/logs`: Application logs
- `/app/cache`: Application cache data

## Monitoring

### View logs

```bash
# Using docker-compose
docker-compose logs -f

# Using docker
docker logs -f britive-broker
```

### Check container status

```bash
# Using docker-compose
docker-compose ps

# Using docker
docker ps | grep britive-broker
```

## Stopping the Container

```bash
# Using docker-compose
docker-compose down

# Using docker
docker stop britive-broker
docker rm britive-broker
```

## Troubleshooting

### Common Issues

1. **Container exits immediately**: Check that both `TENANT_SUBDOMAIN` and `AUTHENTICATION_TOKEN` are set correctly.

2. **Permission issues**: Ensure the Docker daemon has proper permissions to create volumes and run containers.

3. **Java out of memory errors**: Increase memory allocation using the `JAVA_OPTS` environment variable:
   ```bash
   JAVA_OPTS="-Xmx1024m -Xms512m"
   ```

### Debug Mode

To run the container interactively for debugging:

```bash
docker run -it --rm \
  -e TENANT_SUBDOMAIN=your-tenant-subdomain \
  -e AUTHENTICATION_TOKEN=your-authentication-token \
  britive-broker:latest /bin/bash
```

## Security Considerations

- Never commit your `.env` file with real credentials to version control
- Use Docker secrets or secure environment variable management in production
- Regularly update the base Java image for security patches
- Consider running the container with a non-root user in production

## Building for Production

For production deployments, consider:

1. Using multi-stage builds to reduce image size
2. Implementing health checks
3. Setting up proper logging and monitoring
4. Using orchestration platforms like Kubernetes or Docker Swarm

## File Structure

```
britive-broker/
├── Dockerfile                    # Main Docker configuration
├── docker-compose.yml           # Docker Compose configuration
├── docker-entrypoint.sh         # Container startup script
├── .dockerignore                # Files to exclude from build context
├── britive-broker-1.0.0.jar    # Application JAR file
├── config/                      # Configuration directory
│   ├── broker-config.yml        # Runtime configuration
│   ├── broker-config-template.yml
│   └── logback.xml
└── README.md                    # This file
```