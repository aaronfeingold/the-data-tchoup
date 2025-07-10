# Local Development Setup

This guide explains how to set up your local development environment using the provided scripts.

## Scripts Overview

### `setup-local-env.sh`

**When to run:** Once when setting up your development environment for the first time, or when you need to reset your local environment configuration.

**What it does:**

- Creates a `.env` file in the project roots
- Intentionally **unsets** the `NEON_DATABASE_URL` environment variable to allow the application to use its default local database configuration
- Backs up any existing `.env.local` file to `.env.local.backup` before creating a new one
- Provides colored output to indicate success/warning states

**Why unset NEON_DATABASE_URL?**
The application is designed to work with a local database configuration when `NEON_DATABASE_URL` is not set. This allows for easier local development without hardcoding database connection strings.

### `dev-db.sh`

**When to run:** Whenever you need to manage your local PostgreSQL database container.

**What it does:**

- Manages a PostgreSQL database container using Docker Compose
- Provides commands to start, stop, restart, and reset the database
- Includes Prisma integration for database schema management
- Offers status checking and log viewing capabilities

## Setup Workflow

### 1. Initial Setup (First Time)

```bash
# 1. Set up your local environment configuration
./setup-local-env.sh

# 2. Start the local database
./dev-db.sh start

# 3. Push your Prisma schema to the database
./dev-db.sh prisma db push
```

### 2. Daily Development Workflow

```bash
# Start the database (if not already running)
./dev-db.sh start

# Check database status
./dev-db.sh status

# Run your application...
# (Your app will automatically connect to the local database)

# When done developing
./dev-db.sh stop
```

## Available Commands

### `dev-db.sh` Commands

| Command            | Description                                                     |
| ------------------ | --------------------------------------------------------------- |
| `start`            | Start the PostgreSQL container                                  |
| `stop`             | Stop the PostgreSQL container                                   |
| `restart`          | Restart the PostgreSQL container                                |
| `reset`            | Reset the database (delete all data)                            |
| `status`           | Show database status                                            |
| `prisma <command>` | Run Prisma commands (e.g., `prisma generate`, `prisma db push`) |
| `logs`             | Show database logs                                              |
| `help`             | Show help message                                               |

### Common Prisma Commands

```bash
# Generate Prisma client
./dev-db.sh prisma generate

# Push schema changes to database
./dev-db.sh prisma db push

# Open Prisma Studio (database GUI)
./dev-db.sh prisma studio

# Run migrations
./dev-db.sh prisma migrate dev
```

## Database Configuration

The local database runs with these settings:

- **Host:** localhost
- **Port:** 5433 (mapped from container port 5432)
- **Database:** exclaim_recovery
- **Username:** postgres
- **Password:** postgres
- **Image:** pgvector/pgvector:pg16 (PostgreSQL 16 with vector extensions)

## Troubleshooting

### Database won't start

1. Ensure Docker is running
2. Check if port 5433 is available: `lsof -i :5433`
3. Try resetting the database: `./dev-db.sh reset`

### Connection issues

1. Verify the database is running: `./dev-db.sh status`
2. Check the logs: `./dev-db.sh logs`
3. Ensure your application is configured to use the local database when `NEON_DATABASE_URL` is not set

### Prisma issues

1. Generate the client: `./dev-db.sh prisma generate`
2. Push schema changes: `./dev-db.sh prisma db push`
3. Check for migration conflicts: `./dev-db.sh prisma migrate status`

## File Structure

```
.
├── setup-local-env.sh    # Environment setup script
├── dev-db.sh            # Database management script
├── docker-compose.yml   # Docker Compose configuration
├── init.sql            # Database initialization script
└── ../dan/.env.local   # Local environment file (created by setup-local-env.sh)
```

## Notes

- The database data is persisted in a Docker volume, so your data will survive container restarts
- The `init.sql` script runs automatically when the database is first created
- The database uses the pgvector extension for vector operations
- All database operations are isolated to your local development environment
