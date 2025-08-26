#!/bin/bash

# Process RAG chunks for uploaded documents
# This script will trigger RAG processing for documents that were uploaded without chunks

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

print_header "Processing RAG Chunks for Uploaded Documents"

# Get all documents
print_status "Fetching all documents..."
DOCUMENTS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents")
DOC_COUNT=$(echo "$DOCUMENTS_RESPONSE" | jq 'length')
print_status "Found $DOC_COUNT documents"

# Process documents in batches to avoid overwhelming the system
BATCH_SIZE=5
PROCESSED=0
FAILED=0

for i in $(seq 0 $((DOC_COUNT - 1))); do
    DOC_ID=$(echo "$DOCUMENTS_RESPONSE" | jq -r ".[$i].id")
    DOC_NAME=$(echo "$DOCUMENTS_RESPONSE" | jq -r ".[$i].originalFilename")
    DOC_STATUS=$(echo "$DOCUMENTS_RESPONSE" | jq -r ".[$i].status")
    
    # Skip documents that are not completed
    if [ "$DOC_STATUS" != "COMPLETED" ]; then
        print_status "Skipping document $DOC_ID ($DOC_NAME) - status: $DOC_STATUS"
        continue
    fi
    
    print_status "Processing document $DOC_ID: $DOC_NAME"
    
    # Trigger RAG processing by re-uploading the document
    # This will trigger the RAG processing pipeline
    DOC_PATH=$(echo "$DOCUMENTS_RESPONSE" | jq -r ".[$i].filePath")
    
    if [ -f "$DOC_PATH" ]; then
        print_status "Re-uploading document $DOC_ID to trigger RAG processing..."
        
        UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@$DOC_PATH" "$APP_URL/api/v1/upload")
        
        if echo "$UPLOAD_RESPONSE" | grep -q '"documentId"'; then
            NEW_DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)
            print_success "Document $DOC_ID re-uploaded as $NEW_DOC_ID"
            PROCESSED=$((PROCESSED + 1))
        else
            print_error "Failed to re-upload document $DOC_ID"
            FAILED=$((FAILED + 1))
        fi
        
        # Wait a bit between uploads to avoid overwhelming the system
        sleep 2
    else
        print_error "File not found: $DOC_PATH"
        FAILED=$((FAILED + 1))
    fi
    
    # Process in batches
    if [ $((i % BATCH_SIZE)) -eq $((BATCH_SIZE - 1)) ]; then
        print_status "Processed batch. Waiting 10 seconds before next batch..."
        sleep 10
    fi
done

print_header "Processing Complete"
print_status "Summary:"
echo "  - Processed: $PROCESSED"
echo "  - Failed: $FAILED"
echo "  - Total: $DOC_COUNT"

if [ $PROCESSED -gt 0 ]; then
    print_success "RAG processing triggered for $PROCESSED documents"
    print_status "Check the application logs for processing status"
else
    print_error "No documents were processed"
fi
