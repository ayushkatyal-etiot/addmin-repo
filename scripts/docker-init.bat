@echo off
setlocal enabledelayedexpansion

echo.
echo 🚀 AddMin Docker Initialization
echo ==================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker not found. Please install Docker Desktop.
    exit /b 1
)

echo ✓ Docker found

REM Check if docker-compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose not found. Please install Docker Desktop.
    exit /b 1
)

echo ✓ Docker Compose found

REM Build images
echo.
echo 🔨 Building Docker images...
docker-compose build --no-cache
if errorlevel 1 (
    echo ❌ Build failed
    exit /b 1
)

REM Start services
echo.
echo 🟢 Starting services...
docker-compose up -d
if errorlevel 1 (
    echo ❌ Failed to start services
    exit /b 1
)

REM Wait for postgres
echo.
echo ⏳ Waiting for PostgreSQL to be ready...
set max_attempts=30
set attempt=0

:wait_postgres
if !attempt! geq !max_attempts! (
    echo ❌ PostgreSQL failed to start
    docker-compose logs postgres
    exit /b 1
)

docker-compose exec -T postgres pg_isready -U postgres >nul 2>&1
if errorlevel 1 (
    set /a attempt=!attempt!+1
    echo   Attempt !attempt!/!max_attempts!...
    timeout /t 1 /nobreak >nul
    goto wait_postgres
)

echo ✓ PostgreSQL is ready

REM Run migrations
echo.
echo 📦 Running database migrations...
docker-compose exec -T api pnpm --filter @addmin/db db:migrate:dev
if errorlevel 1 (
    echo ⚠️  Migrations may have already run or encountered an error
)

REM Print status
echo.
echo ==================================
echo ✅ AddMin is ready!
echo ==================================
echo.
echo 📱 Services:
echo   • Website:  http://localhost:3000
echo   • Operator: http://localhost:3001
echo   • Tenant:   http://localhost:3002
echo   • API:      http://localhost:3001 (internal)
echo.
echo 🗄️  Database:
echo   • Host:     localhost:5432
echo   • Database: addmin
echo   • User:     postgres
echo   • Password: postgres
echo.
echo 📋 Useful commands:
echo   • View logs:        docker-compose logs -f
echo   • Stop services:    docker-compose down
echo   • Database shell:   docker-compose exec postgres psql -U postgres -d addmin
echo.
echo 🔗 Full documentation: See DOCKER.md
echo.
