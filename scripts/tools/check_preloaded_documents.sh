#!/bin/bash

echo "📚 Checking Pre-Loaded Documents"
echo "================================"

# Check if application is running
if ! curl -s http://localhost:8080/api/v1/health >/dev/null 2>&1; then
    echo "❌ Application is not running!"
    echo "🚀 Start it with: mvn spring-boot:run"
    exit 1
fi

echo "✅ Application is running"
echo ""

# Get all documents from the database
echo "📋 Documents in Database:"
echo "------------------------"

DOCUMENTS_RESPONSE=$(curl -s http://localhost:8080/api/v1/documents)

if [ "$DOCUMENTS_RESPONSE" = "[]" ]; then
    echo "📭 No documents found in database"
    echo ""
    echo "💡 To pre-load a PDF:"
    echo "   ./preload_pdf.sh /path/to/your/math_textbook.pdf"
    exit 0
fi

# Parse and display documents
echo "$DOCUMENTS_RESPONSE" | jq -r '.[] | "📄 \(.originalFilename)\n   🆔 ID: \(.id)\n   📊 Status: \(.status)\n   🧩 Chunks: \(.totalChunks // "N/A")\n   📅 Uploaded: \(.uploadedAt)\n"' 2>/dev/null || {
    echo "📄 Documents found (JSON format):"
    echo "$DOCUMENTS_RESPONSE"
}

echo ""
echo "💬 To chat with a document:"
echo "   1. Go to http://localhost:8080"
echo "   2. Click 'Chat' on any document"
echo "   3. Ask questions about your textbook!"
echo ""
echo "🔧 To add more documents:"
echo "   ./preload_pdf.sh /path/to/another_pdf.pdf"
