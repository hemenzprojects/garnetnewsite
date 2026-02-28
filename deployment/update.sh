#!/bin/bash

###############################################################################
# GARNET Application Update Script
# Use this to update the application after initial deployment
#
# Usage: bash update.sh
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
echo -e "${BLUE}    GARNET Application Update${NC}"
echo -e "${BLUE}================================================${NC}"

cd "$DEPLOY_DIR"

# Pull latest code
echo -e "\n${GREEN}[1/5] Pulling latest code...${NC}"
if [ -d ".git" ]; then
    git pull origin main
    echo -e "${GREEN}✓ Code updated${NC}"
else
    echo -e "${YELLOW}Not a git repository, skipping...${NC}"
fi

# Rebuild containers
echo -e "\n${GREEN}[2/5] Rebuilding containers...${NC}"
docker compose -f docker-compose.prod.yml build
echo -e "${GREEN}✓ Containers rebuilt${NC}"

# Restart services
echo -e "\n${GREEN}[3/5] Restarting services...${NC}"
docker compose -f docker-compose.prod.yml up -d
sleep 10
echo -e "${GREEN}✓ Services restarted${NC}"

# Run migrations
echo -e "\n${GREEN}[4/5] Running database migrations...${NC}"
docker compose -f docker-compose.prod.yml exec -T backend php artisan migrate --force
echo -e "${GREEN}✓ Migrations complete${NC}"

# Clear and optimize cache
echo -e "\n${GREEN}[5/5] Optimizing application...${NC}"
docker compose -f docker-compose.prod.yml exec -T backend php artisan config:cache
docker compose -f docker-compose.prod.yml exec -T backend php artisan route:cache
docker compose -f docker-compose.prod.yml exec -T backend php artisan view:cache
docker compose -f docker-compose.prod.yml exec -T backend php artisan optimize
echo -e "${GREEN}✓ Application optimized${NC}"

echo -e "\n${BLUE}================================================${NC}"
echo -e "${GREEN}Update Complete!${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "\n${GREEN}Application status:${NC}"
docker compose -f docker-compose.prod.yml ps