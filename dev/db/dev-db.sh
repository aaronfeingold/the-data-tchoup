#!/bin/bash

# Creole Creamery Development Database Management Script
# This script helps manage the local PostgreSQL container for development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to start the database
start_db() {
    print_status "Starting PostgreSQL container for Creole Creamery Hall of Fame..."
    docker-compose up -d postgres

    print_status "Waiting for database to be ready..."
    until docker-compose exec -T postgres pg_isready -U postgres -d creole_creamery_hof; do
        sleep 2
    done

    print_success "PostgreSQL is ready!"
    print_status "Database URL: postgresql://postgres:postgres@localhost:5433/creole_creamery_hof"
    print_status "Container: creole-creamery-hall-of-fame-db"
}

# Function to stop the database
stop_db() {
    print_status "Stopping PostgreSQL container..."
    docker-compose down
    print_success "PostgreSQL stopped!"
}

# Function to reset the database
reset_db() {
    print_warning "This will delete all data in the local Creole Creamery Hall of Fame database!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping and removing containers..."
        docker-compose down -v
        print_status "Starting fresh database..."
        start_db
        print_success "Database reset complete!"
    else
        print_status "Reset cancelled."
    fi
}

# Function to show database status
status_db() {
    if docker-compose ps postgres | grep -q "Up"; then
        print_success "PostgreSQL is running"
        print_status "Connection: postgresql://postgres:postgres@localhost:5433/creole_creamery_hof"
        print_status "Container: creole-creamery-hall-of-fame-db"
    else
        print_warning "PostgreSQL is not running"
    fi
}

# Function to run database migrations
run_migrations() {
    print_status "Running database migrations..."
    # Add migration commands here when you have them
    # For now, the schema is created by the application
    print_success "Migrations completed!"
}

# Function to connect to database
connect_db() {
    print_status "Connecting to PostgreSQL database..."
    docker-compose exec postgres psql -U postgres -d creole_creamery_hof
}

# Function to show logs
logs_db() {
    docker-compose logs -f postgres
}

# Function to backup database
backup_db() {
    local backup_file="creole_creamery_hof_backup_$(date +%Y%m%d_%H%M%S).sql"
    print_status "Creating backup: $backup_file"
    docker-compose exec -T postgres pg_dump -U postgres -d creole_creamery_hof > "$backup_file"
    print_success "Backup created: $backup_file"
}

# Function to restore database
restore_db() {
    if [ -z "$1" ]; then
        print_error "Please specify a backup file to restore from"
        echo "Usage: $0 restore <backup_file.sql>"
        exit 1
    fi

    local backup_file="$1"
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        exit 1
    fi

    print_warning "This will overwrite the current database with data from $backup_file"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restoring database from $backup_file..."
        docker-compose exec -T postgres psql -U postgres -d creole_creamery_hof < "$backup_file"
        print_success "Database restored from $backup_file"
    else
        print_status "Restore cancelled."
    fi
}

# Main script logic
case "$1" in
    "start")
        check_docker
        start_db
        ;;
    "stop")
        stop_db
        ;;
    "restart")
        stop_db
        start_db
        ;;
    "reset")
        check_docker
        reset_db
        ;;
    "status")
        status_db
        ;;
    "migrate")
        run_migrations
        ;;
    "connect")
        connect_db
        ;;
    "logs")
        logs_db
        ;;
    "backup")
        backup_db
        ;;
    "restore")
        shift
        restore_db "$@"
        ;;
    "help"|"--help"|"-h"|"")
        echo "Creole Creamery Development Database Management Script"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  start     Start the PostgreSQL container"
        echo "  stop      Stop the PostgreSQL container"
        echo "  restart   Restart the PostgreSQL container"
        echo "  reset     Reset the database (delete all data)"
        echo "  status    Show database status"
        echo "  migrate   Run database migrations"
        echo "  connect   Connect to database with psql"
        echo "  logs      Show database logs"
        echo "  backup    Create a database backup"
        echo "  restore   Restore database from backup file"
        echo "  help      Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 start                    # Start the database"
        echo "  $0 connect                  # Connect to database"
        echo "  $0 backup                   # Create backup"
        echo "  $0 restore backup.sql       # Restore from backup"
        echo ""
        echo "Database Details:"
        echo "  Name: creole_creamery_hof"
        echo "  Container: creole-creamery-hall-of-fame-db"
        echo "  Port: 5433"
        echo "  User: postgres"
        echo "  Password: postgres"
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Run '$0 help' for usage information."
        exit 1
        ;;
esac
