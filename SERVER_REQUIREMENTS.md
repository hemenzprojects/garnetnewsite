# GARNET Server Setup Requirements

## To: Server Administrator
## From: Michael Himeng
## Project: GARNET Website

---

## My SSH Public Key:

Please add this SSH public key to my user account:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFoMx6EBLKKTfq+8gJuNJROnloXJJwAhl5VLVOPX9/e hemenmike@gmail.com
```

---

## Server Requirements:

### Operating System:
- Ubuntu 22.04 LTS or newer (preferred)
- OR CentOS 8+ / Debian 11+

### Server Specifications:
- **RAM:** 4GB minimum (8GB recommended)
- **Storage:** 20GB minimum (50GB recommended)
- **CPU:** 2 cores minimum

### Software Requirements:

#### Option A - Docker Deployment (Recommended & Easiest):
- Docker Engine 24.x or higher
- Docker Compose 2.x or higher

#### Option B - Traditional Deployment:
- **PHP:** 8.3 with extensions:
  - php-fpm, php-mysql, php-xml, php-mbstring
  - php-curl, php-zip, php-gd, php-redis, php-bcmath

- **Web Server:** Nginx 1.20+ or Apache 2.4+

- **Database:** MySQL 8.0+ or MariaDB 10.6+

- **Node.js:** 20.x LTS

- **Redis:** 7.x (for caching)

- **Process Manager:** Supervisor or systemd

### Network Requirements:
- **Ports to Open:**
  - 80 (HTTP)
  - 443 (HTTPS)
  - 22 (SSH) - for my access

- **SSL Certificate:** Required (Let's Encrypt is fine)

### Domain Setup:
- Please provide the domain name for this project
- DNS should point to the server IP

---

## Access Information Needed:

Please provide me with:

1. **SSH Access:**
   - Server IP address: _______________
   - SSH username: _______________
   - SSH port: _______________ (default: 22)

2. **Server Details:**
   - Operating system & version: _______________
   - Deployment method preference: Docker / Traditional

3. **Database Credentials:**
   - Database name: _______________ (suggested: garnet_db)
   - Database user: _______________ (suggested: garnet_user)
   - Database password: _______________ (will set securely)

4. **Domain:**
   - Primary domain: _______________
   - SSL certificate: Already installed / Need Let's Encrypt

5. **Deployment Directory:**
   - Preferred location: _______________ (suggested: /var/www/garnet)

6. **Permissions:**
   - Do I have sudo access? Yes / No
   - Can I install software? Yes / No

---

## Application Overview:

This is a full-stack web application:

- **Frontend:** Nuxt.js 3 (Vue.js framework) - runs on port 3000
- **Backend:** Laravel 12 (PHP framework) - runs on port 8000
- **Database:** MySQL 8.x
- **Cache:** Redis

### Expected Resource Usage:
- **Disk Space:** ~2GB for application + database growth
- **RAM:** ~1.5GB during normal operation
- **CPU:** Light (educational website)

---

## Deployment Timeline:

Once I have access, deployment will take approximately:
- Docker method: 1-2 hours
- Traditional method: 2-4 hours

This includes:
- Initial setup and configuration
- Database migrations
- SSL certificate setup
- Testing all features

---

## Post-Deployment Needs:

After deployment, I will need:
- Access to view logs (for debugging)
- Ability to restart services (for updates)
- Database backup schedule (your recommendation?)

---

## Security Considerations:

- All sensitive data will be stored in `.env` files (not in git)
- File permissions will be set according to best practices
- I will enable firewall rules as needed
- Regular security updates will be applied

---

## Questions for Server Admin:

1. Is Docker allowed on this server?
2. Do you have a preferred backup solution?
3. Are there any security policies I should be aware of?
4. Do you provide monitoring/alerting services?
5. What's your preferred deployment method?

---

## Contact:

**Email:** michael.himeng@comepetence.team

Please let me know if you need any additional information or if you have any questions about the requirements.

Thank you!