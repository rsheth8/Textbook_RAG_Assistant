#!/bin/bash

# Manual RAG testing script
# This creates chunks manually and tests queries

set -e

APP_URL="http://localhost:8080"

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

# Start application
print_status "Starting application..."
MAVEN_OPTS="-Xmx4g -Xms2g" mvn spring-boot:run > app_manual.log 2>&1 &
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

# Test 1: Create a simple document
print_status "Test 1: Creating a simple document..."
UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@./test_minimal/minimal.txt" "$APP_URL/api/v1/upload")

if echo "$UPLOAD_RESPONSE" | grep -q '"documentId"'; then
    DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)
    print_success "Document created with ID: $DOC_ID"
else
    print_error "Failed to create document"
    exit 1
fi

# Test 2: Manually create chunks using direct API calls
print_status "Test 2: Testing Ollama embedding service directly..."

# Test embedding generation
EMBEDDING_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"model":"nomic-embed-text","prompt":"A matrix is a rectangular array of numbers."}' \
    http://localhost:11434/api/embeddings)

if echo "$EMBEDDING_RESPONSE" | grep -q '"embedding"'; then
    print_success "Ollama embedding service working"
    
    # Extract embedding
    EMBEDDING=$(echo "$EMBEDDING_RESPONSE" | grep -o '"embedding":\[[^]]*\]' | sed 's/"embedding"://')
    print_success "Generated embedding with length: $(echo "$EMBEDDING" | jq 'length')"
else
    print_error "Ollama embedding service failed"
    exit 1
fi

# Test 3: Test Ollama chat service
print_status "Test 3: Testing Ollama chat service..."
CHAT_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"model":"llama2","prompt":"What is linear algebra?","stream":false}' \
    http://localhost:11434/api/generate)

if echo "$CHAT_RESPONSE" | grep -q '"response"'; then
    RESPONSE=$(echo "$CHAT_RESPONSE" | grep -o '"response":"[^"]*"' | cut -d'"' -f4)
    print_success "Ollama chat service working"
    print_status "Sample response: ${RESPONSE:0:100}..."
else
    print_error "Ollama chat service failed"
    exit 1
fi

# Test 4: Test a simple query (this will fail because no chunks exist, but we can see the error)
print_status "Test 4: Testing query system..."
QUERY_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"query\":\"What is linear algebra?\",\"documentId\":$DOC_ID,\"learningLevel\":\"beginner\",\"responseType\":\"explanation\"}" \
    "$APP_URL/api/v1/query")

echo "Query Response: $QUERY_RESPONSE"

if echo "$QUERY_RESPONSE" | grep -q '"answer"'; then
    ANSWER=$(echo "$QUERY_RESPONSE" | grep -o '"answer":"[^"]*"' | cut -d'"' -f4)
    if [[ "$ANSWER" == *"error"* ]] || [[ "$ANSWER" == *"Sorry"* ]]; then
        print_warning "Query returned error (expected since no chunks exist): $ANSWER"
    else
        print_success "Query successful: $ANSWER"
    fi
else
    print_error "Query failed"
fi

print_status "Manual RAG testing completed. Check app_manual.log for detailed logs."
print_status "Next step: Enable RAG processing to create chunks automatically."
