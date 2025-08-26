#!/bin/bash

# Process RAG chunks for key textbook documents
# This will process the first few chunks to test the system

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

print_header "Processing Key Textbook Chunks"

# Process the first few chunks (pages 1-60) which should contain the introduction
KEY_DOCS=(75 76 77)  # Document IDs for the first few chunks

for DOC_ID in "${KEY_DOCS[@]}"; do
    print_status "Processing document $DOC_ID..."
    
    # Get document details
    DOC_DETAILS=$(curl -s "$APP_URL/api/v1/documents/$DOC_ID")
    DOC_NAME=$(echo "$DOC_DETAILS" | jq -r '.originalFilename')
    DOC_PATH=$(echo "$DOC_DETAILS" | jq -r '.filePath')
    
    print_status "Document: $DOC_NAME"
    
    if [ -f "$DOC_PATH" ]; then
        print_status "Re-uploading to trigger RAG processing..."
        
        UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@$DOC_PATH" "$APP_URL/api/v1/upload")
        
        if echo "$UPLOAD_RESPONSE" | grep -q '"documentId"'; then
            NEW_DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)
            print_success "Document $DOC_ID re-uploaded as $NEW_DOC_ID"
            
            # Wait for processing
            print_status "Waiting for RAG processing to complete..."
            sleep 10
            
            # Test if chunks were created
            TEST_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
                -d "{\"query\":\"test\",\"documentId\":$NEW_DOC_ID,\"learningLevel\":\"beginner\",\"responseType\":\"explanation\"}" \
                "$APP_URL/api/v1/query")
            
            CHUNK_COUNT=$(echo "$TEST_RESPONSE" | jq '.sources | length')
            
            if [ "$CHUNK_COUNT" -gt 0 ]; then
                print_success "RAG processing successful! Found $CHUNK_COUNT chunks"
            else
                print_warning "No chunks found yet, processing may still be in progress"
            fi
            
        else
            print_error "Failed to re-upload document $DOC_ID"
        fi
        
        # Wait between uploads
        sleep 5
        
    else
        print_error "File not found: $DOC_PATH"
    fi
done

print_header "Key Chunks Processing Complete"
print_status "Now you can test queries with the processed documents!"
