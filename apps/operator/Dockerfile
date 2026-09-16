FROM node:20-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@9

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copy apps and packages
COPY apps/operator ./apps/operator
COPY packages ./packages

# Install dependencies
RUN pnpm install --frozen-lockfile

# Expose port
EXPOSE 3001

# Default command (can be overridden by docker-compose)
CMD ["pnpm", "--filter", "@addmin/operator", "dev", "--", "-p", "3001"]
