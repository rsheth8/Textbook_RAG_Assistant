#!/bin/bash

# Simple RAG testing script
# This tests RAG processing with minimal text

set -e

APP_URL="http://localhost:8080"
TEST_DIR="./test_rag_simple"

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

# Create test directory
mkdir -p "$TEST_DIR"

print_status "Creating minimal test file..."

# Create a very minimal text file
cat > "$TEST_DIR/tiny_test.txt" << 'EOF'
Matrix. Linear algebra. Vector.
EOF

print_success "Created tiny_test.txt"

# Start application
print_status "Starting application..."
MAVEN_OPTS="-Xmx4g -Xms2g" mvn spring-boot:run > app_simple_rag.log 2>&1 &
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

# Test upload with RAG processing
print_status "Testing upload with RAG processing (timeout: 60 seconds)..."
UPLOAD_RESPONSE=$(timeout 60 curl -s -X POST -F "file=@$TEST_DIR/tiny_test.txt" "$APP_URL/api/v1/upload")

if [ $? -eq 124 ]; then
    print_error "Upload timed out after 60 seconds"
    exit 1
fi

echo "Upload response: $UPLOAD_RESPONSE"

if echo "$UPLOAD_RESPONSE" | grep -q '"documentId"'; then
    DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)
    print_success "Upload successful! Document ID: $DOC_ID"
    
    # Wait for processing
    print_status "Waiting for processing..."
    for i in {1..30}; do
        STATUS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents/$DOC_ID")
        STATUS=$(echo "$STATUS_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        
        case $STATUS in
            "COMPLETED")
                print_success "Processing completed successfully!"
                echo "Status response: $STATUS_RESPONSE"
                break
                ;;
            "FAILED")
                ERROR_MSG=$(echo "$STATUS_RESPONSE" | grep -o '"errorMessage":"[^"]*"' | cut -d'"' -f4)
                print_error "Processing failed: $ERROR_MSG"
                break
                ;;
            *)
                if [ $i -eq 30 ]; then
                    print_error "Processing timeout after 30 seconds"
                else
                    sleep 2
                fi
                ;;
        esac
    done
    
    # Test query
    print_status "Testing query with processed document..."
    QUERY_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"query\":\"What is a matrix?\",\"documentId\":$DOC_ID,\"learningLevel\":\"beginner\",\"responseType\":\"explanation\"}" \
        "$APP_URL/api/v1/query")
    
    echo "Query response: $QUERY_RESPONSE"
    
    if echo "$QUERY_RESPONSE" | grep -q '"answer"'; then
        ANSWER=$(echo "$QUERY_RESPONSE" | grep -o '"answer":"[^"]*"' | cut -d'"' -f4)
        if [[ "$ANSWER" == *"error"* ]] || [[ "$ANSWER" == *"Sorry"* ]]; then
            print_warning "Query returned error: $ANSWER"
        else
            print_success "Query successful! Answer: $ANSWER"
        fi
    else
        print_error "Query failed"
    fi
    
else
    print_error "Upload failed"
fi

print_status "Simple RAG test completed. Check app_simple_rag.log for detailed logs."
