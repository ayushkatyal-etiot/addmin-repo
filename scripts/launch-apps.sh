#!/bin/bash

###############################################################################
# AddMin Web Apps Launcher - Conductor Single Run Script
#
# Launches all web apps (website, operator, tenant) with Docker
# Includes database setup, migrations, and browser opening
###############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="addmin"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"
POSTGRES_READY_TIMEOUT=60
SERVICES_READY_TIMEOUT=120

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check prerequisites
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    log_success "Docker found"
}

check_docker_compose() {
    if ! docker-compose --version &> /dev/null; then
        log_error "Docker Compose is not installed"
        echo "Please install Docker Desktop with Compose support"
        exit 1
    fi
    log_success "Docker Compose found"
}

check_docker_daemon() {
    if ! docker ps &> /dev/null; then
        log_error "Docker daemon is not running"
        echo "Please start Docker Desktop"
        exit 1
    fi
    log_success "Docker daemon is running"
}

# Clean up function
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Launcher failed (exit code: $exit_code)"
    fi
    return $exit_code
}

trap cleanup EXIT

# Build Docker images
build_images() {
    log_info "Building Docker images..."
    cd "$PROJECT_ROOT"

    if docker-compose build --no-cache 2>&1 | grep -q "ERROR"; then
        log_error "Failed to build Docker images"
        return 1
    fi

    log_success "Docker images built"
}

# Start containers
start_containers() {
    log_info "Starting containers..."
    cd "$PROJECT_ROOT"

    # Start services in background
    docker-compose up -d

    log_success "Containers started"
}

# Wait for PostgreSQL
wait_postgres() {
    log_info "Waiting for PostgreSQL (max ${POSTGRES_READY_TIMEOUT}s)..."

    local start_time=$(date +%s)
    local attempt=0

    while true; do
        if docker-compose exec -T postgres pg_isready -U postgres &> /dev/null; then
            log_success "PostgreSQL is ready"
            return 0
        fi

        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))

        if [ $elapsed -gt $POSTGRES_READY_TIMEOUT ]; then
            log_error "PostgreSQL failed to start within ${POSTGRES_READY_TIMEOUT}s"
            docker-compose logs postgres | tail -20
            return 1
        fi

        attempt=$((attempt + 1))
        echo -ne "  Attempt $attempt... (${elapsed}s elapsed)\r"
        sleep 1
    done
}

# Run database migrations
run_migrations() {
    log_info "Running database migrations..."

    if docker-compose exec -T api pnpm --filter @addmin/db db:migrate:dev &> /tmp/migrations.log; then
        log_success "Migrations completed"
        return 0
    else
        log_warning "Migrations encountered an issue (may already be applied)"
        tail -10 /tmp/migrations.log
    fi
}

# Wait for all services to be healthy
wait_services() {
    log_info "Waiting for services to be ready (max ${SERVICES_READY_TIMEOUT}s)..."

    local start_time=$(date +%s)
    local services=("api" "website" "operator" "tenant")
    local all_ready=false

    while true; do
        all_ready=true
        for service in "${services[@]}"; do
            if ! docker-compose exec -T $service /bin/true &> /dev/null 2>&1; then
                all_ready=false
                break
            fi
        done

        if [ "$all_ready" = true ]; then
            log_success "All services are ready"
            return 0
        fi

        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))

        if [ $elapsed -gt $SERVICES_READY_TIMEOUT ]; then
            log_error "Services failed to start within ${SERVICES_READY_TIMEOUT}s"
            return 1
        fi

        echo -ne "  Waiting... (${elapsed}s)\r"
        sleep 2
    done
}

# Open browser
open_browser() {
    log_info "Opening web apps in browser..."

    local urls=(
        "http://localhost:3000"    # Website
        "http://localhost:3001"    # Operator
        "http://localhost:3002"    # Tenant
    )

    # macOS
    if command -v open &> /dev/null; then
        for url in "${urls[@]}"; do
            open "$url" 2>/dev/null || true
            sleep 0.5
        done
        return 0
    fi

    # Linux
    if command -v xdg-open &> /dev/null; then
        for url in "${urls[@]}"; do
            xdg-open "$url" 2>/dev/null || true
            sleep 0.5
        done
        return 0
    fi

    # Windows (Git Bash, WSL, etc)
    if command -v start &> /dev/null; then
        for url in "${urls[@]}"; do
            start "$url" 2>/dev/null || true
            sleep 0.5
        done
        return 0
    fi

    log_warning "Could not open browser automatically"
    log_info "Please open these URLs manually:"
    for url in "${urls[@]}"; do
        echo "  • $url"
    done
}

