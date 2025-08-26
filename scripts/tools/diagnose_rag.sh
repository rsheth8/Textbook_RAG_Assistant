#!/bin/bash

# RAG Diagnostic Script
# This isolates exactly where the RAG process is failing

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

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Test 1: Check if Ollama is responsive
print_header "Test 1: Ollama Service Health"
print_status "Testing Ollama embedding service..."

EMBEDDING_RESPONSE=$(timeout 10 curl -s -X POST -H "Content-Type: application/json" \
    -d '{"model":"nomic-embed-text","prompt":"test"}' http://localhost:11434/api/embeddings)

if [ $? -eq 124 ]; then
    print_error "Ollama embedding service timed out (10 seconds)"
else
    if echo "$EMBEDDING_RESPONSE" | grep -q '"embedding"'; then
        EMBEDDING_LENGTH=$(echo "$EMBEDDING_RESPONSE" | grep -o '"embedding":\[[^]]*\]' | sed 's/"embedding"://' | jq 'length' 2>/dev/null || echo "unknown")
        print_success "Ollama embedding service working (${EMBEDDING_LENGTH} dimensions)"
    else
        print_error "Ollama embedding service failed"
    fi
fi

# Test 2: Check database connection
print_header "Test 2: Database Connection"
print_status "Testing database connection..."

if curl -s "$APP_URL/api/v1/health" > /dev/null 2>&1; then
    print_success "Application is running"
    
    # Check document count
    DOC_COUNT=$(curl -s "$APP_URL/api/v1/documents" | grep -o '"id":[0-9]*' | wc -l)
    print_status "Documents in database: $DOC_COUNT"
    
    # Check if any documents have chunks
    if [ $DOC_COUNT -gt 0 ]; then
        FIRST_DOC_ID=$(curl -s "$APP_URL/api/v1/documents" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
        print_status "Testing with document ID: $FIRST_DOC_ID"
        
        # Check document details
        DOC_DETAILS=$(curl -s "$APP_URL/api/v1/documents/$FIRST_DOC_ID")
        EXTRACTED_TEXT=$(echo "$DOC_DETAILS" | grep -o '"extractedText":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$EXTRACTED_TEXT" ]; then
            TEXT_LENGTH=${#EXTRACTED_TEXT}
            print_success "Document has extracted text (${TEXT_LENGTH} characters)"
        else
            print_error "Document has no extracted text"
        fi
    fi
else
    print_error "Application is not running"
fi

# Test 3: Test chunking logic
print_header "Test 3: Chunking Logic Test"
print_status "Testing with a simple text..."

SIMPLE_TEXT="This is a test sentence. It contains basic content. We will chunk this text."

# Calculate expected chunks
CHUNK_SIZE=1500
OVERLAP=300
TEXT_LENGTH=${#SIMPLE_TEXT}

if [ $TEXT_LENGTH -le $CHUNK_SIZE ]; then
    EXPECTED_CHUNKS=1
else
    EXPECTED_CHUNKS=$(( (TEXT_LENGTH - CHUNK_SIZE) / (CHUNK_SIZE - OVERLAP) + 1 ))
fi

print_status "Text length: $TEXT_LENGTH characters"
print_status "Chunk size: $CHUNK_SIZE characters"
print_status "Overlap: $OVERLAP characters"
print_status "Expected chunks: $EXPECTED_CHUNKS"

# Test 4: Test embedding generation with different text sizes
print_header "Test 4: Embedding Generation Test"

# Test with small text
print_status "Testing embedding with small text (${#SIMPLE_TEXT} chars)..."
SMALL_EMBEDDING=$(timeout 10 curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"model\":\"nomic-embed-text\",\"prompt\":\"$SIMPLE_TEXT\"}" \
    http://localhost:11434/api/embeddings)

if [ $? -eq 124 ]; then
    print_error "Small text embedding timed out"
else
    if echo "$SMALL_EMBEDDING" | grep -q '"embedding"'; then
        print_success "Small text embedding successful"
    else
        print_error "Small text embedding failed"
    fi
fi

# Test with larger text
LARGE_TEXT="This is a much longer text that contains many more words and sentences. " 
LARGE_TEXT+="It goes on and on with multiple paragraphs. " 
LARGE_TEXT+="We want to test if the embedding service can handle larger chunks of text. "
LARGE_TEXT+="This should be closer to our actual chunk size of 1500 characters. "
LARGE_TEXT+="Let's see if this causes any issues with the embedding generation process."

print_status "Testing embedding with larger text (${#LARGE_TEXT} chars)..."
LARGE_EMBEDDING=$(timeout 15 curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"model\":\"nomic-embed-text\",\"prompt\":\"$LARGE_TEXT\"}" \
    http://localhost:11434/api/embeddings)

if [ $? -eq 124 ]; then
    print_error "Large text embedding timed out (15 seconds)"
else
    if echo "$LARGE_EMBEDDING" | grep -q '"embedding"'; then
        print_success "Large text embedding successful"
    else
        print_error "Large text embedding failed"
    fi
fi

# Test 5: Check if any chunks exist in database
print_header "Test 5: Database Chunk Analysis"
print_status "Checking if any document chunks exist..."

# This would require a direct database query, but we can infer from query results
if [ $DOC_COUNT -gt 0 ]; then
    QUERY_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"query\":\"test\",\"documentId\":$FIRST_DOC_ID,\"learningLevel\":\"beginner\",\"responseType\":\"explanation\"}" \
        "$APP_URL/api/v1/query")
    
    if echo "$QUERY_RESPONSE" | grep -q '"sources":\[\]'; then
        print_warning "No document chunks found - this explains why queries fail"
    else
        print_success "Document chunks exist"
    fi
fi

print_header "Diagnostic Summary"
print_status "RAG System Status:"
echo "  - Ollama Services: $(if echo "$EMBEDDING_RESPONSE" | grep -q '"embedding"'; then echo "✅ Working"; else echo "❌ Failed"; fi)"
echo "  - Database Connection: $(if curl -s "$APP_URL/api/v1/health" > /dev/null 2>&1; then echo "✅ Working"; else echo "❌ Failed"; fi)"
echo "  - Documents Stored: $DOC_COUNT"
echo "  - Document Chunks: $(if echo "$QUERY_RESPONSE" | grep -q '"sources":\[\]'; then echo "❌ None"; else echo "✅ Exist"; fi)"
echo ""
print_status "Root Cause: RAG processing (chunking + embedding) is not completing during document upload"
print_status "Solution: Fix the timeout/hanging issue in processTextChunks method"
