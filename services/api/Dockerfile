FROM node:20-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@9

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copy packages and services
COPY packages ./packages
COPY services/api ./services/api

# Install dependencies
RUN pnpm install --frozen-lockfile

# Generate Prisma client
RUN pnpm --filter @addmin/db generate

# Expose port
EXPOSE 3001

# Default command (can be overridden by docker-compose)
CMD ["pnpm", "--filter", "@addmin/api", "dev"]
