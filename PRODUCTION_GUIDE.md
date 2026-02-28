# GARNET Production Deployment Guide

Complete step-by-step guide to deploy GARNET on production server.

## Server Information

| Item | Value |
|------|-------|
| **Server IP** | 169.239.249.15 |
| **Domain** | www2.garnet.edu.gh |
| **SSH User** | sysadmin |
| **SSH Port** | 22 |
| **OS** | Ubuntu 24.04.4 LTS |
| **Method** | Docker |
| **Directory** | /var/www/garnet |

---

## Prerequisites

Before starting, ensure:
- ✅ You have SSH access to the server
- ✅ Domain DNS is configured (www2.garnet.edu.gh → 169.239.249.15)
- ✅ You have sudo privileges on the server

---

## Quick Start (For Experienced Users)

```bash
# On server
sudo bash deployment/1-setup-server.sh
# Log out and back in
bash deployment/2-configure-env.sh
bash deployment/3-setup-ssl.sh
bash deployment/4-deploy.sh
```

---

## Detailed Step-by-Step Instructions

### Step 1: Prepare Your SSH Key

**On your local machine:**

Your SSH public key has been provided to the server administrator:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFoMx6EBLKKTfq+8gJuNJROnloXJJwAhl5VLVOPX9/e hemenmike@gmail.com
```

**Test SSH connection:**
```bash
ssh sysadmin@169.239.249.15
```

If successful, you should be logged into the server.

---

### Step 2: Upload Application Code to Server

**Option A: Using Git (Recommended)**

```bash
# On the server
cd /var/www/garnet
git clone <your-repository-url> .
```

**Option B: Using SCP from your local machine**

```bash
# On your local machine
cd /Users/michaelhimeng/Documents/Applications/garnetnewsite
scp -r * sysadmin@169.239.249.15:/var/www/garnet/
```

**Verify files are uploaded:**
```bash
# On the server
ls -la /var/www/garnet
```

You should see: `backend/`, `frontend/`, `docker-compose.prod.yml`, `deployment/`, etc.

---

### Step 3: Run Server Setup Script

This script installs Docker, Docker Compose, and prepares the server.

```bash
# On the server
cd /var/www/garnet
sudo bash deployment/1-setup-server.sh
```

**What this script does:**
- Updates system packages
- Installs Docker and Docker Compose
- Adds `sysadmin` user to docker group
- Installs utilities (git, curl, vim, etc.)
- Configures firewall (opens ports 22, 80, 443)
- Creates deployment directory

**IMPORTANT:** After the script completes:
```bash
exit
# Log back in
ssh sysadmin@169.239.249.15
```

**Verify Docker works without sudo:**
```bash
docker ps
```

This should work without permission errors.

---

### Step 4: Configure Environment Variables

This script creates environment files with secure passwords.

```bash
cd /var/www/garnet
bash deployment/2-configure-env.sh
```

**What this script does:**
- Creates `.env.production` with auto-generated secure passwords
- Creates `backend/.env` with matching database credentials
- Creates `frontend/.env` with API URL

**Files created:**
- `.env.production` - Docker Compose environment
- `backend/.env` - Laravel configuration
- `frontend/.env` - Nuxt configuration

**Optional: Configure Email**

If you need to send emails, edit `backend/.env`:

```bash
nano backend/.env
```

Update these values:
```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-specific-password
MAIL_ENCRYPTION=tls
```

---

### Step 5: Setup SSL Certificate

This script obtains a free Let's Encrypt SSL certificate for your domain.

```bash
cd /var/www/garnet
bash deployment/3-setup-ssl.sh
```

**What this script does:**
- Verifies DNS configuration
- Starts nginx temporarily
- Obtains SSL certificate from Let's Encrypt
- Configures auto-renewal

**Important:** This step will fail if:
- DNS is not configured correctly
- Domain doesn't resolve to your server IP
- Port 80 is not accessible

**To verify DNS before running:**
```bash
nslookup www2.garnet.edu.gh
# Should return: 169.239.249.15
```

---

### Step 6: Deploy Application

This is the main deployment script.

```bash
cd /var/www/garnet
bash deployment/4-deploy.sh
```

**What this script does:**
1. Builds Docker containers (backend, frontend, nginx, mysql, redis)
2. Stops old containers
3. Starts new containers
4. Generates Laravel application key
5. Runs database migrations
6. Creates storage symbolic link
7. Optimizes Laravel (config, routes, views)
8. Prompts you to create admin user

**Creating Admin User:**

When prompted, enter:
- **Name:** Admin User
- **Email:** admin@garnet.edu.gh
- **Password:** (choose a strong password and save it securely!)

**Deployment takes:** 5-10 minutes depending on server speed.

---

### Step 7: Verify Deployment

**Check container status:**
```bash
cd /var/www/garnet
docker compose -f docker-compose.prod.yml ps
```

All services should show "Up" and healthy.

**Test in browser:**
1. Frontend: https://www2.garnet.edu.gh
2. Admin Panel: https://www2.garnet.edu.gh/admin
3. API: https://www2.garnet.edu.gh/api/v1/settings

**Check SSL certificate:**
- Visit https://www2.garnet.edu.gh
- Look for green padlock in browser
- Certificate should be valid from Let's Encrypt

---

## Post-Deployment Tasks

### Add Sample Content

1. Go to https://www2.garnet.edu.gh/admin
2. Login with admin credentials
3. Create some sample content:
   - Pages
   - News articles
   - Events
   - Member institutions
   - Services

### Setup Database Backups

Create a backup script:

```bash
cat > /var/www/garnet/backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/www/garnet/backups"
mkdir -p $BACKUP_DIR
cd /var/www/garnet

