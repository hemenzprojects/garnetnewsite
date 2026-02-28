# GARNET Deployment Scripts

This directory contains automated scripts for deploying GARNET to production.

## Scripts Overview

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `1-setup-server.sh` | Initial server setup (Docker, firewall, etc.) | **Once** on fresh server |
| `2-configure-env.sh` | Create environment files with secure passwords | **Once** before first deployment |
| `3-setup-ssl.sh` | Obtain SSL certificate from Let's Encrypt | **Once** after DNS is configured |
| `4-deploy.sh` | Build and deploy the application | Initial deployment |
| `update.sh` | Update application after code changes | Whenever you update code |

## Quick Start

```bash
# 1. First time setup (run once)
sudo bash deployment/1-setup-server.sh
# Log out and back in for docker group

# 2. Configure environment
bash deployment/2-configure-env.sh

# 3. Setup SSL (ensure DNS is configured first!)
bash deployment/3-setup-ssl.sh

# 4. Deploy application
bash deployment/4-deploy.sh

# 5. For updates (run anytime)
bash deployment/update.sh
```

## Prerequisites

Before running these scripts:

1. **Server Access**
   - SSH access to server as `sysadmin` user
   - Sudo privileges

2. **DNS Configuration**
   - Domain `www2.garnet.edu.gh` must point to `169.239.249.15`
   - Verify with: `nslookup www2.garnet.edu.gh`

3. **Application Code**
   - Code uploaded to `/var/www/garnet`
   - All files present (backend/, frontend/, docker-compose.prod.yml, etc.)

## Script Details

### 1-setup-server.sh

**Purpose:** Prepare a fresh server for deployment

**Actions:**
- Updates system packages
- Installs Docker and Docker Compose
- Adds user to docker group
- Installs utilities (git, curl, vim, htop, ufw)
- Configures firewall (ports 22, 80, 443)
- Creates deployment directory

**Run as:** `sudo` (root privileges required)

**Run:** Once per server

### 2-configure-env.sh

**Purpose:** Create environment configuration files

**Actions:**
- Creates `.env.production` with auto-generated secure passwords
- Creates `backend/.env` for Laravel
- Creates `frontend/.env` for Nuxt
- Ensures passwords match across files

**Run as:** Normal user

**Run:** Once before first deployment

**Note:** Passwords are randomly generated and saved. You can view them in `.env.production`

### 3-setup-ssl.sh

**Purpose:** Obtain SSL certificate

**Actions:**
- Verifies DNS configuration
- Starts nginx temporarily
- Obtains Let's Encrypt certificate
- Configures auto-renewal
- Activates production nginx config

**Run as:** Normal user

**Run:** Once after DNS is configured

**Important:** DNS must be properly configured or this will fail!

### 4-deploy.sh

**Purpose:** Deploy the application

**Actions:**
- Builds Docker containers
- Starts all services (backend, frontend, nginx, mysql, redis)
- Generates Laravel app key
- Runs database migrations
- Creates storage link
- Optimizes Laravel
- Prompts to create admin user

**Run as:** Normal user

**Run:** For initial deployment

**Duration:** 5-10 minutes

### update.sh

**Purpose:** Update application after code changes

**Actions:**
- Pulls latest code from git
- Rebuilds containers
- Restarts services
- Runs new migrations
- Clears and rebuilds cache

**Run as:** Normal user

**Run:** Whenever you need to update the application

## Common Issues

### "Permission denied" when running docker

**Solution:** Log out and log back in after running `1-setup-server.sh`

### SSL script fails

**Solution:** Verify DNS with `nslookup www2.garnet.edu.gh` - must return `169.239.249.15`

### Container build fails

**Solution:** Check logs with `docker compose -f docker-compose.prod.yml logs`

## After Deployment

Once deployed, access your application:

- **Frontend:** https://www2.garnet.edu.gh
- **Admin Panel:** https://www2.garnet.edu.gh/admin
- **API:** https://www2.garnet.edu.gh/api/v1

## For Full Documentation

See: [`PRODUCTION_GUIDE.md`](../PRODUCTION_GUIDE.md) in the root directory