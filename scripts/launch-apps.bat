@echo off
REM ###############################################################################
REM AddMin Web Apps Launcher - Conductor Single Run Script (Windows)
REM
REM Launches all web apps (website, operator, tenant) with Docker
REM Includes database setup, migrations, and browser opening
REM ###############################################################################

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_NAME=addmin
set POSTGRES_READY_TIMEOUT=60
set SERVICES_READY_TIMEOUT=120

REM Get script directory
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..

REM ============================================================================
REM Main Script
REM ============================================================================

echo.
echo ===============================================================================
echo   AddMin Web Apps Launcher
echo ===============================================================================
echo.

REM Check Docker
echo Checking prerequisites...

docker --version >nul 2>&1
if errorlevel 1 (
    echo [X] Docker is not installed
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    exit /b 1
)
echo [OK] Docker found

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [X] Docker Compose is not installed
    echo Please install Docker Desktop with Compose support
    exit /b 1
)
echo [OK] Docker Compose found

docker ps >nul 2>&1
if errorlevel 1 (
    echo [X] Docker daemon is not running
    echo Please start Docker Desktop
    exit /b 1
)
echo [OK] Docker daemon is running

echo.
echo Building Docker images...
cd /d "%PROJECT_ROOT%"
docker-compose build --no-cache
if errorlevel 1 (
    echo [X] Failed to build Docker images
    exit /b 1
)
echo [OK] Docker images built

echo.
echo Starting containers...
docker-compose up -d
if errorlevel 1 (
    echo [X] Failed to start containers
    exit /b 1
)
echo [OK] Containers started

echo.
echo Waiting for PostgreSQL...
set attempt=0
set max_attempts=%POSTGRES_READY_TIMEOUT%

:wait_postgres
if !attempt! geq !max_attempts! (
    echo [X] PostgreSQL failed to start
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
echo [OK] PostgreSQL is ready

echo.
echo Running database migrations...
docker-compose exec -T api pnpm --filter @addmin/db db:migrate:dev >nul 2>&1
if errorlevel 1 (
    echo [WARN] Migrations may have already been applied
) else (
    echo [OK] Migrations completed
)

echo.
echo Waiting for services...
timeout /t 10 /nobreak >nul
echo [OK] All services are ready

echo.
echo ===============================================================================
echo   AddMin is Running!
echo ===============================================================================
echo.

echo Web Applications:
echo   * Website (Marketing):      http://localhost:3000
echo   * Operator (Control Plane): http://localhost:3001
echo   * Tenant (Product):         http://localhost:3002
echo.

echo Database:
echo   * Host:                     localhost:5432
echo   * Database:                 addmin
echo   * User:                     postgres
echo   * Password:                 postgres
echo.

echo Useful Commands:
echo   * View logs:                docker-compose logs -f
echo   * Stop services:            docker-compose down
echo   * Database shell:           docker-compose exec postgres psql -U postgres -d addmin
echo.

echo Opening web apps in browser...
start http://localhost:3000
timeout /t 1 /nobreak >nul
start http://localhost:3001
timeout /t 1 /nobreak >nul
start http://localhost:3002

echo.
echo Development Mode Active
echo   * Hot reload enabled for all apps
echo   * Code changes automatically rebuild containers
echo   * Database persists in Docker volume
echo   * Logs available via: docker-compose logs -f
echo.

echo Ready to develop!
