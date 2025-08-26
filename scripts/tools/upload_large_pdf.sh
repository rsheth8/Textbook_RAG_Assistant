#!/bin/bash

echo "📚 Large PDF Upload Script"
echo "========================="

if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-your-pdf>"
    echo "Example: $0 ~/Downloads/math_textbook.pdf"
    exit 1
fi

PDF_PATH="$1"

if [ ! -f "$PDF_PATH" ]; then
    echo "❌ Error: File '$PDF_PATH' not found!"
    exit 1
fi

echo "📄 Uploading: $(basename "$PDF_PATH")"
echo "📏 File size: $(du -h "$PDF_PATH" | cut -f1)"
echo ""

# Upload the PDF
echo "🔄 Uploading PDF..."
UPLOAD_RESPONSE=$(curl -s -X POST -F "file=@$PDF_PATH" http://localhost:8080/api/v1/upload)

if [ $? -ne 0 ]; then
    echo "❌ Upload failed!"
    exit 1
fi

# Extract document ID from response
DOC_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"documentId":[0-9]*' | cut -d':' -f2)

if [ -z "$DOC_ID" ]; then
    echo "❌ Could not get document ID from response"
    echo "Response: $UPLOAD_RESPONSE"
    exit 1
fi

echo "✅ Upload successful! Document ID: $DOC_ID"
echo ""

# Monitor processing status
echo "🔄 Monitoring processing status..."
echo "⏳ This may take 15-35 minutes for a 700-page PDF..."
echo ""

while true; do
    STATUS_RESPONSE=$(curl -s http://localhost:8080/api/v1/documents/$DOC_ID)
    STATUS=$(echo "$STATUS_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    
    case $STATUS in
        "UPLOADED")
            echo "📤 Status: UPLOADED - File uploaded, processing starting..."
            ;;
        "PROCESSING")
            echo "⚙️  Status: PROCESSING - Extracting text and generating embeddings..."
            ;;
        "COMPLETED")
            echo "✅ Status: COMPLETED - PDF processed successfully!"
            echo ""
            echo "🎉 Your PDF is ready for questions!"
            echo "🌐 Go to: http://localhost:8080"
            echo "💬 Click 'Chat' on your document to start asking questions"
            break
            ;;
        "FAILED")
            ERROR_MSG=$(echo "$STATUS_RESPONSE" | grep -o '"errorMessage":"[^"]*"' | cut -d'"' -f4)
            echo "❌ Status: FAILED - $ERROR_MSG"
            exit 1
            ;;
        *)
            echo "❓ Status: UNKNOWN - $STATUS"
            ;;
    esac
    
    sleep 30  # Check every 30 seconds
done
