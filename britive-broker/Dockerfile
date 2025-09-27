# Use OpenJDK 21 as base image
FROM openjdk:21-jre-slim

# Set working directory
WORKDIR /app

# Install necessary utilities for the startup script
RUN apt-get update && apt-get install -y \
    envsubst \
    && rm -rf /var/lib/apt/lists/*

# Create directories for logs and cache
RUN mkdir -p /app/logs /app/cache

# Copy the JAR file
COPY britive-broker-1.0.0.jar /app/

# Copy configuration files
COPY config/ /app/config/

# Copy startup script
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# Set environment variables with default values
ENV TENANT_SUBDOMAIN=""
ENV AUTHENTICATION_TOKEN=""
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Expose port (if the broker uses any specific port, adjust as needed)
# EXPOSE 8080

# Create volumes for persistent data
VOLUME ["/app/logs", "/app/cache"]

# Run the startup script
ENTRYPOINT ["/app/docker-entrypoint.sh"]