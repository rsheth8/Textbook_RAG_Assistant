#!/bin/bash

# Smart PDF Splitting and Upload Script
# This script intelligently splits large PDFs and uploads them to the RAG system

set -e

PDF_PATH="/Users/rahilsheth/Downloads/Math 4242/Applied Linear Algebra.pdf"
APP_URL="http://localhost:8080"
CHUNK_SIZE_PAGES=20  # 20 pages per chunk for manageable size
UPLOAD_DIR="./pdf_chunks_smart"
LOG_FILE="./smart_split_log.txt"
MAX_CONCURRENT_UPLOADS=3  # Limit concurrent uploads to avoid overwhelming the system

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

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v pdftk &> /dev/null; then
        print_error "pdftk is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed. Please install it first."
        exit 1
    fi
    
    if [ ! -f "$PDF_PATH" ]; then
        print_error "PDF file not found: $PDF_PATH"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Get PDF information
get_pdf_info() {
    print_status "Analyzing PDF..."
    
    TOTAL_PAGES=$(pdftk "$PDF_PATH" dump_data | grep NumberOfPages | cut -d' ' -f2)
    FILE_SIZE=$(du -h "$PDF_PATH" | cut -f1)
    
    print_success "PDF Analysis Complete:"
    echo "  - Total Pages: $TOTAL_PAGES"
    echo "  - File Size: $FILE_SIZE"
    echo "  - Chunk Size: $CHUNK_SIZE_PAGES pages"
    
    TOTAL_CHUNKS=$(( (TOTAL_PAGES + CHUNK_SIZE_PAGES - 1) / CHUNK_SIZE_PAGES ))
    echo "  - Total Chunks: $TOTAL_CHUNKS"
    
    log_message "PDF Analysis: $TOTAL_PAGES pages, $FILE_SIZE, $TOTAL_CHUNKS chunks"
}

