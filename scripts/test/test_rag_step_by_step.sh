#!/bin/bash

# Step-by-step RAG testing script
# This tests each component of RAG processing separately

set -e

APP_URL="http://localhost:8080"
TEST_DIR="./test_rag_debug"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Create test directory
mkdir -p "$TEST_DIR"

print_status "Creating test files..."

# Create a very simple test file
cat > "$TEST_DIR/simple_test.txt" << 'EOF'
A matrix is a rectangular array of numbers.
Linear algebra deals with matrices and vectors.
Vectors are one-dimensional arrays.
EOF

print_success "Created test file: simple_test.txt"

# Start application
print_status "Starting application..."
MAVEN_OPTS="-Xmx4g -Xms2g" mvn spring-boot:run > app_debug.log 2>&1 &
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

# Test 1: Basic upload without RAG
print_status "Test 1: Basic upload (RAG disabled)..."
UPLOAD_RESPONSE=$(timeout 30 curl -s -X POST -F "file=@$TEST_DIR/simple_test.txt" "$APP_URL/api/v1/upload")

if [ $? -eq 124 ]; then
    print_error "Upload timed out"
    exit 1
fi

if echo "$UPLOAD_RESPONSE" | grep -q '"documentId"'; then
    DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)
    print_success "Upload successful! Document ID: $DOC_ID"
    
    # Check document status
    sleep 2
    STATUS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents/$DOC_ID")
    STATUS=$(echo "$STATUS_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$STATUS" = "COMPLETED" ]; then
        print_success "Document processing completed"
        
        # Check if text was extracted
        EXTRACTED_TEXT=$(echo "$STATUS_RESPONSE" | grep -o '"extractedText":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$EXTRACTED_TEXT" ]; then
            print_success "Text extraction working: ${#EXTRACTED_TEXT} characters"
        else
            print_error "Text extraction failed"
        fi
    else
        print_error "Document processing failed: $STATUS"
    fi
else
    print_error "Upload failed"
    exit 1
fi

# Test 2: Check if Ollama is working
print_status "Test 2: Testing Ollama embedding service..."
EMBEDDING_RESPONSE=$(timeout 30 curl -s -X POST -H "Content-Type: application/json" \
    -d '{"model":"nomic-embed-text","prompt":"test"}' http://localhost:11434/api/embeddings)

if [ $? -eq 124 ]; then
    print_error "Ollama embedding request timed out"
else
    if echo "$EMBEDDING_RESPONSE" | grep -q '"embedding"'; then
        print_success "Ollama embedding service working"
    else
        print_error "Ollama embedding service failed"
    fi
fi

# Test 3: Check database for chunks
print_status "Test 3: Checking database for document chunks..."
CHUNKS_COUNT=$(curl -s "$APP_URL/api/v1/documents" | grep -o '"id":[0-9]*' | wc -l)
print_status "Total documents in database: $CHUNKS_COUNT"

print_status "Test completed. Check app_debug.log for detailed application logs."
