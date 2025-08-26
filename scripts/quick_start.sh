#!/bin/bash

# 📚 Textbook Assistant - Quick Start Script
# This script helps you get the system up and running quickly

set -e

echo "🚀 Textbook Assistant - Quick Start"
echo "=================================="

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

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Java
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed. Please install Java 17 or higher."
        exit 1
    fi
    
    # Check Maven
    if ! command -v mvn &> /dev/null; then
        print_error "Maven is not installed. Please install Maven 3.6+."
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker."
        exit 1
    fi
    
    # Check Ollama
    if ! command -v ollama &> /dev/null; then
        print_error "Ollama is not installed. Please install Ollama."
        exit 1
    fi
    
    print_success "All prerequisites are installed!"
}

# Setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    # Copy environment template if .env doesn't exist
    if [ ! -f .env ]; then
        if [ -f env.example ]; then
            cp env.example .env
            print_success "Created .env file from template"
        else
            print_warning "No env.example found. You may need to create .env manually."
        fi
    else
        print_success ".env file already exists"
    fi
}

# Start database
start_database() {
    print_status "Starting PostgreSQL database..."
    
    # Stop any existing containers
    docker-compose down postgres 2>/dev/null || true
    
    # Start database
    docker-compose up -d postgres
    
    # Wait for database to be ready
    print_status "Waiting for database to be ready..."
    sleep 10
    
    print_success "Database is running!"
}

# Check Ollama models
check_ollama_models() {
    print_status "Checking Ollama models..."
    
    # Check if llama2 is available
    if ! ollama list | grep -q "llama2"; then
        print_warning "llama2 model not found. Installing..."
        ollama pull llama2
    fi
    
    # Check if nomic-embed-text is available
    if ! ollama list | grep -q "nomic-embed-text"; then
        print_warning "nomic-embed-text model not found. Installing..."
        ollama pull nomic-embed-text
    fi
    
    print_success "Ollama models are ready!"
}

# Build application
build_application() {
    print_status "Building application..."
    
    mvn clean package -DskipTests
    
    print_success "Application built successfully!"
}

# Start application
start_application() {
    print_status "Starting application..."
    
    # Kill any existing process on port 8080
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    
    # Start with increased memory
    export MAVEN_OPTS="-Xmx8g -Xms4g"
    mvn spring-boot:run > scripts/logs/app_quick_start.log 2>&1 &
    
    # Wait for application to start
    print_status "Waiting for application to start..."
    sleep 20
    
    # Check if application is running
    if curl -s http://localhost:8080/api/v1/health > /dev/null; then
        print_success "Application is running!"
        print_success "Web Interface: http://localhost:8080"
        print_success "Health Check: http://localhost:8080/api/v1/health"
    else
        print_error "Application failed to start. Check logs: scripts/logs/app_quick_start.log"
        exit 1
    fi
}

# Main execution
main() {
    echo ""
    print_status "Starting Textbook Assistant setup..."
    echo ""
    
    check_prerequisites
    setup_environment
    start_database
    check_ollama_models
    build_application
    start_application
    
    echo ""
    print_success "🎉 Textbook Assistant is ready!"
    echo ""
    echo "📚 Next steps:"
    echo "1. Open http://localhost:8080 in your browser"
    echo "2. Upload your textbook PDF"
    echo "3. Start asking questions!"
    echo ""
    echo "📖 For more information, see docs/README.md"
    echo "🛠️  For troubleshooting, see scripts/logs/"
    echo ""
}

# Run main function
main "$@"