# Create upload directory
setup_directories() {
    print_status "Setting up directories..."
    
    mkdir -p "$UPLOAD_DIR"
    rm -f "$UPLOAD_DIR"/*.pdf 2>/dev/null || true
    
    print_success "Directories ready"
}

# Check if application is running
check_application() {
    print_status "Checking application status..."
    
    if ! curl -s "$APP_URL/api/v1/health" > /dev/null 2>&1; then
        print_warning "Application not running. Starting it now..."
        
        # Start application with high memory allocation
        MAVEN_OPTS="-Xmx8g -Xms4g -XX:+UseG1GC -XX:MaxGCPauseMillis=200" mvn spring-boot:run > app_smart.log 2>&1 &
        APP_PID=$!
        
        print_status "Application starting (PID: $APP_PID)..."
        
        # Wait for application to start
        for i in {1..120}; do
            if curl -s "$APP_URL/api/v1/health" > /dev/null 2>&1; then
                print_success "Application started successfully!"
                break
            fi
            if [ $i -eq 120 ]; then
                print_error "Application failed to start within 120 seconds"
                exit 1
            fi
            sleep 1
        done
    else
        print_success "Application is already running"
    fi
}

# Split PDF into chunks
split_pdf() {
    print_status "Splitting PDF into chunks..."
    
    local chunk_count=0
    
    for ((start_page=1; start_page<=TOTAL_PAGES; start_page+=CHUNK_SIZE_PAGES)); do
        local end_page=$((start_page + CHUNK_SIZE_PAGES - 1))
        if [ $end_page -gt $TOTAL_PAGES ]; then
            end_page=$TOTAL_PAGES
        fi
        
        chunk_count=$((chunk_count + 1))
        local chunk_filename="chunk_${chunk_count}_pages_${start_page}-${end_page}.pdf"
        local chunk_path="$UPLOAD_DIR/$chunk_filename"
        
        print_status "Creating chunk $chunk_count: pages $start_page-$end_page"
        
        pdftk "$PDF_PATH" cat $start_page-$end_page output "$chunk_path"
        
        local chunk_size=$(du -k "$chunk_path" | cut -f1)
        print_success "Created $chunk_filename (${chunk_size}KB)"
        
        log_message "Created chunk $chunk_count: $chunk_filename (${chunk_size}KB)"
    done
    
    print_success "PDF splitting completed: $chunk_count chunks created"
}

# Upload a single chunk
upload_chunk() {
    local chunk_path="$1"
    local chunk_name=$(basename "$chunk_path")
    
    print_status "Uploading $chunk_name..."
    
    local upload_response=$(curl -s -X POST -F "file=@$chunk_path" "$APP_URL/api/v1/upload")
    
    if echo "$upload_response" | grep -q '"documentId"'; then
        local doc_id=$(echo "$upload_response" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)
        print_success "Upload successful: Document ID $doc_id"
        
        # Wait for processing to complete
        local max_attempts=30
        for ((attempt=1; attempt<=max_attempts; attempt++)); do
            local status_response=$(curl -s "$APP_URL/api/v1/documents/$doc_id")
            local status=$(echo "$status_response" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
            
            case $status in
                "COMPLETED")
                    print_success "Processing completed for $chunk_name"
                    log_message "Chunk $chunk_name processed successfully (ID: $doc_id)"
                    return 0
                    ;;
                "FAILED")
                    local error_msg=$(echo "$status_response" | grep -o '"errorMessage":"[^"]*"' | cut -d'"' -f4)
                    print_error "Processing failed for $chunk_name: $error_msg"
                    log_message "Chunk $chunk_name failed: $error_msg"
                    return 1
                    ;;
                *)
                    if [ $attempt -eq $max_attempts ]; then
                        print_error "Processing timeout for $chunk_name"
                        log_message "Chunk $chunk_name timed out"
                        return 1
                    fi
                    sleep 3
                    ;;
            esac
        done
    else
        print_error "Upload failed for $chunk_name"
        log_message "Upload failed for $chunk_name"
        return 1
    fi
}

# Upload all chunks with concurrency control
upload_all_chunks() {
    print_status "Starting chunk uploads (max $MAX_CONCURRENT_UPLOADS concurrent)..."
    
    local chunk_files=($(ls -1 "$UPLOAD_DIR"/*.pdf 2>/dev/null | sort))
    local total_chunks=${#chunk_files[@]}
    local successful_uploads=0
    local failed_uploads=0
    
    if [ $total_chunks -eq 0 ]; then
        print_error "No chunk files found in $UPLOAD_DIR"
        return 1
    fi
    
    print_status "Found $total_chunks chunks to upload"
    
    # Process chunks in batches
    for ((i=0; i<total_chunks; i+=MAX_CONCURRENT_UPLOADS)); do
        local batch_end=$((i + MAX_CONCURRENT_UPLOADS - 1))
        if [ $batch_end -ge $total_chunks ]; then
            batch_end=$((total_chunks - 1))
        fi
        
        print_status "Processing batch $((i/MAX_CONCURRENT_UPLOADS + 1)): chunks $((i+1))-$((batch_end+1))"
        
        # Start concurrent uploads for this batch
        local pids=()
        for ((j=i; j<=batch_end; j++)); do
            upload_chunk "${chunk_files[j]}" &
            pids+=($!)
        done
        
        # Wait for all uploads in this batch to complete
        for pid in "${pids[@]}"; do
            if wait $pid; then
                successful_uploads=$((successful_uploads + 1))
            else
                failed_uploads=$((failed_uploads + 1))
            fi
        done
        
        # Small delay between batches
        sleep 2
    done
    
    print_success "Upload Summary:"
    echo "  - Successful: $successful_uploads"
    echo "  - Failed: $failed_uploads"
    echo "  - Total: $total_chunks"
    
    log_message "Upload Summary: $successful_uploads successful, $failed_uploads failed"
    
    if [ $failed_uploads -eq 0 ]; then
        print_success "All chunks uploaded successfully!"
        return 0
    else
        print_warning "Some chunks failed to upload"
        return 1
    fi
}

# Main execution
main() {
    print_status "Starting Smart PDF Splitter"
    echo "=================================="
    
    # Initialize log file
    echo "Smart PDF Splitter Log - $(date)" > "$LOG_FILE"
    
    check_prerequisites
    get_pdf_info
    setup_directories
    check_application
    split_pdf
    upload_all_chunks
    
    print_success "Smart PDF splitting and upload completed!"
    print_status "Check $LOG_FILE for detailed logs"
}

# Run main function
main "$@"
