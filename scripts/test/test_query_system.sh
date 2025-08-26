#!/bin/bash

# Test script for query system
# This tests queries with existing documents

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
MAVEN_OPTS="-Xmx4g -Xms2g" mvn spring-boot:run > app_query.log 2>&1 &
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

# Test 1: List all documents
print_status "Test 1: Listing all documents..."
DOCUMENTS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents")
DOC_COUNT=$(echo "$DOCUMENTS_RESPONSE" | grep -o '"id":[0-9]*' | wc -l)
print_success "Found $DOC_COUNT documents in database"

# Get the first document ID for testing
FIRST_DOC_ID=$(echo "$DOCUMENTS_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
if [ -n "$FIRST_DOC_ID" ]; then
    print_success "Using document ID $FIRST_DOC_ID for testing"
else
    print_error "No documents found for testing"
    exit 1
fi

# Test 2: Test a simple query
print_status "Test 2: Testing simple query..."
QUERY_REQUEST='{
    "query": "What is linear algebra?",
    "documentId": '$FIRST_DOC_ID',
    "learningLevel": "beginner",
    "responseType": "explanation"
}'

QUERY_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "$QUERY_REQUEST" "$APP_URL/api/v1/query")

echo "Query Response: $QUERY_RESPONSE"

if echo "$QUERY_RESPONSE" | grep -q '"answer"'; then
    ANSWER=$(echo "$QUERY_RESPONSE" | grep -o '"answer":"[^"]*"' | cut -d'"' -f4)
    print_success "Query successful! Answer: $ANSWER"
else
    print_error "Query failed or returned no answer"
fi

# Test 3: Test another query
print_status "Test 3: Testing matrix query..."
QUERY_REQUEST2='{
    "query": "What is a matrix?",
    "documentId": '$FIRST_DOC_ID',
    "learningLevel": "beginner",
    "responseType": "explanation"
}'

QUERY_RESPONSE2=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "$QUERY_REQUEST2" "$APP_URL/api/v1/query")

echo "Query Response 2: $QUERY_RESPONSE2"

if echo "$QUERY_RESPONSE2" | grep -q '"answer"'; then
    ANSWER2=$(echo "$QUERY_RESPONSE2" | grep -o '"answer":"[^"]*"' | cut -d'"' -f4)
    print_success "Query 2 successful! Answer: $ANSWER2"
else
    print_error "Query 2 failed or returned no answer"
fi

print_status "Query testing completed. Check app_query.log for detailed logs."
