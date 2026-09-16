#!/bin/bash

set -e

echo "🚀 AddMin Docker Initialization"
echo "=================================="
echo ""

# Check if Docker is running
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker Desktop."
    exit 1
fi

echo "✓ Docker found"

# Check if docker-compose is available
if ! docker-compose --version &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Desktop."
    exit 1
fi

echo "✓ Docker Compose found"

# Build images
echo ""
echo "🔨 Building Docker images..."
docker-compose build --no-cache

# Start services
echo ""
echo "🟢 Starting services..."
docker-compose up -d

# Wait for postgres to be ready
echo ""
echo "⏳ Waiting for PostgreSQL to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker-compose exec -T postgres pg_isready -U postgres &> /dev/null; then
        echo "✓ PostgreSQL is ready"
        break
    fi

    attempt=$((attempt + 1))
    echo "  Attempt $attempt/$max_attempts..."
    sleep 1
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ PostgreSQL failed to start"
    docker-compose logs postgres
    exit 1
fi

# Run migrations
echo ""
echo "📦 Running database migrations..."
if docker-compose exec -T api pnpm --filter @addmin/db db:migrate:dev; then
    echo "✓ Migrations completed"
else
    echo "⚠️  Migrations may have already run or encountered an error"
fi

# Print status
echo ""
echo "=================================="
echo "✅ AddMin is ready!"
echo "=================================="
echo ""
echo "📱 Services:"
echo "  • Website:  http://localhost:3000"
echo "  • Operator: http://localhost:3001"
echo "  • Tenant:   http://localhost:3002"
echo "  • API:      http://localhost:3001 (internal)"
echo ""
postgres_port=$(docker-compose port postgres 5432 2>/dev/null | cut -d: -f2)

echo "🗄️  Database:"
echo "  • Host:     localhost:${postgres_port:-unknown}"
echo "  • Database: addmin"
echo "  • User:     postgres"
echo "  • Password: postgres"
echo ""
echo "📋 Useful commands:"
echo "  • View logs:        make docker-logs"
echo "  • Stop services:    make docker-down"
echo "  • Database shell:   make docker-db-shell"
echo "  • Shell access:     make docker-shell-api"
echo ""
echo "🔗 Full documentation: See DOCKER.md"
echo ""
