#!/bin/bash

# Test script for small PDF processing
# This creates a very small PDF chunk to test the system

set -e

PDF_PATH="/Users/rahilsheth/Downloads/Math 4242/Applied Linear Algebra.pdf"
TEST_DIR="./test_chunks"
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

print_status "Creating a small test PDF chunk (pages 1-5)..."

# Create a very small chunk - just 5 pages
pdftk "$PDF_PATH" cat 1-5 output "$TEST_DIR/test_chunk_5pages.pdf"

CHUNK_SIZE=$(du -m "$TEST_DIR/test_chunk_5pages.pdf" | cut -f1)
print_success "Created test chunk: test_chunk_5pages.pdf (${CHUNK_SIZE}MB)"

# Start application with moderate memory
print_status "Starting application..."
MAVEN_OPTS="-Xmx2g -Xms1g" mvn spring-boot:run > app_test.log 2>&1 &
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

# Test upload
print_status "Testing upload with small chunk..."
UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@$TEST_DIR/test_chunk_5pages.pdf" "$APP_URL/api/v1/upload")

if echo "$UPLOAD_RESPONSE" | grep -q '"success":true'; then
    DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)
    print_success "Upload successful! Document ID: $DOC_ID"
    
    # Wait for processing
    print_status "Waiting for processing..."
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
                    print_error "Processing timeout"
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

print_status "Test completed. Check app_test.log for application logs."
