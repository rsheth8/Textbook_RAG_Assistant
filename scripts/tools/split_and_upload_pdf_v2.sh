#!/bin/bash

# Smart PDF Splitting and Upload Script v2
# This script splits a large PDF into very small chunks and uploads them to the RAG system

set -e

# Configuration
PDF_PATH="$1"
CHUNK_SIZE_PAGES=10  # Much smaller chunks - 10 pages each
MAX_FILE_SIZE_MB=1   # Maximum file size per chunk in MB
APP_URL="http://localhost:8080"
UPLOAD_DIR="./pdf_chunks_small"
LOG_FILE="./upload_log_v2.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if PDF path is provided
if [ -z "$PDF_PATH" ]; then
    print_error "Usage: $0 <path_to_pdf>"
    print_error "Example: $0 '/Users/rahilsheth/Downloads/Math 4242/Applied Linear Algebra.pdf'"
    exit 1
fi

# Check if PDF file exists
if [ ! -f "$PDF_PATH" ]; then
    print_error "PDF file not found: $PDF_PATH"
    exit 1
fi

# Check if required tools are installed
if ! command -v pdftk &> /dev/null; then
    print_error "pdftk is not installed. Please install it first:"
    print_error "  macOS: brew install pdftk-java"
    print_error "  Ubuntu: sudo apt-get install pdftk"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    print_error "curl is not installed"
    exit 1
fi

# Create upload directory
mkdir -p "$UPLOAD_DIR"
rm -f "$LOG_FILE"

print_status "Starting smart PDF splitting and upload process (v2)..."
log_message "Starting process for PDF: $PDF_PATH"

# Get PDF information
print_status "Analyzing PDF..."
TOTAL_PAGES=$(pdftk "$PDF_PATH" dump_data | grep NumberOfPages | awk '{print $2}')
PDF_SIZE_MB=$(du -m "$PDF_PATH" | cut -f1)
PDF_NAME=$(basename "$PDF_PATH" .pdf)

print_success "PDF Analysis Complete:"
print_success "  - Total pages: $TOTAL_PAGES"
print_success "  - File size: ${PDF_SIZE_MB}MB"
print_success "  - Name: $PDF_NAME"

# Calculate optimal chunk size
if [ "$TOTAL_PAGES" -le "$CHUNK_SIZE_PAGES" ]; then
    CHUNKS=1
    PAGES_PER_CHUNK=$TOTAL_PAGES
else
    CHUNKS=$(( (TOTAL_PAGES + CHUNK_SIZE_PAGES - 1) / CHUNK_SIZE_PAGES ))
    PAGES_PER_CHUNK=$CHUNK_SIZE_PAGES
fi

print_status "Splitting PDF into $CHUNKS chunks of ~${PAGES_PER_CHUNK} pages each..."

# Split PDF into chunks
for ((i=1; i<=CHUNKS; i++)); do
    START_PAGE=$(( (i-1) * PAGES_PER_CHUNK + 1 ))
    END_PAGE=$(( i * PAGES_PER_CHUNK ))
    
    # Ensure we don't exceed total pages
    if [ "$END_PAGE" -gt "$TOTAL_PAGES" ]; then
        END_PAGE=$TOTAL_PAGES
    fi
    
    CHUNK_FILE="$UPLOAD_DIR/${PDF_NAME}_part${i}_pages${START_PAGE}-${END_PAGE}.pdf"
    
    print_status "Creating chunk $i/$CHUNKS (pages $START_PAGE-$END_PAGE)..."
    
    pdftk "$PDF_PATH" cat $START_PAGE-$END_PAGE output "$CHUNK_FILE"
    
    CHUNK_SIZE=$(du -m "$CHUNK_FILE" | cut -f1)
    print_success "Created: $(basename "$CHUNK_FILE") (${CHUNK_SIZE}MB)"
    
    log_message "Created chunk $i: $CHUNK_FILE (${CHUNK_SIZE}MB, pages $START_PAGE-$END_PAGE)"
done

