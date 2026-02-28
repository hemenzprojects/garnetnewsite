#!/bin/bash

###############################################################################
# GARNET Environment Configuration Script
# This script helps you set up environment variables for production
#
# Usage: bash 2-configure-env.sh
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DEPLOY_DIR="/var/www/garnet"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    GARNET Environment Configuration${NC}"
echo -e "${BLUE}================================================${NC}"

# Check if we're in the right directory
if [ ! -f "$DEPLOY_DIR/docker-compose.prod.yml" ]; then
    echo -e "${RED}Error: docker-compose.prod.yml not found!${NC}"
    echo -e "Please ensure application code is in ${BLUE}$DEPLOY_DIR${NC}"
    exit 1
fi

cd "$DEPLOY_DIR"

echo -e "\n${GREEN}[1/3] Setting up Docker environment...${NC}"
if [ ! -f ".env.production" ]; then
    # Generate random passwords (alphanumeric only to avoid sed issues)
    DB_ROOT_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
    DB_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
    REDIS_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)

    # Create .env.production directly
    cat > .env.production << EOF
# Production Environment Variables for Docker Compose
DB_ROOT_PASSWORD=${DB_ROOT_PASS}
DB_DATABASE=garnet_db
DB_USERNAME=garnet_user
DB_PASSWORD=${DB_PASS}
REDIS_PASSWORD=${REDIS_PASS}
WWWGROUP=1000
WWWUSER=1000
EOF

    echo -e "${GREEN}✓ Created .env.production with secure passwords${NC}"
else
    echo -e "${YELLOW}.env.production already exists, skipping...${NC}"
    # Get existing passwords
    DB_PASS=$(grep "^DB_PASSWORD=" .env.production | cut -d '=' -f2)
    REDIS_PASS=$(grep "^REDIS_PASSWORD=" .env.production | cut -d '=' -f2)
fi

echo -e "\n${GREEN}[2/3] Setting up Laravel environment...${NC}"
if [ ! -f "backend/.env" ]; then
    # Get passwords from .env.production
    DB_PASS=$(grep "^DB_PASSWORD=" .env.production | cut -d '=' -f2)
    REDIS_PASS=$(grep "^REDIS_PASSWORD=" .env.production | cut -d '=' -f2)

    # Create backend/.env with passwords already filled in
    cat > backend/.env << EOF
APP_NAME=GARNET
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_TIMEZONE=Africa/Accra
APP_URL=https://www2.garnet.edu.gh

APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

APP_MAINTENANCE_DRIVER=file

BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

# Database - Container names
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=garnet_db
DB_USERNAME=garnet_user
DB_PASSWORD=${DB_PASS}

# Session & Cache
SESSION_DRIVER=redis
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=.garnet.edu.gh

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=public
QUEUE_CONNECTION=redis

CACHE_STORE=redis
CACHE_PREFIX=

# Redis - Container name
REDIS_CLIENT=phpredis
REDIS_HOST=redis
REDIS_PASSWORD=${REDIS_PASS}
REDIS_PORT=6379

# Mail Configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@garnet.edu.gh"
MAIL_FROM_NAME="\${APP_NAME}"

# Vite
VITE_APP_NAME="\${APP_NAME}"
EOF

    echo -e "${GREEN}✓ Created backend/.env with matching passwords${NC}"
else
    echo -e "${YELLOW}backend/.env already exists, skipping...${NC}"
fi

echo -e "\n${GREEN}[3/3] Setting up Frontend environment...${NC}"
if [ ! -f "frontend/.env" ]; then
    # Create frontend/.env directly
    cat > frontend/.env << EOF
NUXT_PUBLIC_API_BASE=https://www2.garnet.edu.gh/api/v1
NODE_ENV=production
EOF
    echo -e "${GREEN}✓ Created frontend/.env${NC}"
else
    echo -e "${YELLOW}frontend/.env already exists, skipping...${NC}"
fi

echo -e "\n${BLUE}================================================${NC}"
echo -e "${GREEN}Environment configuration complete!${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "\n${YELLOW}Created files:${NC}"
echo -e "  - .env.production (Docker Compose environment)"
echo -e "  - backend/.env (Laravel environment)"
echo -e "  - frontend/.env (Nuxt environment)"

echo -e "\n${YELLOW}IMPORTANT:${NC}"
echo -e "Your database and Redis passwords have been auto-generated."
echo -e "You can view them in: ${BLUE}.env.production${NC}"

echo -e "\n${YELLOW}If you need to configure mail settings:${NC}"
echo -e "Edit ${BLUE}backend/.env${NC} and update the MAIL_* variables"

echo -e "\n${GREEN}Next step:${NC}"
echo -e "Run: ${YELLOW}bash 3-setup-ssl.sh${NC}"