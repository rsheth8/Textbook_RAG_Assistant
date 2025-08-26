#!/bin/bash

# Test script for basic upload functionality
# This tests just the upload without RAG processing

set -e

TEST_DIR="./test_basic"
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

print_status "Creating a simple text file for basic upload test..."

# Create a very simple text file
cat > "$TEST_DIR/simple.txt" << 'EOF'
This is a simple test file.
It contains basic text content.
No complex formatting or large amounts of data.
EOF

FILE_SIZE=$(du -k "$TEST_DIR/simple.txt" | cut -f1)
print_success "Created text file: simple.txt (${FILE_SIZE}KB)"

# Start application with minimal memory
print_status "Starting application..."
MAVEN_OPTS="-Xmx1g -Xms512m" mvn spring-boot:run > app_basic.log 2>&1 &
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
print_status "Testing basic upload (timeout: 30 seconds)..."
UPLOAD_RESPONSE=$(timeout 30 curl -s -X POST -F "file=@$TEST_DIR/simple.txt" "$APP_URL/api/v1/upload")

if [ $? -eq 124 ]; then
    print_error "Upload timed out after 30 seconds"
    exit 1
fi

echo "Upload response: $UPLOAD_RESPONSE"

if echo "$UPLOAD_RESPONSE" | grep -q '"documentId"'; then
    DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)
    print_success "Upload successful! Document ID: $DOC_ID"
    
    # Check document status
    print_status "Checking document status..."
    STATUS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents/$DOC_ID")
    echo "Status response: $STATUS_RESPONSE"
    
else
    print_error "Upload failed: Invalid response format"
fi

print_status "Test completed. Check app_basic.log for application logs."
