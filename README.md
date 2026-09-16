# AddMin - Office Administration Management SaaS

A modern, AI-friendly monorepo for managing office administration processes including utilities, compliance, lease, facilities, and assets.

## Tech Stack

- **Monorepo Tool:** Turborepo
- **Package Manager:** pnpm
- **Frontend:** Next.js (App Router) + React 19
- **Backend:** Node.js (Express)
- **Database:** PostgreSQL + Prisma ORM
- **Auth:** NextAuth.js
- **Testing:** Vitest + Playwright
- **Styling:** Tailwind CSS

## Project Structure

```
addmin/
├── apps/
│   ├── website/              # Marketing site (port 3000)
│   ├── operator/             # Admin control plane (port 3001)
│   └── tenant/               # Product app (port 3002)
├── services/
│   └── api/                  # Backend API (port 4000)
├── packages/
│   ├── db/                   # Prisma schema & migrations
│   ├── types/                # Shared TypeScript types
│   ├── auth/                 # NextAuth configuration
│   ├── utils/                # Helpers (RLS, validation, formatting)
│   └── testing/              # Test factories & mocks
├── turbo.json                # Turborepo config
├── pnpm-workspace.yaml       # pnpm workspaces
└── .env.local                # Environment variables
```

## Getting Started

### Prerequisites

#### Option 1: Docker (Recommended)
- Docker Desktop 4.0+
- 4GB+ RAM
- Works on macOS, Linux, Windows (WSL2)

#### Option 2: Local Development
- Node.js 18+
- pnpm 9.0+
- PostgreSQL 14+

### Installation with Docker

**Fastest way to get started:**

```bash
# Start all services (database, API, apps)
docker-compose up -d

# Run database migrations
make docker-db-migrate

# Access the apps
# Website: http://localhost:3000
# Operator: http://localhost:3001
# Tenant: http://localhost:3002
```

See [DOCKER.md](./DOCKER.md) for complete Docker setup guide.

### Installation Local

1. **Install dependencies:**
   ```bash
   pnpm install
   ```

2. **Setup environment:**
   ```bash
   cp .env.local.example .env.local
   # Edit .env.local with your database URL and secrets
   ```

3. **Setup database:**
   ```bash
   cd packages/db
   pnpm db:migrate:dev
   ```

4. **Start dev servers:**
   ```bash
   pnpm dev
   ```

   This starts all apps in parallel:
   - Website: http://localhost:3000
   - Operator: http://localhost:3001
   - Tenant: http://localhost:3002
   - API: http://localhost:4000

## Available Commands

### Root Level

```bash
pnpm dev                 # Start all dev servers
pnpm build              # Build all apps
pnpm test               # Run tests
pnpm lint               # Lint all apps
pnpm type-check         # TypeScript type checking
```

### Database

```bash
cd packages/db
pnpm db:migrate:dev     # Run migrations in dev
pnpm db:generate        # Generate Prisma client
```

### Individual Apps

```bash
cd apps/website
pnpm dev                # Start website dev server
pnpm build              # Build website
```

## Database Schema

The Prisma schema in `packages/db/prisma/schema.prisma` includes:

- **Organization & Office:** Company hierarchy
- **Users & Roles:** RBAC with office scope
- **Utilities & Bills:** Electricity, water, gas, internet billing workflows
- **Lease & Landlord:** Property ownership and lease terms
- **Compliance:** Certificate tracking with expiry alerts
- **Assets:** IT, furniture, equipment inventory
- **Facilities & Maintenance:** Cleaning, AC, DG, UPS management
- **Vendors:** Service providers and AMC tracking
- **Workflows:** Approval pipeline (Maker → Checker → Authorizer)

## Architecture Decisions

- **Shared Database with RLS:** Single PostgreSQL with row-level security policies enforce office-level data isolation
- **Monorepo:** Turborepo enables fast builds with caching and parallel execution
- **P0 Only in MVP:** Core features only; P1 (Payment gateway, Finance integration) deferred
- **India-First Defaults:** Hardcoded compliance types (Trade Licence, Fire NOC, etc.)

## Release Cycles

**Cycle 1 (Weeks 1-2):** Foundation + Onboarding
- Organization setup, office creation, role management

**Cycle 2 (Weeks 3-4):** Utility Core
- Utilities, bills, approval workflow, payments

**Cycle 3 (Weeks 5-6):** Lease + Compliance + Reports
- Property, lease, compliance register, dashboards

**Cycle 4 (Weeks 7-8):** Assets + Facilities + Launch
- Assets, facilities, maintenance, full product launch

## Development Workflow

1. Create a feature branch
2. Make changes across apps/packages as needed
3. Run `pnpm build` and `pnpm test` to verify
4. Create a PR for review

Turborepo caches builds, so subsequent builds are faster.

## Contributing

- Follow TypeScript strict mode
- Write tests for new features
- Validate input with Zod schemas
- Use shared utilities from `packages/`
- Keep shared types in `packages/types`

## Documentation

- Feature plan: `docs/addmin-feature-plan.export.html`
- Database schema: `packages/db/prisma/schema.prisma`
- API routes: `services/api/src/routes/`

## License

Proprietary - AddMin SaaS Platform
