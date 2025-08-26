#!/bin/bash

# Debug RAG system step by step

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

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Test 1: Check if chunks exist
print_header "Test 1: Check Document Chunks"
print_status "Checking if document 74 has chunks..."

DOC_DETAILS=$(curl -s "$APP_URL/api/v1/documents/74")
echo "Document details: $DOC_DETAILS"

# Test 2: Test query with detailed logging
print_header "Test 2: Test Query with Debug"
print_status "Testing query with document 74..."

QUERY_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"query":"What is a matrix?","documentId":74,"learningLevel":"beginner","responseType":"explanation"}' \
    "$APP_URL/api/v1/query")

echo "Full query response: $QUERY_RESPONSE"

# Test 3: Test Ollama directly with the same prompt
print_header "Test 3: Test Ollama Directly"
print_status "Testing Ollama with a simple prompt..."

OLLAMA_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"model":"llama2","prompt":"What is a matrix?","stream":false}' \
    http://localhost:11434/api/generate)

echo "Ollama response: $OLLAMA_RESPONSE"

# Test 4: Check application logs
print_header "Test 4: Check Application Logs"
print_status "Recent application logs:"
tail -20 app_rag_fixed_v3.log
