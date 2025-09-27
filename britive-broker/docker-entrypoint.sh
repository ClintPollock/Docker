#!/bin/bash

# docker-entrypoint.sh - Startup script for Britive Broker container

set -e

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting Britive Broker container..."

# Check if required environment variables are set
if [ -z "$TENANT_SUBDOMAIN" ]; then
    log "ERROR: TENANT_SUBDOMAIN environment variable is required"
    exit 1
fi

if [ -z "$AUTHENTICATION_TOKEN" ]; then
    log "ERROR: AUTHENTICATION_TOKEN environment variable is required"
    exit 1
fi

# Create the runtime configuration file from the template
log "Configuring broker with tenant subdomain: $TENANT_SUBDOMAIN"

# Use envsubst to replace environment variables in the config file
cat > /app/config/broker-config.yml << EOF
config:
  bootstrap:
    tenant_subdomain: $TENANT_SUBDOMAIN
    authentication_token: $AUTHENTICATION_TOKEN
EOF

log "Configuration file created successfully"

# Ensure cache and logs directories exist and have proper permissions
mkdir -p /app/cache /app/logs
chmod 755 /app/cache /app/logs

log "Starting Britive Broker service..."

# Start the Java application
exec java $JAVA_OPTS -jar /app/britive-broker-1.0.0.jar