#!/bin/bash

# Show complete system status

echo "🎉 TEXTBOOK RAG ASSISTANT - SYSTEM STATUS"
echo "=========================================="
echo ""

# Check if application is running
if curl -s http://localhost:8080/api/v1/health > /dev/null 2>&1; then
    echo "✅ Application Status: RUNNING"
else
    echo "❌ Application Status: OFFLINE"
    exit 1
fi

# Get document count
DOC_COUNT=$(curl -s http://localhost:8080/api/v1/documents | jq 'length')
echo "📚 Total Documents: $DOC_COUNT"

# Count textbook chunks
TEXTBOOK_CHUNKS=$(curl -s http://localhost:8080/api/v1/documents | jq '[.[] | select(.id >= 75 and .id <= 110)] | length')
echo "📖 Textbook Chunks: $TEXTBOOK_CHUNKS/36"

# Count completed documents
COMPLETED=$(curl -s http://localhost:8080/api/v1/documents | jq '[.[] | select(.status == "COMPLETED")] | length')
echo "✅ Completed Documents: $COMPLETED"

echo ""
echo "🌐 Web Interface: http://localhost:8080"
echo ""

echo "📋 SYSTEM COMPONENTS:"
echo "   ✅ Spring Boot Application"
echo "   ✅ PostgreSQL Database"
echo "   ✅ Ollama (nomic-embed-text + llama2)"
echo "   ✅ RAG Processing Pipeline"
echo "   ✅ Web Interface"
echo ""

echo "🎯 FEATURES:"
echo "   ✅ PDF Upload & Processing"
echo "   ✅ Text Extraction & Chunking"
echo "   ✅ Vector Embedding Generation"
echo "   ✅ Semantic Search"
echo "   ✅ AI-Powered Q&A"
echo "   ✅ Learning Level Selection"
echo "   ✅ Response Type Customization"
echo ""

echo "📖 HOW TO USE:"
echo "   1. Open http://localhost:8080 in your browser"
echo "   2. Select a document from the list"
echo "   3. Ask questions about the content"
echo "   4. Choose learning level (beginner/intermediate/advanced)"
echo "   5. Select response type (explanation/detailed/summary)"
echo ""

echo "🎓 SAMPLE QUESTIONS:"
echo "   • 'What is a matrix and how is it used?'"
echo "   • 'Explain eigenvalues and eigenvectors'"
echo "   • 'How do linear transformations work?'"
echo "   • 'What are the applications of linear algebra?'"
echo "   • 'Explain vector spaces and their properties'"
echo ""

echo "🚀 Your AI-powered study assistant is ready!"
echo "   Start learning with your Applied Linear Algebra textbook!"