print_success "PDF splitting completed! Created $CHUNKS chunks in $UPLOAD_DIR"

# Start the application with higher memory settings
print_status "Starting application with optimized memory settings..."
MAVEN_OPTS="-Xmx12g -Xms6g -XX:+UseG1GC -XX:MaxGCPauseMillis=200" mvn spring-boot:run > app_v2.log 2>&1 &
APP_PID=$!

print_status "Application starting (PID: $APP_PID)..."

# Wait for application to start
for i in {1..90}; do
    if curl -s "$APP_URL/api/v1/health" > /dev/null 2>&1; then
        print_success "Application started successfully!"
        break
    fi
    if [ $i -eq 90 ]; then
        print_error "Application failed to start within 90 seconds"
        exit 1
    fi
    sleep 1
done

# Upload chunks with longer delays
print_status "Starting upload process for $CHUNKS chunks..."

UPLOADED_COUNT=0
FAILED_COUNT=0

for chunk_file in "$UPLOAD_DIR"/*.pdf; do
    if [ ! -f "$chunk_file" ]; then
        continue
    fi
    
    CHUNK_NAME=$(basename "$chunk_file")
    print_status "Uploading: $CHUNK_NAME"
    
    # Upload the chunk
    UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@$chunk_file" "$APP_URL/api/v1/upload")
    
    if echo "$UPLOAD_RESPONSE" | grep -q '"success":true'; then
        DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)
        print_success "Uploaded successfully! Document ID: $DOC_ID"
        log_message "Uploaded: $CHUNK_NAME -> Document ID: $DOC_ID"
        ((UPLOADED_COUNT++))
        
        # Wait for processing to complete with longer timeout
        print_status "Waiting for processing to complete..."
        for i in {1..180}; do
            STATUS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents/$DOC_ID")
            STATUS=$(echo "$STATUS_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
            
            case $STATUS in
                "COMPLETED")
                    print_success "Processing completed for $CHUNK_NAME"
                    log_message "Processing completed: $CHUNK_NAME"
                    break
                    ;;
                "FAILED")
                    ERROR_MSG=$(echo "$STATUS_RESPONSE" | grep -o '"errorMessage":"[^"]*"' | cut -d'"' -f4)
                    print_error "Processing failed for $CHUNK_NAME: $ERROR_MSG"
                    log_message "Processing failed: $CHUNK_NAME - $ERROR_MSG"
                    ((FAILED_COUNT++))
                    break
                    ;;
                *)
                    if [ $i -eq 180 ]; then
                        print_warning "Processing timeout for $CHUNK_NAME"
                        log_message "Processing timeout: $CHUNK_NAME"
                        ((FAILED_COUNT++))
                    else
                        sleep 3
                    fi
                    ;;
            esac
        done
    else
        ERROR_MSG=$(echo "$UPLOAD_RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        print_error "Upload failed for $CHUNK_NAME: $ERROR_MSG"
        log_message "Upload failed: $CHUNK_NAME - $ERROR_MSG"
        ((FAILED_COUNT++))
    fi
    
    # Longer delay between uploads
    sleep 3
done

# Summary
print_status "Upload process completed!"
print_success "Successfully uploaded: $UPLOADED_COUNT chunks"
if [ $FAILED_COUNT -gt 0 ]; then
    print_warning "Failed uploads: $FAILED_COUNT chunks"
fi

log_message "Upload process completed. Success: $UPLOADED_COUNT, Failed: $FAILED_COUNT"

# Show uploaded documents
print_status "Current documents in database:"
DOCUMENTS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents")
if echo "$DOCUMENTS_RESPONSE" | grep -q '"documents":\[\]'; then
    print_warning "No documents found in database"
else
    echo "$DOCUMENTS_RESPONSE" | grep -o '"originalFilename":"[^"]*"' | cut -d'"' -f4 | while read -r filename; do
        print_success "  - $filename"
    done
fi

print_success "Process completed! Check $LOG_FILE for detailed logs."
print_status "You can now use the RAG system at: $APP_URL"
