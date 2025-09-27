#!/bin/bash

# docker-entrypoint.sh - Startup script for Britive Broker container

set -e

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to tail logs to stdout
tail_logs() {
    local log_file="$1"
    if [ "$LOG_TO_STDOUT" = "true" ]; then
        log "Starting log tail for $log_file to stdout"
        tail -F "$log_file" 2>/dev/null &
        TAIL_PID=$!
        log "Log tail started with PID: $TAIL_PID"
    fi
}

# Function to cleanup on exit
cleanup() {
    log "Shutting down Britive Broker..."
    if [ ! -z "$TAIL_PID" ]; then
        kill $TAIL_PID 2>/dev/null || true
    fi
    if [ ! -z "$JAVA_PID" ]; then
        kill $JAVA_PID 2>/dev/null || true
        wait $JAVA_PID 2>/dev/null || true
    fi
    log "Shutdown complete"
}

# Set up signal handling
trap cleanup SIGTERM SIGINT

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
mkdir -p /app/cache /app/logs /app/logs/archive
chmod 755 /app/cache /app/logs /app/logs/archive

# Create symlinks for log visibility
ln -sf /app/logs/britive-broker.log /var/log/britive-broker.log 2>/dev/null || true

# Initialize log file if it doesn't exist
touch /app/logs/britive-broker.log

log "Log directory structure created"

log "Starting Britive Broker service..."

# Start log tailing if enabled
tail_logs "/app/logs/britive-broker.log"

# Start the Java application in the background
java $JAVA_OPTS -jar /app/britive-broker-1.0.0.jar &
JAVA_PID=$!

log "Britive Broker started with PID: $JAVA_PID"

# Wait for the Java process to complete
wait $JAVA_PID