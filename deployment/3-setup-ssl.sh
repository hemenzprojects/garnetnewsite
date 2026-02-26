#!/bin/bash

###############################################################################
# GARNET SSL Certificate Setup Script
# Obtains Let's Encrypt SSL certificate for your domain
#
# Usage: bash 3-setup-ssl.sh
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DEPLOY_DIR="/var/www/garnet"
DOMAIN="www2.garnet.edu.gh"
EMAIL="hemenmike@gmail.com"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    GARNET SSL Certificate Setup${NC}"
echo -e "${BLUE}================================================${NC}"

cd "$DEPLOY_DIR"

echo -e "\nDomain: ${GREEN}$DOMAIN${NC}"
echo -e "Email: ${GREEN}$EMAIL${NC}"

# Verify DNS
echo -e "\n${YELLOW}Checking DNS configuration...${NC}"
RESOLVED_IP=$(dig +short $DOMAIN | tail -n1)
echo -e "Domain resolves to: ${GREEN}$RESOLVED_IP${NC}"

read -p "Is this correct? Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted. Please check DNS configuration.${NC}"
    exit 1
fi

# Create temporary nginx config for certificate validation
echo -e "\n${GREEN}[1/4] Creating temporary nginx configuration...${NC}"
cat > nginx/conf.d/temp-ssl.conf << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name www2.garnet.edu.gh;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 200 'SSL certificate setup in progress...';
        add_header Content-Type text/plain;
    }
}
EOF
echo -e "${GREEN}✓ Temporary config created${NC}"

# Start nginx container
echo -e "\n${GREEN}[2/4] Starting nginx for certificate validation...${NC}"
docker compose -f docker-compose.prod.yml up -d nginx
sleep 5
echo -e "${GREEN}✓ Nginx started${NC}"

# Obtain SSL certificate
echo -e "\n${GREEN}[3/4] Obtaining SSL certificate from Let's Encrypt...${NC}"
echo -e "${YELLOW}This may take a minute...${NC}"

docker compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d "$DOMAIN"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Certificate obtained successfully!${NC}"
else
    echo -e "${RED}Failed to obtain certificate!${NC}"
    echo -e "${YELLOW}Check that:${NC}"
    echo -e "  1. DNS is correctly configured"
    echo -e "  2. Port 80 is open"
    echo -e "  3. Domain resolves to this server"
    exit 1
fi

# Remove temporary config
echo -e "\n${GREEN}[4/4] Activating production nginx configuration...${NC}"
rm -f nginx/conf.d/temp-ssl.conf
docker compose -f docker-compose.prod.yml restart nginx
echo -e "${GREEN}✓ Production nginx config activated${NC}"

echo -e "\n${BLUE}================================================${NC}"
echo -e "${GREEN}SSL Certificate Setup Complete!${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "\nCertificate details:"
docker compose -f docker-compose.prod.yml exec certbot certbot certificates

echo -e "\n${GREEN}Your SSL certificate is installed and will auto-renew!${NC}"
echo -e "${YELLOW}Certificate location:${NC} /etc/letsencrypt/live/$DOMAIN/"

echo -e "\n${GREEN}Next step:${NC}"
echo -e "Run: ${YELLOW}bash 4-deploy.sh${NC}"