# Load environment
source .env.production

# Create backup
docker compose -f docker-compose.prod.yml exec -T mysql \
  mysqldump -u root -p$DB_ROOT_PASSWORD $DB_DATABASE \
  > $BACKUP_DIR/garnet-$(date +%Y%m%d-%H%M%S).sql

# Keep only last 7 days
find $BACKUP_DIR -name "garnet-*.sql" -mtime +7 -delete

echo "Backup completed: $(date)"
EOF

chmod +x /var/www/garnet/backup-db.sh
```

**Schedule daily backups:**
```bash
crontab -e
```

Add this line:
```
0 2 * * * /var/www/garnet/backup-db.sh >> /var/www/garnet/backups/backup.log 2>&1
```

This runs daily at 2 AM.

---

## Updating the Application

When you need to update the application code:

```bash
cd /var/www/garnet
bash deployment/update.sh
```

This script:
- Pulls latest code from git
- Rebuilds containers
- Restarts services
- Runs new migrations
- Clears and rebuilds cache

---

## Useful Commands

### View Logs

```bash
# All services
docker compose -f docker-compose.prod.yml logs -f

# Specific service
docker compose -f docker-compose.prod.yml logs -f backend
docker compose -f docker-compose.prod.yml logs -f frontend
docker compose -f docker-compose.prod.yml logs -f nginx

# Laravel application logs
docker compose -f docker-compose.prod.yml exec backend tail -f storage/logs/laravel.log
```

### Container Management

```bash
# Check status
docker compose -f docker-compose.prod.yml ps

# Restart all services
docker compose -f docker-compose.prod.yml restart

# Restart specific service
docker compose -f docker-compose.prod.yml restart backend

# Stop all
docker compose -f docker-compose.prod.yml down

# Start all
docker compose -f docker-compose.prod.yml up -d
```

### Laravel Commands

```bash
# Access Laravel console
docker compose -f docker-compose.prod.yml exec backend php artisan tinker

# Run migrations
docker compose -f docker-compose.prod.yml exec backend php artisan migrate

# Clear cache
docker compose -f docker-compose.prod.yml exec backend php artisan cache:clear
docker compose -f docker-compose.prod.yml exec backend php artisan config:clear
docker compose -f docker-compose.prod.yml exec backend php artisan view:clear

# Create new admin user
docker compose -f docker-compose.prod.yml exec backend php artisan make:filament-user
```

### Database Access

```bash
# Access MySQL console
docker compose -f docker-compose.prod.yml exec mysql mysql -u root -p

# Create manual backup
docker compose -f docker-compose.prod.yml exec mysql \
  mysqldump -u root -p garnet_db > backup-$(date +%Y%m%d).sql

# Restore from backup
docker compose -f docker-compose.prod.yml exec -T mysql \
  mysql -u root -p garnet_db < backup-20240226.sql
```

---

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose -f docker-compose.prod.yml logs [service-name]

# Rebuild container
docker compose -f docker-compose.prod.yml build --no-cache [service-name]
docker compose -f docker-compose.prod.yml up -d [service-name]
```

### Database Connection Error

1. Check MySQL is running:
```bash
docker compose -f docker-compose.prod.yml ps mysql
```

2. Verify credentials in `backend/.env` match `.env.production`

3. Check MySQL logs:
```bash
docker compose -f docker-compose.prod.yml logs mysql
```

### 502 Bad Gateway

1. Check nginx logs:
```bash
docker compose -f docker-compose.prod.yml logs nginx
```

2. Verify backend is running:
```bash
docker compose -f docker-compose.prod.yml ps backend
```

