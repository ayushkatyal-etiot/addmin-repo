.PHONY: help docker-build docker-up docker-down docker-logs docker-db-migrate docker-db-seed docker-clean docker-ps

help:
	@echo "AddMin Docker Commands"
	@echo "====================="
	@echo ""
	@echo "Development:"
	@echo "  make docker-up              Start all services in development mode"
	@echo "  make docker-down            Stop all services"
	@echo "  make docker-logs            View logs from all services"
	@echo "  make docker-build           Build all Docker images"
	@echo "  make docker-ps              Show running containers"
	@echo ""
	@echo "Database:"
	@echo "  make docker-db-migrate      Run database migrations"
	@echo "  make docker-db-seed         Seed database with initial data"
	@echo "  make docker-db-shell        Connect to PostgreSQL shell"
	@echo ""
	@echo "Cleanup:"
	@echo "  make docker-clean           Stop services and remove volumes"
	@echo "  make docker-clean-build     Clean build cache and volumes"

docker-build:
	docker-compose build

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

docker-logs-api:
	docker-compose logs -f api

docker-logs-website:
	docker-compose logs -f website

docker-logs-operator:
	docker-compose logs -f operator

docker-logs-tenant:
	docker-compose logs -f tenant

docker-logs-db:
	docker-compose logs -f postgres

docker-ps:
	docker-compose ps

docker-db-migrate:
	docker-compose exec api pnpm --filter @addmin/db db:migrate:dev

docker-db-seed:
	docker-compose exec api pnpm --filter @addmin/db seed

docker-db-shell:
	docker-compose exec postgres psql -U postgres -d addmin

docker-clean:
	docker-compose down -v

docker-clean-build:
	docker-compose down -v --remove-orphans
	docker system prune -f

docker-restart:
	docker-compose restart

docker-restart-api:
	docker-compose restart api

docker-shell-api:
	docker-compose exec api /bin/sh

docker-shell-website:
	docker-compose exec website /bin/sh

docker-shell-operator:
	docker-compose exec operator /bin/sh

docker-shell-tenant:
	docker-compose exec tenant /bin/sh
