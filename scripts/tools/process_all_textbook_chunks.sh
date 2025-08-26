#!/bin/bash

# Process all 36 textbook chunks with RAG
# This will enable RAG processing for all uploaded textbook documents

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

print_header "Processing All Textbook Chunks with RAG"

# Get all documents
print_status "Fetching all documents..."
DOCUMENTS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents")
DOC_COUNT=$(echo "$DOCUMENTS_RESPONSE" | jq 'length')
print_status "Found $DOC_COUNT documents"

# Filter for textbook chunks (documents 75-110 are the textbook chunks)
TEXTBOOK_DOCS=()
PROCESSED=0
FAILED=0

for i in $(seq 0 $((DOC_COUNT - 1))); do
    DOC_ID=$(echo "$DOCUMENTS_RESPONSE" | jq -r ".[$i].id")
    DOC_NAME=$(echo "$DOCUMENTS_RESPONSE" | jq -r ".[$i].originalFilename")
    DOC_STATUS=$(echo "$DOCUMENTS_RESPONSE" | jq -r ".[$i].status")
    
    # Only process textbook chunks (documents 75-110)
    if [ "$DOC_ID" -ge 75 ] && [ "$DOC_ID" -le 110 ] && [ "$DOC_STATUS" = "COMPLETED" ]; then
        TEXTBOOK_DOCS+=($DOC_ID)
    fi
done

print_status "Found ${#TEXTBOOK_DOCS[@]} textbook chunks to process"

# Process in batches to avoid overwhelming the system
BATCH_SIZE=3
BATCH_COUNT=0

for DOC_ID in "${TEXTBOOK_DOCS[@]}"; do
    BATCH_COUNT=$((BATCH_COUNT + 1))
    
    # Get document details
    DOC_DETAILS=$(curl -s "$APP_URL/api/v1/documents/$DOC_ID")
    DOC_NAME=$(echo "$DOC_DETAILS" | jq -r '.originalFilename')
    DOC_PATH=$(echo "$DOC_DETAILS" | jq -r '.filePath')
    
    print_status "Processing document $DOC_ID: $DOC_NAME"
    
    if [ -f "$DOC_PATH" ]; then
        print_status "Re-uploading to trigger RAG processing..."
        
        UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@$DOC_PATH" "$APP_URL/api/v1/upload")
        
        if echo "$UPLOAD_RESPONSE" | grep -q '"documentId"'; then
            NEW_DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)
            print_success "Document $DOC_ID re-uploaded as $NEW_DOC_ID"
            PROCESSED=$((PROCESSED + 1))
        else
            print_error "Failed to re-upload document $DOC_ID"
            FAILED=$((FAILED + 1))
        fi
        
        # Wait between uploads
        sleep 3
        
        # Process in batches
        if [ $((BATCH_COUNT % BATCH_SIZE)) -eq 0 ]; then
            print_status "Processed batch $((BATCH_COUNT / BATCH_SIZE)). Waiting 15 seconds before next batch..."
            sleep 15
        fi
        
    else
        print_error "File not found: $DOC_PATH"
        FAILED=$((FAILED + 1))
    fi
done

print_header "Processing Complete"
print_status "Summary:"
echo "  - Processed: $PROCESSED"
echo "  - Failed: $FAILED"
echo "  - Total: ${#TEXTBOOK_DOCS[@]}"

if [ $PROCESSED -gt 0 ]; then
    print_success "RAG processing triggered for $PROCESSED textbook chunks"
    print_status "The system will now process chunks in the background"
    print_status "You can start testing queries while processing continues"
else
    print_error "No documents were processed"
fi

print_status "Next step: Creating web interface..."
