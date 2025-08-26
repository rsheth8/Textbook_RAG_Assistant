#!/bin/bash

# 🚀 Railway Deployment Script
# This script helps deploy your Textbook Assistant to Railway.app

set -e

echo "🚀 Railway Deployment Script"
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if Railway CLI is installed
check_railway_cli() {
    print_status "Checking Railway CLI..."
    
    if ! command -v railway &> /dev/null; then
        print_warning "Railway CLI not found. Installing..."
        npm install -g @railway/cli
    fi
    
    print_success "Railway CLI is ready!"
}

# Login to Railway
login_railway() {
    print_status "Logging into Railway..."
    
    if ! railway whoami &> /dev/null; then
        print_status "Please login to Railway..."
        railway login
    fi
    
    print_success "Logged into Railway!"
}

# Build the application
build_application() {
    print_status "Building application..."
    
    mvn clean package -DskipTests
    
    print_success "Application built successfully!"
}

# Deploy to Railway
deploy_to_railway() {
    print_status "Deploying to Railway..."
    
    # Check if project exists
    if ! railway project &> /dev/null; then
        print_status "Creating new Railway project..."
        railway init
    fi
    
    # Deploy
    railway up
    
    print_success "Deployment completed!"
}

# Get deployment URL
get_deployment_url() {
    print_status "Getting deployment URL..."
    
    local url=$(railway domain)
    if [ ! -z "$url" ]; then
        print_success "Your application is available at: https://$url"
        echo ""
        echo "🌐 Application URL: https://$url"
        echo "📊 Railway Dashboard: https://railway.app/dashboard"
        echo ""
    else
        print_warning "Could not get deployment URL. Check Railway dashboard."
    fi
}

# Main deployment process
main() {
    echo ""
    print_status "Starting Railway deployment..."
    echo ""
    
    check_railway_cli
    login_railway
    build_application
    deploy_to_railway
    get_deployment_url
    
    echo ""
    print_success "🎉 Deployment completed!"
    echo ""
    echo "📚 Next steps:"
    echo "1. Visit your Railway dashboard"
    echo "2. Add PostgreSQL database service"
    echo "3. Configure environment variables"
    echo "4. Add custom domain (optional)"
    echo ""
    echo "📖 For detailed instructions, see DEPLOYMENT_GUIDE.md"
    echo ""
}

# Run main function
main "$@"
