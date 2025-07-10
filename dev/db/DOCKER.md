# Docker PostgreSQL Setup for Creole Creamery Scraper

This guide covers setting up a local PostgreSQL database using Docker for the Creole Creamery Hall of Fame scraper project.

## Prerequisites

- Docker and Docker Compose installed
- Python 3.11+ and Poetry installed
- Access to the project directory

## Quick Setup

### 1. Start the Database

```bash
# Navigate to the docker-compose directory
cd db/dev_db

# Start the PostgreSQL container
docker-compose up -d

# Verify it's running
docker ps
```

### 2. Configure Environment Variables

Make sure your `.env` file has the correct `NEON_DATABASE_URL` for local development:

```env
# For local development with Docker PostgreSQL
NEON_DATABASE_URL="postgresql://postgres:postgres@localhost:5433/creole_creamery_hof"
OPENAI_API_KEY=sk-your-openai-api-key-here
AWS_REGION=us-east-1
FUNCTION_NAME=creole-creamery-scraper
```

### 3. Initialize the Database

```bash
# Run the database initialization script
python -c "
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

# Connect to PostgreSQL server
conn = psycopg2.connect(
    host='localhost',
    port=5433,
    user='postgres',
    password='postgres'
)
conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
cursor = conn.cursor()

# Create database if it doesn't exist
cursor.execute('CREATE DATABASE creole_creamery_hof')
cursor.close()
conn.close()
print('Database creole_creamery_hof created successfully')
"

# Create the hall_of_fame_entries table
python -c "
import psycopg2

conn = psycopg2.connect(
    host='localhost',
    port=5433,
    user='postgres',
    password='postgres',
    database='creole_creamery_hof'
)
cursor = conn.cursor()

# Create the table
cursor.execute('''
    CREATE TABLE IF NOT EXISTS hall_of_fame_entries (
        id SERIAL PRIMARY KEY,
        participant_number INTEGER UNIQUE NOT NULL,
        name VARCHAR(255) NOT NULL,
        date_str VARCHAR(50) NOT NULL,
        parsed_date TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
''')

conn.commit()
cursor.close()
conn.close()
print('Table hall_of_fame_entries created successfully')
"
```

### 4. Verify Connection

```bash
# Test the connection with a simple query
python -c "
import psycopg2

conn = psycopg2.connect(
    host='localhost',
    port=5433,
    user='postgres',
    password='postgres',
    database='creole_creamery_hof'
)
cursor = conn.cursor()

cursor.execute('SELECT COUNT(*) FROM hall_of_fame_entries')
count = cursor.fetchone()[0]
print(f'Hall of Fame entries in database: {count}')

cursor.close()
conn.close()
"
```

## Docker Configuration

The Docker setup uses the official pgvector image with PostgreSQL 16:

```yaml
# docker-compose.yml
version: "3.8"

services:
  postgres:
    image: pgvector/pgvector:pg16
    container_name: creole-creamery-hall-of-fame-db
    environment:
      POSTGRES_DB: creole_creamery_hof
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d creole_creamery_hof"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

## Database Connection Details

- **Host**: localhost
- **Port**: 5433 (mapped from container port 5432)
- **Database**: creole_creamery_hof
- **Username**: postgres
- **Password**: postgres
- **Connection String**: `postgresql://postgres:postgres@localhost:5433/creole_creamery_hof`

## Database Schema

The scraper uses the following table structure:

```sql
CREATE TABLE hall_of_fame_entries (
    id SERIAL PRIMARY KEY,
    participant_number INTEGER UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    date_str VARCHAR(50) NOT NULL,
    parsed_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Troubleshooting

### Connection Issues

1. **Check if Docker container is running:**

   ```bash
   docker ps | grep creole-creamery-hall-of-fame-db
   ```

2. **Check container logs:**

   ```bash
   docker logs creole-creamery-hall-of-fame-db
   ```

3. **Restart the container:**
   ```bash
   docker-compose restart
   ```

### Environment Variable Issues

1. **Clear shell environment variables:**

   ```bash
   unset NEON_DATABASE_URL
   ```

2. **Verify .env file is loaded:**

   ```bash
   python -c "import os; from dotenv import load_dotenv; load_dotenv(); print(os.getenv('NEON_DATABASE_URL'))"
   ```

3. **Restart your development server:**
   ```bash
   poetry run python test_scraper.py
   ```

### Database Schema Issues

1. **Reset the database:**

   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

2. **Recreate the table:**

   ```bash
   # Run the initialization script again
   python -c "
   import psycopg2

   conn = psycopg2.connect(
       host='localhost',
       port=5433,
       user='postgres',
       password='postgres',
       database='creole_creamery_hof'
   )
   cursor = conn.cursor()

   cursor.execute('DROP TABLE IF EXISTS hall_of_fame_entries')
   cursor.execute('''
       CREATE TABLE hall_of_fame_entries (
           id SERIAL PRIMARY KEY,
           participant_number INTEGER UNIQUE NOT NULL,
           name VARCHAR(255) NOT NULL,
           date_str VARCHAR(50) NOT NULL,
           parsed_date TIMESTAMP NOT NULL,
           created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
           updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
       );
   ''')

   conn.commit()
   cursor.close()
   conn.close()
   print('Table recreated successfully')
   "
   ```

## Development Workflow

1. **Start the database:**

   ```bash
   cd db/dev_db
   docker-compose up -d
   ```

2. **Set up environment variables:**

   ```bash
   # Copy example environment file
   cp ../../terraform/terraform.tfvars.example ../../.env

   # Edit .env with local database URL
   # NEON_DATABASE_URL="postgresql://postgres:postgres@localhost:5433/creole_creamery_hof"
   ```

3. **Test the scraper locally:**

   ```bash
   cd ../..
   poetry shell
   python test_scraper.py
   ```

4. **View data in the database:**

   ```bash
   # Connect to database
   psql "postgresql://postgres:postgres@localhost:5433/creole_creamery_hof"

   # View entries
   SELECT * FROM hall_of_fame_entries ORDER BY created_at DESC LIMIT 10;
   ```

## Production Considerations

For production deployment:

1. Use Neon PostgreSQL or another managed PostgreSQL service
2. Implement proper backup strategies
3. Set up connection pooling for better performance
4. Use environment-specific connection strings
5. Consider using pgvector for future vector search capabilities

## Local Testing with Docker

Test the scraper with the local Docker database:

```bash
# Start the database
cd db/dev_db
docker-compose up -d

# Set environment to use local database
export NEON_DATABASE_URL="postgresql://postgres:postgres@localhost:5433/creole_creamery_hof"

# Run the scraper
cd ../..
poetry shell
python test_scraper.py
```

## Useful Commands

```bash
# Start database
cd db/dev_db && docker-compose up -d

# Stop database
cd db/dev_db && docker-compose down

# View logs
cd db/dev_db && docker-compose logs -f

# Connect to database
psql "postgresql://postgres:postgres@localhost:5433/creole_creamery_hof"

# Reset database
cd db/dev_db && docker-compose down -v && docker-compose up -d

# Test scraper locally
poetry shell && python test_scraper.py

# View recent entries
psql "postgresql://postgres:postgres@localhost:5433/creole_creamery_hof" -c "SELECT * FROM hall_of_fame_entries ORDER BY created_at DESC LIMIT 5;"
```
