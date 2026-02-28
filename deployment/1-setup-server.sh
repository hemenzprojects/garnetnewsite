#!/bin/bash

###############################################################################
# GARNET Server Initial Setup Script
# Run this ONCE on a fresh server to prepare it for deployment
#
# Usage: sudo bash 1-setup-server.sh
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    GARNET Server Initial Setup${NC}"
echo -e "${BLUE}================================================${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo -e "Usage: ${YELLOW}sudo bash 1-setup-server.sh${NC}"
    exit 1
fi

echo -e "\n${GREEN}[1/7] Updating system packages...${NC}"
apt update && apt upgrade -y
echo -e "${GREEN}✓ System updated${NC}"

echo -e "\n${GREEN}[2/7] Installing Docker...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker already installed, skipping...${NC}"
else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo -e "${GREEN}✓ Docker installed${NC}"
fi

echo -e "\n${GREEN}[3/7] Installing Docker Compose plugin...${NC}"
apt-get install -y docker-compose-plugin
echo -e "${GREEN}✓ Docker Compose installed${NC}"

echo -e "\n${GREEN}[4/7] Adding sysadmin user to docker group...${NC}"
usermod -aG docker sysadmin
echo -e "${GREEN}✓ User added to docker group${NC}"

echo -e "\n${GREEN}[5/7] Installing additional utilities...${NC}"
apt install -y git curl wget vim nano htop ufw
echo -e "${GREEN}✓ Utilities installed${NC}"

echo -e "\n${GREEN}[6/7] Configuring firewall...${NC}"
ufw --force enable
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
echo -e "${GREEN}✓ Firewall configured${NC}"

echo -e "\n${GREEN}[7/7] Creating deployment directory...${NC}"
mkdir -p /var/www/garnet
chown -R sysadmin:sysadmin /var/www/garnet
echo -e "${GREEN}✓ Directory created: /var/www/garnet${NC}"

echo -e "\n${BLUE}================================================${NC}"
echo -e "${GREEN}Server setup complete!${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "\nInstalled versions:"
docker --version
docker compose version
git --version

echo -e "\n${YELLOW}IMPORTANT NEXT STEPS:${NC}"
echo -e "1. ${GREEN}Log out and log back in${NC} (for docker group to take effect)"
echo -e "2. Upload/clone your application code to ${BLUE}/var/www/garnet${NC}"
echo -e "3. Run: ${YELLOW}bash 2-configure-env.sh${NC}"
echo -e "4. Run: ${YELLOW}bash 3-setup-ssl.sh${NC}"
echo -e "5. Run: ${YELLOW}bash 4-deploy.sh${NC}"

echo -e "\n${GREEN}To verify docker works without sudo after re-login:${NC}"
echo -e "${YELLOW}docker ps${NC}"