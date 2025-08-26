#!/bin/bash

echo "📚 Pre-Loading PDF into Database"
echo "================================"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-your-pdf>"
    echo "Example: $0 ~/Downloads/math_textbook.pdf"
    echo ""
    echo "This will upload your PDF and process it once, making it permanently available."
    exit 1
fi

PDF_PATH="$1"

if [ ! -f "$PDF_PATH" ]; then
    echo "❌ Error: File '$PDF_PATH' not found!"
    exit 1
fi

echo "📄 PDF: $(basename "$PDF_PATH")"
echo "📏 Size: $(du -h "$PDF_PATH" | cut -f1)"
echo ""

# Check if application is running
echo "🔍 Checking if application is running..."
if ! curl -s http://localhost:8080/api/v1/health >/dev/null 2>&1; then
    echo "❌ Application is not running!"
    echo "🚀 Starting the application..."
    echo "   This will take about 30 seconds..."
    
    # Start the application in background
    nohup mvn spring-boot:run > app.log 2>&1 &
    APP_PID=$!
    
    # Wait for application to start
    echo "⏳ Waiting for application to start..."
    for i in {1..30}; do
        if curl -s http://localhost:8080/api/v1/health >/dev/null 2>&1; then
            echo "✅ Application started successfully!"
            break
        fi
        echo "   Waiting... ($i/30)"
        sleep 2
    done
    
    if ! curl -s http://localhost:8080/api/v1/health >/dev/null 2>&1; then
        echo "❌ Failed to start application. Check app.log for details."
        exit 1
    fi
else
    echo "✅ Application is already running!"
fi

echo ""
echo "📤 Uploading PDF to database..."

# Upload the PDF
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
echo "🔄 Processing PDF (this may take 15-35 minutes for large PDFs)..."
echo "⏳ This is a one-time process. The PDF will be permanently stored in the database."
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
            echo "✅ Status: COMPLETED - PDF processed and stored in database!"
            echo ""
            echo "🎉 Your PDF is now permanently stored in the database!"
            echo "📊 Document Details:"
            
            # Get document details
            DOC_DETAILS=$(curl -s http://localhost:8080/api/v1/documents/$DOC_ID)
            FILENAME=$(echo "$DOC_DETAILS" | grep -o '"originalFilename":"[^"]*"' | cut -d'"' -f4)
            TOTAL_CHUNKS=$(echo "$DOC_DETAILS" | grep -o '"totalChunks":[0-9]*' | cut -d':' -f2)
            
            echo "   📄 Filename: $FILENAME"
            echo "   🧩 Total Chunks: $TOTAL_CHUNKS"
            echo "   🆔 Document ID: $DOC_ID"
            echo ""
            echo "💾 The PDF is now permanently stored in the database."
            echo "🔄 You can restart the application anytime and the PDF will be available."
            echo ""
            echo "🌐 To use it:"
            echo "   1. Go to http://localhost:8080"
            echo "   2. You'll see your PDF in the documents list"
            echo "   3. Click 'Chat' to start asking questions"
            echo ""
            
            # Save document info for future reference
            echo "📝 Saving document info to preloaded_documents.txt..."
            echo "Document ID: $DOC_ID" > preloaded_documents.txt
            echo "Filename: $FILENAME" >> preloaded_documents.txt
            echo "Total Chunks: $TOTAL_CHUNKS" >> preloaded_documents.txt
            echo "Upload Date: $(date)" >> preloaded_documents.txt
            echo "Status: Permanently stored in database" >> preloaded_documents.txt
            
            echo "✅ Document info saved to preloaded_documents.txt"
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

echo ""
echo "🎯 Next Steps:"
echo "   1. Your PDF is now permanently stored in the database"
echo "   2. You can stop and restart the application anytime"
echo "   3. The PDF will always be available for questions"
echo "   4. Use the web interface or API to ask questions about your textbook"
echo ""
echo "🚀 Your RAG system is ready with persistent data!"
