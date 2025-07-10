#!/bin/bash

# Setup Local Environment Script
# This script helps set up the local environment for development

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if .env.local exists
if [ -f "../../.env" ]; then
    print_warning ".env already exists. Backing up to .env.backup"
    cp ../../.env ../../.env.backup
fi

# Create .env.local with unset DATABASE_URL
print_status "Creating .env.local with unset DATABASE_URL for local development..."
cat > ../../.env << EOF
# Local Development Database (Docker)
# DATABASE_URL is intentionally unset for local development
# The application will use the default local database configuration

# Add your other environment variables below
# Copy from your existing .env file if needed
EOF

print_success ".env.local created successfully!"
print_status "You can now start the database with: ./dev-db.sh start"
print_status "Then push your schema with: ./dev-db.sh prisma db push"
