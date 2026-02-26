.PHONY: help up down restart build shell logs clean install migrate migrate-fresh migrate-rollback seed test tinker composer npm artisan db-shell redis-shell cache-clear route-clear config-clear view-clear clear-all queue storage-link pint stan docker-reset docker-prune docker-check frontend-shell frontend-logs

# Default target
help:
	@echo "Available commands:"
	@echo "  make up              - Start all Docker containers"
	@echo "  make down            - Stop all Docker containers"
	@echo "  make restart         - Restart all Docker containers"
	@echo "  make build           - Build Docker images"
	@echo "  make shell           - Access Laravel container shell"
	@echo "  make logs            - View container logs"
	@echo "  make clean           - Remove all containers, volumes, and images"
	@echo "  make docker-reset    - Reset Docker (fix build issues)"
	@echo "  make docker-prune    - Clean up Docker system"
	@echo "  make docker-check    - Check Docker health"
	@echo ""
	@echo "  make frontend-shell  - Access frontend container shell"
	@echo "  make frontend-logs   - View frontend logs"
	@echo ""
	@echo "  make install         - Install dependencies (composer & npm)"
	@echo "  make migrate         - Run database migrations"
	@echo "  make migrate-fresh   - Drop all tables and re-run migrations"
	@echo "  make migrate-rollback - Rollback last migration"
	@echo "  make seed            - Run database seeders"
	@echo "  make test            - Run PHPUnit tests"
	@echo "  make tinker          - Run Laravel Tinker"
	@echo ""
	@echo "  make composer CMD='...' - Run composer command"
	@echo "  make npm CMD='...'      - Run npm command"
	@echo "  make artisan CMD='...'  - Run artisan command"
	@echo ""
	@echo "  make db-shell        - Access MySQL shell"
	@echo "  make redis-shell     - Access Redis shell"
	@echo ""
	@echo "  make cache-clear     - Clear application cache"
	@echo "  make route-clear     - Clear route cache"
	@echo "  make config-clear    - Clear config cache"
	@echo "  make view-clear      - Clear view cache"
	@echo "  make clear-all       - Clear all caches"
	@echo ""
	@echo "  make queue           - Start queue worker"
	@echo "  make storage-link    - Create storage symlink"
	@echo "  make pint            - Run Laravel Pint (code style fixer)"

# Docker commands
up:
	cd backend && ./vendor/bin/sail up -d

down:
	cd backend && ./vendor/bin/sail down

restart:
	cd backend && ./vendor/bin/sail restart

build:
	cd backend && ./vendor/bin/sail build --no-cache

shell:
	cd backend && ./vendor/bin/sail shell

logs:
	cd backend && ./vendor/bin/sail logs -f

clean:
	cd backend && ./vendor/bin/sail down -v --remove-orphans
	@echo "Cleaned up containers, volumes, and networks"

# Docker troubleshooting
docker-reset:
	@echo "Stopping all containers..."
	docker stop $$(docker ps -aq) 2>/dev/null || true
	@echo "Removing all containers..."
	docker rm $$(docker ps -aq) 2>/dev/null || true
	@echo "Removing all volumes..."
	docker volume prune -f
	@echo "Docker reset complete. Try 'make build' now."

docker-prune:
	docker system prune -af --volumes
	@echo "Docker system cleaned. Restart Docker Desktop and try 'make build'."

docker-check:
	@echo "Checking Docker..."
	@docker --version
	@docker info | grep "Server Version" || echo "Docker daemon not running!"
	@echo "\nChecking containers..."
	@docker ps -a
	@echo "\nChecking images..."
	@docker images | head -10

# Frontend commands
frontend-shell:
	docker exec -it backend-frontend-1 sh

frontend-logs:
	docker logs -f backend-frontend-1

# Installation commands
install:
	cd backend && ./vendor/bin/sail composer install
	cd backend && ./vendor/bin/sail npm install
	@echo "Dependencies installed successfully"

# Database commands
migrate:
	cd backend && ./vendor/bin/sail artisan migrate

migrate-fresh:
	cd backend && ./vendor/bin/sail artisan migrate:fresh

migrate-rollback:
	cd backend && ./vendor/bin/sail artisan migrate:rollback

seed:
	cd backend && ./vendor/bin/sail artisan db:seed

# Testing
test:
	cd backend && ./vendor/bin/sail artisan test

# Laravel Tinker
tinker:
	cd backend && ./vendor/bin/sail artisan tinker

# Generic commands
composer:
	cd backend && ./vendor/bin/sail composer $(CMD)

npm:
	cd backend && ./vendor/bin/sail npm $(CMD)

artisan:
	cd backend && ./vendor/bin/sail artisan $(CMD)

# Database shell access
db-shell:
	cd backend && ./vendor/bin/sail mysql

redis-shell:
	cd backend && ./vendor/bin/sail redis

# Cache clearing
cache-clear:
	cd backend && ./vendor/bin/sail artisan cache:clear

route-clear:
	cd backend && ./vendor/bin/sail artisan route:clear

config-clear:
	cd backend && ./vendor/bin/sail artisan config:clear

view-clear:
	cd backend && ./vendor/bin/sail artisan view:clear

clear-all: cache-clear route-clear config-clear view-clear
	@echo "All caches cleared"

# Queue worker
queue:
	cd backend && ./vendor/bin/sail artisan queue:work

# Storage link
storage-link:
	cd backend && ./vendor/bin/sail artisan storage:link

# Code quality
pint:
	cd backend && ./vendor/bin/sail pint