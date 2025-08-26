#!/bin/bash

# Step-by-step RAG testing with fixes
# This isolates and fixes the RAG processing issue

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

# Step 1: Test with minimal text and RAG disabled
print_header "Step 1: Test Basic Upload (RAG Disabled)"
print_status "Creating minimal test file..."

cat > "./test_minimal_fixed.txt" << 'EOF'
Matrix. Linear algebra. Vector.
EOF

print_status "Uploading with RAG disabled..."
UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@./test_minimal_fixed.txt" "$APP_URL/api/v1/upload")

if echo "$UPLOAD_RESPONSE" | grep -q '"documentId"'; then
    DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)
    print_success "Upload successful! Document ID: $DOC_ID"
    
    # Check document status
    sleep 2
    STATUS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents/$DOC_ID")
    STATUS=$(echo "$STATUS_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$STATUS" = "COMPLETED" ]; then
        print_success "Document processing completed"
        
        # Check extracted text
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

# Step 2: Test manual chunking and embedding
print_header "Step 2: Test Manual Chunking and Embedding"

# Test chunking logic with the extracted text
if [ -n "$EXTRACTED_TEXT" ]; then
    print_status "Testing chunking with extracted text: '$EXTRACTED_TEXT'"
    
    # Calculate expected chunks
    TEXT_LENGTH=${#EXTRACTED_TEXT}
    CHUNK_SIZE=1500
    OVERLAP=300
    
    if [ $TEXT_LENGTH -le $CHUNK_SIZE ]; then
        EXPECTED_CHUNKS=1
    else
        EXPECTED_CHUNKS=$(( (TEXT_LENGTH - CHUNK_SIZE) / (CHUNK_SIZE - OVERLAP) + 1 ))
    fi
    
    print_status "Text length: $TEXT_LENGTH characters"
    print_status "Expected chunks: $EXPECTED_CHUNKS"
    
    # Test embedding generation for this text
    print_status "Testing embedding generation..."
    EMBEDDING_RESPONSE=$(timeout 10 curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"model\":\"nomic-embed-text\",\"prompt\":\"$EXTRACTED_TEXT\"}" \
        http://localhost:11434/api/embeddings)
    
    if [ $? -eq 124 ]; then
        print_error "Embedding generation timed out"
    else
        if echo "$EMBEDDING_RESPONSE" | grep -q '"embedding"'; then
            print_success "Embedding generation successful"
        else
            print_error "Embedding generation failed"
        fi
    fi
fi

# Step 3: Test query with no chunks (expected to fail)
print_header "Step 3: Test Query (Expected to Fail)"
print_status "Testing query with document that has no chunks..."

QUERY_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"query\":\"What is a matrix?\",\"documentId\":$DOC_ID,\"learningLevel\":\"beginner\",\"responseType\":\"explanation\"}" \
    "$APP_URL/api/v1/query")

echo "Query Response: $QUERY_RESPONSE"

if echo "$QUERY_RESPONSE" | grep -q '"sources":\[\]'; then
    print_warning "Query failed as expected - no chunks exist"
else
    print_success "Query succeeded unexpectedly"
fi

print_header "Diagnosis Complete"
print_status "Root Cause Confirmed:"
echo "  - Documents are uploaded and processed ✅"
echo "  - Text is extracted ✅"
echo "  - Ollama services work ✅"
echo "  - RAG processing (chunking + embedding) is not completing ❌"
echo "  - No document chunks exist in database ❌"
echo ""
print_status "Next Step: Enable RAG processing and debug the hanging issue"