3. Restart nginx:
```bash
docker compose -f docker-compose.prod.yml restart nginx
```

### SSL Certificate Issues

```bash
# Check certificate status
docker compose -f docker-compose.prod.yml exec certbot certbot certificates

# Force renewal
docker compose -f docker-compose.prod.yml exec certbot certbot renew --force-renewal

# Restart nginx after renewal
docker compose -f docker-compose.prod.yml restart nginx
```

### Out of Disk Space

```bash
# Check disk usage
df -h

# Clean Docker unused images/containers
docker system prune -a

# Clean old logs
truncate -s 0 /var/www/garnet/backend/storage/logs/laravel.log
```

### Permission Errors

```bash
docker compose -f docker-compose.prod.yml exec backend \
  chown -R www-data:www-data storage bootstrap/cache

docker compose -f docker-compose.prod.yml exec backend \
  chmod -R 775 storage bootstrap/cache
```

---

## Security Checklist

- [x] Firewall configured (only ports 22, 80, 443 open)
- [x] SSL certificate installed and auto-renewing
- [x] Strong database passwords generated
- [x] Laravel debug mode disabled (APP_DEBUG=false)
- [ ] Regular backups configured
- [ ] Fail2ban installed (optional but recommended)
- [ ] Server OS regularly updated

### Install Fail2ban (Recommended)

```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## Architecture Overview

```
                                     ┌──────────────┐
                                     │   Internet   │
                                     └──────┬───────┘
                                            │
                                     ┌──────▼───────┐
                                     │  Port 80/443 │
                                     │    Nginx     │
                                     └──────┬───────┘
                                            │
                        ┌───────────────────┼───────────────────┐
                        │                   │                   │
                  ┌─────▼─────┐      ┌──────▼──────┐     ┌─────▼────┐
                  │  Frontend │      │   Backend   │     │ Storage  │
                  │ (Nuxt:3000)│      │(Laravel:9000)│     │  Files   │
                  └───────────┘      └──────┬──────┘     └──────────┘
                                            │
                                 ┌──────────┼──────────┐
                                 │          │          │
                          ┌──────▼───┐  ┌───▼────┐   │
                          │  MySQL   │  │ Redis  │   │
                          │ (DB:3306)│  │(:6379) │   │
                          └──────────┘  └────────┘   │
                                                      │
                                               ┌──────▼──────┐
                                               │  Certbot    │
                                               │(SSL Renewal)│
                                               └─────────────┘
```

---

## File Structure

```
/var/www/garnet/
├── backend/                    # Laravel application
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── public/
│   ├── storage/
│   ├── .env                   # Laravel environment
│   └── Dockerfile.prod        # Laravel Docker build
├── frontend/                  # Nuxt application
│   ├── pages/
│   ├── components/
│   ├── .env                   # Nuxt environment
│   └── Dockerfile.prod        # Nuxt Docker build
├── nginx/                     # Nginx configuration
│   ├── nginx.conf
│   └── conf.d/
│       └── garnet.conf
├── certbot/                   # SSL certificates
│   ├── conf/
│   └── www/
├── deployment/                # Deployment scripts
│   ├── 1-setup-server.sh
│   ├── 2-configure-env.sh
│   ├── 3-setup-ssl.sh
│   ├── 4-deploy.sh
│   └── update.sh
├── .env.production            # Docker Compose environment
└── docker-compose.prod.yml    # Production Docker config
```

---

## Support & Contacts

**Developer:** hemenmike@gmail.com

**Documentation:**
- Laravel: https://laravel.com/docs
- Filament: https://filamentphp.com/docs
- Nuxt: https://nuxt.com/docs
- Docker: https://docs.docker.com

---

## Quick Reference Card

### Essential URLs
```
Frontend:     https://www2.garnet.edu.gh
Admin Panel:  https://www2.garnet.edu.gh/admin
API:          https://www2.garnet.edu.gh/api/v1
```

### Essential Commands
```bash
# Deploy/Update
cd /var/www/garnet && bash deployment/update.sh

# Check status
docker compose -f docker-compose.prod.yml ps

# View logs
docker compose -f docker-compose.prod.yml logs -f

# Restart
docker compose -f docker-compose.prod.yml restart

# Backup database
docker compose -f docker-compose.prod.yml exec mysql \
  mysqldump -u root -p garnet_db > backup.sql
```

### Credentials Location
- Database passwords: `.env.production`
- Laravel config: `backend/.env`
- Admin user: (set during deployment)

---

**Document Version:** 1.0
**Last Updated:** 2024-02-26
**Server:** www2.garnet.edu.gh (169.239.249.15)