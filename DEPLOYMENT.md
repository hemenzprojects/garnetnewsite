# GARNET Deployment Guide

## Server Requirements

### Minimum Specifications:
- **OS:** Ubuntu 22.04 LTS or newer
- **RAM:** 2GB minimum, 4GB recommended
- **Storage:** 20GB minimum
- **PHP:** 8.2 or higher
- **Node.js:** 20.x or higher
- **Database:** MySQL 8.0 or higher
- **Web Server:** Nginx (recommended) or Apache

## Deployment Options

---

## Option 1: Docker Deployment (Recommended)

### Prerequisites on Server:
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

### Deployment Steps:

1. **Clone Repository:**
```bash
ssh user@your-server.com
cd /var/www
git clone YOUR_REPO_URL garnet
cd garnet
```

2. **Configure Environment:**
```bash
# Backend
cp backend/.env.example backend/.env
nano backend/.env

# Update these values:
APP_URL=https://your-domain.com
DB_PASSWORD=strong-password-here
```

3. **Build and Start:**
```bash
docker-compose up -d --build
```

4. **Run Migrations:**
```bash
docker-compose exec laravel.test php artisan migrate --force
docker-compose exec laravel.test php artisan db:seed --force
```

5. **Set Up SSL (with Let's Encrypt):**
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

### Nginx Configuration for Docker:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Option 2: Traditional Deployment (Without Docker)

### 1. Install Dependencies on Server:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP 8.3 and extensions
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.3 php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring \
  php8.3-curl php8.3-zip php8.3-gd php8.3-redis php8.3-bcmath -y

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation

# Install Nginx
sudo apt install nginx -y

# Install Redis
sudo apt install redis-server -y
```

### 2. Deploy Laravel Backend:

```bash
# Create directory
sudo mkdir -p /var/www/garnet
sudo chown -R $USER:$USER /var/www/garnet

# Clone repository
cd /var/www/garnet
git clone YOUR_REPO_URL .

# Install backend dependencies
cd backend
composer install --no-dev --optimize-autoloader

# Configure environment
cp .env.example .env
nano .env

# Set proper values:
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# Generate key
php artisan key:generate

# Set permissions
sudo chown -R www-data:www-data /var/www/garnet/backend/storage
sudo chown -R www-data:www-data /var/www/garnet/backend/bootstrap/cache
sudo chmod -R 775 /var/www/garnet/backend/storage
sudo chmod -R 775 /var/www/garnet/backend/bootstrap/cache

# Run migrations
php artisan migrate --force
php artisan db:seed --force

# Cache config
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 3. Deploy Nuxt Frontend:

```bash
cd /var/www/garnet/frontend

# Install dependencies
npm install

# Update .env for production
echo "NUXT_PUBLIC_API_BASE=https://your-domain.com/api/v1" > .env

# Build for production
npm run build

# Install PM2 to run Node.js app
sudo npm install -g pm2

# Start the app
pm2 start npm --name "garnet-frontend" -- start
pm2 save
pm2 startup
```

### 4. Nginx Configuration:

Create `/etc/nginx/sites-available/garnet`:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # Frontend (Nuxt)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API
    location /api {
        alias /var/www/garnet/backend/public;
        try_files $uri $uri/ @laravel;

        location ~ \.php$ {
            fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
            fastcgi_param SCRIPT_FILENAME /var/www/garnet/backend/public/index.php;
            include fastcgi_params;
        }
    }

    location @laravel {
        rewrite /api/(.*)$ /api/index.php?/$1 last;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/garnet /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 5. Set Up Queue Workers (Optional):

Create `/etc/supervisor/conf.d/garnet-worker.conf`:

```ini
[program:garnet-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/garnet/backend/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/garnet/backend/storage/logs/worker.log
stopwaitsecs=3600
```

Start the workers:
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start garnet-worker:*
```

---

## Post-Deployment Checklist

- [ ] Test frontend: `https://your-domain.com`
- [ ] Test backend API: `https://your-domain.com/api/v1/news`
- [ ] Check SSL certificate is working
- [ ] Test database connections
- [ ] Verify file uploads work
- [ ] Check email functionality
- [ ] Set up daily database backups
- [ ] Set up monitoring (optional: UptimeRobot, Pingdom)
- [ ] Set up log rotation

---

## Continuous Deployment

### Using Git Hooks:

Create `/var/www/garnet/deploy.sh`:

```bash
#!/bin/bash
cd /var/www/garnet

# Pull latest code
git pull origin main

# Backend updates
cd backend
composer install --no-dev
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Frontend updates
cd ../frontend
npm install
npm run build
pm2 restart garnet-frontend

echo "Deployment complete!"
```

Make it executable:
```bash
chmod +x /var/www/garnet/deploy.sh
```

---

## Troubleshooting

### Check Logs:
```bash
# Laravel logs
tail -f /var/www/garnet/backend/storage/logs/laravel.log

# Nginx logs
tail -f /var/log/nginx/error.log

# Frontend logs (PM2)
pm2 logs garnet-frontend
```

### Common Issues:

**1. Permission Errors:**
```bash
sudo chown -R www-data:www-data /var/www/garnet/backend/storage
sudo chmod -R 775 /var/www/garnet/backend/storage
```

**2. Database Connection Failed:**
- Check MySQL is running: `sudo systemctl status mysql`
- Verify credentials in `.env`
- Check firewall rules

**3. 502 Bad Gateway:**
- Check PHP-FPM is running: `sudo systemctl status php8.3-fpm`
- Check Nginx config: `sudo nginx -t`

---

## Security Recommendations

1. **Firewall:**
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

2. **Regular Updates:**
```bash
sudo apt update && sudo apt upgrade -y
```

3. **Database Backups:**
```bash
# Create backup script
mysqldump -u root -p garnet_db > backup-$(date +%Y%m%d).sql
```

4. **Monitor Logs:**
```bash
# Install fail2ban
sudo apt install fail2ban -y
```

---

## Maintenance

### Update Application:
```bash
cd /var/www/garnet
./deploy.sh
```

### Database Backup:
```bash
php artisan backup:run
```

### Clear Cache:
```bash
php artisan cache:clear
php artisan config:clear
php artisan view:clear
```