# Use Amazon Corretto 21 (optimized for AWS)
FROM amazoncorretto:21

# Set working directory
WORKDIR /app

# Install necessary utilities for the startup script, logging, and broker functionality
# Using yum since Corretto is based on Amazon Linux
RUN yum update -y && yum install -y \
    gettext \
    curl \
    unzip \
    shadow-utils \
    hostname \
    procps \
    util-linux \
    openssh-clients \
    mysql \
    postgresql \
    python3 \
    && yum clean all

# Install jq manually since it's not available in Amazon Linux 2 repos
RUN curl -L -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod +x /usr/local/bin/jq

# Note: PuTTY tools (puttygen, pscp, plink) are not available in Amazon Linux repos
# Use SSH tools instead: ssh-keygen, ssh, scp are installed via openssh-clients

# Create directories for logs, cache, and bootstrap scripts
RUN mkdir -p /app/logs /app/cache /app/bootstrap

# Copy the JAR file
COPY britive-broker-1.0.0.jar /app/

# Copy configuration files
COPY config/ /app/config/

# Copy startup script and key converter
COPY docker-entrypoint.sh /app/
COPY convert-to-putty.py /usr/local/bin/convert-to-putty.py
RUN chmod +x /app/docker-entrypoint.sh /usr/local/bin/convert-to-putty.py \
    && ln -sf /usr/local/bin/convert-to-putty.py /usr/local/bin/convert-to-putty

# Set environment variables with default values
ENV TENANT_SUBDOMAIN=""
ENV AUTHENTICATION_TOKEN=""
ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV LOG_TO_STDOUT="true"

# Expose port (if the broker uses any specific port, adjust as needed)
# EXPOSE 8080

# Create volumes for persistent data
VOLUME ["/app/logs", "/app/cache"]

# Create symlink for /var/log/britive-broker.log to make it accessible
RUN mkdir -p /var/log && \
    ln -sf /app/logs/britive-broker.log /var/log/britive-broker.log

# Run the startup script
ENTRYPOINT ["/app/docker-entrypoint.sh"]