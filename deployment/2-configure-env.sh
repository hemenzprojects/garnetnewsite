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
    cp .env.production.example .env.production
    echo -e "${YELLOW}Created .env.production from template${NC}"
    echo -e "${YELLOW}Please edit this file with secure passwords!${NC}"

    # Generate random passwords
    DB_ROOT_PASS=$(openssl rand -base64 32)
    DB_PASS=$(openssl rand -base64 32)
    REDIS_PASS=$(openssl rand -base64 32)

    sed -i "s/CHANGE_ME_STRONG_ROOT_PASSWORD/$DB_ROOT_PASS/" .env.production
    sed -i "s/CHANGE_ME_STRONG_DB_PASSWORD/$DB_PASS/" .env.production
    sed -i "s/CHANGE_ME_REDIS_PASSWORD/$REDIS_PASS/" .env.production

    echo -e "${GREEN}✓ Generated secure random passwords${NC}"
else
    echo -e "${YELLOW}.env.production already exists, skipping...${NC}"
fi

echo -e "\n${GREEN}[2/3] Setting up Laravel environment...${NC}"
if [ ! -f "backend/.env" ]; then
    cp backend/.env.production.example backend/.env
    echo -e "${YELLOW}Created backend/.env from template${NC}"

    # Get passwords from .env.production
    DB_PASS=$(grep "^DB_PASSWORD=" .env.production | cut -d '=' -f2)
    REDIS_PASS=$(grep "^REDIS_PASSWORD=" .env.production | cut -d '=' -f2)

    # Update backend/.env with matching passwords
    sed -i "s/CHANGE_ME_STRONG_DB_PASSWORD/$DB_PASS/" backend/.env
    sed -i "s/CHANGE_ME_REDIS_PASSWORD/$REDIS_PASS/" backend/.env

    echo -e "${GREEN}✓ Configured with matching passwords${NC}"
else
    echo -e "${YELLOW}backend/.env already exists, skipping...${NC}"
fi

echo -e "\n${GREEN}[3/3] Setting up Frontend environment...${NC}"
if [ ! -f "frontend/.env" ]; then
    cp frontend/.env.production.example frontend/.env
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