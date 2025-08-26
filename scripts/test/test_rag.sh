#!/bin/bash

echo "🧪 Testing RAG System"
echo "====================="

# Test 1: Health check
echo "1. Testing health endpoint..."
curl -s http://localhost:8080/api/v1/health
echo -e "\n"

# Test 2: List documents
echo "2. Listing documents..."
curl -s http://localhost:8080/api/v1/documents | jq '.' 2>/dev/null || echo "No documents found or jq not installed"

echo -e "\n"
echo "📚 To test the full RAG system:"
echo "1. Go to http://localhost:8080"
echo "2. Upload a PDF file (or use the sample text we created)"
echo "3. Wait for processing to complete"
echo "4. Click 'Chat' to ask questions about the document"
echo ""
echo "💡 Example questions to try:"
echo "- 'What is calculus?'"
echo "- 'Explain derivatives'"
echo "- 'What is the fundamental theorem of calculus?'"
echo "- 'How are derivatives used in physics?'"
echo ""
echo "🔧 Ollama Status:"
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "✅ Ollama is running"
    echo "📋 Available models:"
    curl -s http://localhost:11434/api/tags | jq '.models[].name' 2>/dev/null || echo "llama2"
else
    echo "❌ Ollama is not running. Start it with: ollama serve"
fi

echo ""
echo "🗄️ Database Status:"
./manage_db.sh status
