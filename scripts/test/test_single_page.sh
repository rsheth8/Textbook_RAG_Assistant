#!/bin/bash

# Test script for single page PDF processing
# This creates a single page PDF to test the system

set -e

PDF_PATH="/Users/rahilsheth/Downloads/Math 4242/Applied Linear Algebra.pdf"
TEST_DIR="./test_single_page"
APP_URL="http://localhost:8080"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create test directory
mkdir -p "$TEST_DIR"

print_status "Creating a single page test PDF..."

# Create a single page chunk
pdftk "$PDF_PATH" cat 1-1 output "$TEST_DIR/test_single_page.pdf"

CHUNK_SIZE=$(du -k "$TEST_DIR/test_single_page.pdf" | cut -f1)
print_success "Created test chunk: test_single_page.pdf (${CHUNK_SIZE}KB)"

# Start application with minimal memory
print_status "Starting application..."
MAVEN_OPTS="-Xmx1g -Xms512m" mvn spring-boot:run > app_single.log 2>&1 &
APP_PID=$!

print_status "Application starting (PID: $APP_PID)..."

# Wait for application to start
for i in {1..60}; do
    if curl -s "$APP_URL/api/v1/health" > /dev/null 2>&1; then
        print_success "Application started successfully!"
        break
    fi
    if [ $i -eq 60 ]; then
        print_error "Application failed to start within 60 seconds"
        exit 1
    fi
    sleep 1
done

# Test upload with timeout
print_status "Testing upload with single page (timeout: 30 seconds)..."
UPLOAD_RESPONSE=$(timeout 30 curl -s -X POST -F "file=@$TEST_DIR/test_single_page.pdf" "$APP_URL/api/v1/upload")

if [ $? -eq 124 ]; then
    print_error "Upload timed out after 30 seconds"
    exit 1
fi

if echo "$UPLOAD_RESPONSE" | grep -q '"success":true'; then
    DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)
    print_success "Upload successful! Document ID: $DOC_ID"
    
    # Wait for processing with timeout
    print_status "Waiting for processing (timeout: 60 seconds)..."
    for i in {1..60}; do
        STATUS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents/$DOC_ID")
        STATUS=$(echo "$STATUS_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        
        case $STATUS in
            "COMPLETED")
                print_success "Processing completed successfully!"
                break
                ;;
            "FAILED")
                ERROR_MSG=$(echo "$STATUS_RESPONSE" | grep -o '"errorMessage":"[^"]*"' | cut -d'"' -f4)
                print_error "Processing failed: $ERROR_MSG"
                break
                ;;
            *)
                if [ $i -eq 60 ]; then
                    print_error "Processing timeout after 60 seconds"
                else
                    sleep 2
                fi
                ;;
        esac
    done
else
    ERROR_MSG=$(echo "$UPLOAD_RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
    print_error "Upload failed: $ERROR_MSG"
fi

print_status "Test completed. Check app_single.log for application logs."
