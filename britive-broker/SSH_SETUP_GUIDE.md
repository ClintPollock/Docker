# Generic SSH Keys Setup Guide

## Overview
This guide shows how to configure the Britive Broker container to work with any SSH keys, making it easy for teams to deploy.

## Current Generic Configuration

### Docker Compose Mount Point:
```yaml
volumes:
  - ${SSH_KEYS_HOST_PATH:-./ssh-keys}:/app/ssh-keys:ro
```

### Environment Variables:
```bash
# In .env file:
SSH_KEYS_HOST_PATH=./ssh-keys          # Path to your keys directory
DEFAULT_SSH_KEY=your-key.pem           # Default key filename
```

## User Setup Instructions

### 1. Quick Setup (Recommended)
```bash
# Clone the project
git clone <repo>
cd britive-broker

# Create SSH keys directory and add your keys
mkdir -p ssh-keys
cp /path/to/your/production.pem ./ssh-keys/
chmod 600 ./ssh-keys/*.pem

# Configure environment
cp .env.template .env
# Edit .env:
#   DEFAULT_SSH_KEY=production.pem
#   SSH_KEYS_HOST_PATH=./ssh-keys

# Start the broker
docker-compose up -d
```

### 2. Custom Location Setup
```bash
# If you have keys elsewhere:
# Edit .env:
SSH_KEYS_HOST_PATH=/home/user/aws-keys
DEFAULT_SSH_KEY=my-server.pem

# Keys should be at /home/user/aws-keys/my-server.pem
docker-compose up -d
```

### 3. Multiple Keys Setup
```bash
# Directory structure:
ssh-keys/
├── development.pem
├── staging.pem  
├── production.pem
└── backup-server.pem

# The broker will:
# 1. Use DEFAULT_SSH_KEY if set
# 2. Auto-discover first .pem file if DEFAULT_SSH_KEY not set
# 3. List all available keys on startup
```

## Team Usage Examples

### Development Team:
```bash
# Each developer:
mkdir -p ssh-keys
cp ~/.ssh/dev-server.pem ./ssh-keys/
echo "DEFAULT_SSH_KEY=dev-server.pem" >> .env
docker-compose up -d
```

### DevOps Team:
```bash
# Centralized keys location:
SSH_KEYS_HOST_PATH=/opt/company-keys
DEFAULT_SSH_KEY=production.pem
# Keys at: /opt/company-keys/production.pem
```

### Multi-Environment:
```bash
# Different configs per environment:
# .env.dev
SSH_KEYS_HOST_PATH=./keys/dev
DEFAULT_SSH_KEY=dev.pem

# .env.prod  
SSH_KEYS_HOST_PATH=/secure/prod-keys
DEFAULT_SSH_KEY=prod.pem

# Usage:
docker-compose --env-file .env.dev up -d
docker-compose --env-file .env.prod up -d
```

## Verification Commands

### Check mounted keys:
```bash
docker-compose exec britive-broker ls -la /app/ssh-keys/
```

### Test key permissions:
```bash
docker-compose exec britive-broker stat /app/ssh-keys/your-key.pem
```

### Test SSH connectivity:
```bash
docker-compose exec britive-broker ssh -i /app/ssh-keys/your-key.pem user@server -o ConnectTimeout=5
```

## Container Auto-Discovery

The startup script automatically:
1. **Discovers keys**: Scans `/app/ssh-keys/` for `.pem` files
2. **Sets permissions**: Ensures all keys have `600` permissions  
3. **Lists available keys**: Shows what keys are mounted
4. **Validates paths**: Warns if no keys found

### Startup Log Example:
```
[2025-09-28 10:50:20] Setting up SSH keys from /app/ssh-keys
[2025-09-28 10:50:20] Available SSH keys:
[2025-09-28 10:50:20]   -rw------- 1 root root 1675 Sep 28 10:50 /app/ssh-keys/production.pem
[2025-09-28 10:50:20]   -rw------- 1 root root 1823 Sep 28 10:50 /app/ssh-keys/staging.pem
[2025-09-28 10:50:20] SSH key permissions set to 600
```

## Security Notes

- Keys are mounted **read-only** by default
- Permissions automatically fixed to `600` on container startup
- No keys stored in Docker image - only mounted at runtime
- Each user/team manages their own keys independently

This makes the container completely generic - anyone can use it by just mounting their SSH keys directory!