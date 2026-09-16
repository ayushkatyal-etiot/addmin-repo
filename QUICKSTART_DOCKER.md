# AddMin Docker Quick Start

Get the entire project running with Docker in 2 minutes.

## One-Command Setup

### macOS / Linux

```bash
./scripts/docker-init.sh
```

### Windows (PowerShell)

```powershell
scripts\docker-init.bat
```

## What Happens

1. ✅ Builds all Docker images
2. ✅ Starts all containers (API, Website, Operator, Tenant, PostgreSQL)
3. ✅ Waits for database to be ready
4. ✅ Runs database migrations
5. ✅ Prints access URLs

## Access the Apps

Once the setup completes:

- **Website** (Marketing): http://localhost:3000
- **Operator** (Control Plane): http://localhost:3001
- **Tenant** (Product): http://localhost:3002

## Common Tasks

```bash
# View real-time logs
make docker-logs

# Connect to database shell
make docker-db-shell

# Shell into a container
make docker-shell-api
make docker-shell-website

# Stop everything
make docker-down

# Stop and delete all data
make docker-clean
```

## Manual Setup (Alternative)

If you prefer step-by-step:

```bash
# 1. Build images
docker-compose build

# 2. Start services
docker-compose up -d

# 3. Wait 10 seconds for database...
sleep 10

# 4. Run migrations
docker-compose exec api pnpm --filter @addmin/db db:migrate:dev

# 5. Done! Visit http://localhost:3000
```

## Troubleshooting

**Services won't start?**
```bash
docker-compose logs
# Check output for errors
```

**Port already in use?**
```bash
# Change port in docker-compose.yml or:
export WEBSITE_PORT=3003
docker-compose up
```

**Database not working?**
```bash
# Check postgres
docker-compose logs postgres

# Reset database
docker-compose down -v
docker-compose up
```

## Next Steps

See [DOCKER.md](./DOCKER.md) for complete documentation including:
- Environment variables
- Health checks
- Development workflow
- Production deployment
- Troubleshooting guide

Happy coding! 🚀