# Print status
print_status() {
    log_header "✅ AddMin is Running!"

    local postgres_port=$(docker-compose port postgres 5432 2>/dev/null | cut -d: -f2)

    echo ""
    echo -e "${GREEN}Web Applications:${NC}"
    echo "  • Website (Marketing):      ${BLUE}http://localhost:3000${NC}"
    echo "  • Operator (Control Plane): ${BLUE}http://localhost:3001${NC}"
    echo "  • Tenant (Product):         ${BLUE}http://localhost:3002${NC}"

    echo ""
    echo -e "${GREEN}Database:${NC}"
    echo "  • Host:                     ${BLUE}localhost:${postgres_port:-unknown}${NC}"
    echo "  • Database:                 ${BLUE}addmin${NC}"
    echo "  • User:                     ${BLUE}postgres${NC}"
    echo "  • Password:                 ${BLUE}postgres${NC}"

    echo ""
    echo -e "${GREEN}Useful Commands:${NC}"
    echo "  • View logs:                ${BLUE}make docker-logs${NC}"
    echo "  • Stop services:            ${BLUE}make docker-down${NC}"
    echo "  • Database shell:           ${BLUE}make docker-db-shell${NC}"
    echo "  • API shell:                ${BLUE}make docker-shell-api${NC}"
    echo "  • Full documentation:       ${BLUE}See DOCKER.md${NC}"

    echo ""
    echo -e "${GREEN}Development Mode Active${NC}"
    echo "  • Hot reload enabled for all apps"
    echo "  • Code changes automatically rebuild containers"
    echo "  • Database persists in Docker volume"
    echo "  • Logs available via: make docker-logs"

    echo ""
}

# Print help
print_help() {
    cat << 'EOF'
AddMin Web Apps Launcher

Usage:
  ./scripts/launch-apps.sh [OPTIONS]

Options:
  --no-build              Skip Docker image building (use existing images)
  --no-open               Don't open browser automatically
  --help, -h              Show this help message

Examples:
  # Full setup (build + start + open browser)
  ./scripts/launch-apps.sh

  # Skip rebuild if images already exist
  ./scripts/launch-apps.sh --no-build

  # Start without opening browser
  ./scripts/launch-apps.sh --no-open

Environment Variables:
  POSTGRES_READY_TIMEOUT  Time to wait for PostgreSQL (default: 60s)
  SERVICES_READY_TIMEOUT  Time to wait for services (default: 120s)

EOF
}

# Main flow
main() {
    local skip_build=false
    local skip_open=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-build)
                skip_build=true
                shift
                ;;
            --no-open)
                skip_open=true
                shift
                ;;
            --help|-h)
                print_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
    done

    # Header
    log_header "🚀 AddMin Web Apps Launcher"

    # Checks
    log_info "Checking prerequisites..."
    check_docker
    check_docker_compose
    check_docker_daemon
    log_success "All prerequisites met"

    # Build
    if [ "$skip_build" = false ]; then
        echo ""
        build_images
    else
        log_info "Skipping Docker build (--no-build)"
    fi

    # Start
    echo ""
    start_containers

    # Wait for PostgreSQL
    echo ""
    if ! wait_postgres; then
        log_error "PostgreSQL failed to start"
        exit 1
    fi

    # Migrations
    echo ""
    run_migrations

    # Wait for services
    echo ""
    if ! wait_services; then
        log_error "Services failed to start"
        exit 1
    fi

    # Open browser
    echo ""
    if [ "$skip_open" = false ]; then
        open_browser
    else
        log_info "Skipping browser open (--no-open)"
    fi

    # Status
    echo ""
    print_status

    log_header "Ready to develop!"
    echo ""
}

# Run main function
main "$@"
