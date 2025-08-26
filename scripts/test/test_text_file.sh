#!/bin/bash

# Test script for text file processing
# This creates a simple text file to test the RAG system

set -e

TEST_DIR="./test_text"
APP_URL="http://localhost:8080"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

# Create test directory
mkdir -p "$TEST_DIR"

print_status "Creating a simple text file for testing..."

# Create a simple text file with math content
cat > "$TEST_DIR/sample_math.txt" << 'EOF'
Linear Algebra Fundamentals

Chapter 1: Introduction to Matrices

A matrix is a rectangular array of numbers arranged in rows and columns. 
Matrices are fundamental objects in linear algebra and have many applications 
in mathematics, physics, engineering, and computer science.

Example 1.1: Consider the matrix A = [1 2; 3 4]
This is a 2x2 matrix with elements:
- Row 1: [1, 2]
- Row 2: [3, 4]

Matrix Operations:
1. Addition: Two matrices can be added if they have the same dimensions
2. Multiplication: Matrix multiplication follows specific rules
3. Transpose: The transpose of a matrix flips rows and columns

Chapter 2: Vector Spaces

A vector space is a collection of vectors that can be added together and 
multiplied by scalars. The most common vector space is R^n, the set of 
all n-dimensional real vectors.

Properties of Vector Spaces:
- Closure under addition
- Closure under scalar multiplication
- Existence of zero vector
- Existence of additive inverses

Chapter 3: Linear Transformations

A linear transformation is a function between vector spaces that preserves 
vector addition and scalar multiplication. Linear transformations can be 
represented by matrices.

Key Properties:
- T(u + v) = T(u) + T(v)
- T(cu) = cT(u)

This concludes our introduction to linear algebra fundamentals.
EOF

FILE_SIZE=$(du -k "$TEST_DIR/sample_math.txt" | cut -f1)
print_success "Created text file: sample_math.txt (${FILE_SIZE}KB)"

# Start application with minimal memory
print_status "Starting application..."
MAVEN_OPTS="-Xmx1g -Xms512m" mvn spring-boot:run > app_text.log 2>&1 &
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

# Test upload with timeout
print_status "Testing upload with text file (timeout: 30 seconds)..."
UPLOAD_RESPONSE=$(timeout 30 curl -s -X POST -F "file=@$TEST_DIR/sample_math.txt" "$APP_URL/api/v1/upload")

if [ $? -eq 124 ]; then
    print_error "Upload timed out after 30 seconds"
    exit 1
fi

if echo "$UPLOAD_RESPONSE" | grep -q '"success":true'; then
    DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)
    print_success "Upload successful! Document ID: $DOC_ID"
    
    # Wait for processing with timeout
    print_status "Waiting for processing (timeout: 60 seconds)..."
    for i in {1..60}; do
        STATUS_RESPONSE=$(curl -s "$APP_URL/api/v1/documents/$DOC_ID")
        STATUS=$(echo "$STATUS_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        
        case $STATUS in
            "COMPLETED")
                print_success "Processing completed successfully!"
                
                # Test a simple query
                print_status "Testing a simple query..."
                QUERY_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
                    -d '{"query":"What is a matrix?","documentId":'$DOC_ID',"learningLevel":"beginner","responseType":"explanation"}' \
                    "$APP_URL/api/v1/query")
                
                if echo "$QUERY_RESPONSE" | grep -q '"answer"'; then
                    ANSWER=$(echo "$QUERY_RESPONSE" | grep -o '"answer":"[^"]*"' | cut -d'"' -f4)
                    print_success "Query successful! Answer: $ANSWER"
                else
                    print_error "Query failed"
                fi
                break
                ;;
            "FAILED")
                ERROR_MSG=$(echo "$STATUS_RESPONSE" | grep -o '"errorMessage":"[^"]*"' | cut -d'"' -f4)
                print_error "Processing failed: $ERROR_MSG"
                break
                ;;
            *)
                if [ $i -eq 60 ]; then
                    print_error "Processing timeout after 60 seconds"
                else
                    sleep 2
                fi
                ;;
        esac
    done
else
    ERROR_MSG=$(echo "$UPLOAD_RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
    print_error "Upload failed: $ERROR_MSG"
fi

print_status "Test completed. Check app_text.log for application logs."
