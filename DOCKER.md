# Docker Setup for AddMin

Complete Docker configuration for developing and deploying AddMin with PostgreSQL in containers.

## What's Included

- **PostgreSQL 16** database with persistent volumes
- **Express API** backend service
- **Next.js Website** (marketing site)
- **Next.js Operator** (control plane)
- **Next.js Tenant** (product app)
- **pnpm** monorepo support
- Health checks and service dependencies
- Hot-reload development mode

## Prerequisites

- Docker Desktop 4.0+ or Docker Engine + Docker Compose
- 4GB+ RAM available for containers
- macOS, Linux, or Windows with WSL2

## Quick Start

### 1. **Start All Services**

```bash
# Start in background
docker-compose up -d

# Or view logs in real-time
docker-compose up

# Or use make
make docker-up
```

Services start on:
- **Website**: http://localhost:3000
- **Operator**: http://localhost:3001
- **Tenant**: http://localhost:3002
- **API**: http://localhost:3001 (internal)
- **Database**: postgres://postgres:postgres@localhost:5432/addmin

### 2. **Run Database Migrations**

```bash
# Method 1: Docker exec
docker-compose exec api pnpm --filter @addmin/db db:migrate:dev

# Method 2: Make
make docker-db-migrate
```

### 3. **View Logs**

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f postgres

# Or use make
make docker-logs
make docker-logs-api
```

### 4. **Stop Services**

```bash
docker-compose down

# Clean up volumes (resets database)
docker-compose down -v
```

## Common Commands

### Development

```bash
# Start all services
make docker-up

# View combined logs
make docker-logs

# Shell access to a container
make docker-shell-api
make docker-shell-website

# Restart a service
make docker-restart-api

# Stop everything
make docker-down
```

### Database

```bash
# Run migrations
make docker-db-migrate

# Connect to PostgreSQL
make docker-db-shell

# View database logs
make docker-logs-db

# Full reset (delete data)
make docker-clean
```

### Building

```bash
# Rebuild all images
make docker-build

# Rebuild specific image
docker-compose build api

# Pull latest node image
docker-compose build --pull
```

## Environment Configuration

The project uses `.env.docker` for Docker-specific variables:

```bash
# Database
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/addmin

# API
API_URL=http://api:3001

# NextAuth
NEXTAUTH_SECRET=dev-secret-key-min-32-characters-long-for-local-dev
NEXTAUTH_URL=http://localhost:3000
```

To use custom values:
```bash
# Set environment variables before running
export DATABASE_URL=postgresql://user:pass@localhost:5432/addmin
export NEXTAUTH_SECRET=your-secret-key-here
docker-compose up
```

## Architecture

```
┌─────────────────────────────────────────┐
│         Docker Compose Network          │
│  (addmin-network)                       │
└─────────────────────────────────────────┘
  │
  ├─ postgres:5432 ──────────────────────── PostgreSQL 16 (persistent volume)
  │
  ├─ api:3001 ────────────────────────── Express API
  │   └─ depends_on: postgres
  │   └─ volumes: live code reload
  │   └─ pnpm --filter @addmin/api dev
  │
  ├─ website:3000 ────────────────────── Next.js Website
  │   └─ depends_on: api
  │   └─ volumes: live code reload
  │
  ├─ operator:3001 ───────────────────── Next.js Operator (control plane)
  │   └─ depends_on: api
  │   └─ volumes: live code reload
  │
  └─ tenant:3002 ─────────────────────── Next.js Tenant (product)
      └─ depends_on: api
      └─ volumes: live code reload
```

## Volumes

- **postgres_data**: Persistent PostgreSQL data directory
- **node_modules**: Cached dependencies for faster builds
- **Live mounts**: Source code for hot-reload development

## Networking

All services communicate via the `addmin-network` bridge:
- Internal API calls: `http://api:3001`
- External (from host): `http://localhost:3001`

## Troubleshooting

### Containers won't start

```bash
# Check Docker daemon
docker ps

# View detailed logs
docker-compose logs

# Check disk space
docker system df

# Clean up
docker system prune
```

### Database connection errors

```bash
# Check postgres health
docker-compose exec postgres pg_isready -U postgres

# View postgres logs
docker-compose logs postgres

# Reset database
docker-compose down -v
docker-compose up
```

### Port already in use

```bash
# Find process using port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Change ports in docker-compose.yml or use environment variables
export WEBSITE_PORT=3003
docker-compose up
```

### Hot-reload not working

Ensure volume mounts are correct:
```bash
docker-compose exec website ls -la /app/apps/website
```

If missing, restart with:
```bash
docker-compose down
docker-compose up --build
```

## Production Deployment

For production, create separate Dockerfiles without volume mounts:

```bash
# Use multi-stage builds for smaller images
# Remove hot-reload volumes
# Use --prod flag for pnpm install
# Set NODE_ENV=production
```

Example production docker-compose:
```yaml
services:
  api:
    build:
      context: .
      dockerfile: services/api/Dockerfile.prod
    environment:
      NODE_ENV: production
    restart: always
    # No volumes (immutable)
```

## Health Checks

All services have health checks:
```bash
# View health status
docker-compose ps

# Check specific service
docker inspect addmin-api | grep -A 5 Health
```

## Next Steps

1. Start services: `make docker-up`
2. Run migrations: `make docker-db-migrate`
3. Access http://localhost:3000
4. Begin Cycle 1 development
5. Check logs: `make docker-logs`

## Further Reading

- [Docker Documentation](https://docs.docker.com)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file)
- [Best Practices for Node.js in Docker](https://nodejs.org/en/docs/guides/nodejs-docker-webapp)
