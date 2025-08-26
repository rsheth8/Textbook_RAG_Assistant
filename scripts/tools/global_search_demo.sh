#!/bin/bash

# Demo script for global textbook search

echo "🎉 GLOBAL TEXTBOOK SEARCH - DEMO"
echo "================================="
echo ""

echo "✅ NEW FEATURES:"
echo "   🌐 Global Textbook Search - Search across ALL chapters"
echo "   📚 Comprehensive Answers - Use entire textbook as context"
echo "   🎯 Smart Chunk Selection - Find most relevant content"
echo "   🔄 Dual Search Modes - Global or chapter-specific"
echo ""

echo "🌐 GLOBAL SEARCH MODE:"
echo "   • Searches across ALL 36 textbook chunks"
echo "   • Combines relevant content from multiple chapters"
echo "   • Provides comprehensive, textbook-wide answers"
echo "   • Perfect for broad questions and cross-chapter topics"
echo ""

echo "📄 SPECIFIC SEARCH MODE:"
echo "   • Focus on individual chapters"
echo "   • Detailed answers from specific content"
echo "   • Useful for chapter-specific questions"
echo ""

echo "🎓 SAMPLE GLOBAL SEARCH QUESTIONS:"
echo "   • 'What is linear algebra and what are its applications?'"
echo "   • 'Explain eigenvalues and eigenvectors in detail'"
echo "   • 'How do matrices relate to linear transformations?'"
echo "   • 'What are the fundamental concepts of vector spaces?'"
echo "   • 'Explain the relationship between determinants and invertibility'"
echo ""

echo "🚀 HOW TO USE:"
echo "   1. Open http://localhost:8080"
echo "   2. Select '🌐 Search Entire Textbook' (default)"
echo "   3. Ask any question about the material"
echo "   4. Get comprehensive answers using all chapters!"
echo ""

echo "📊 SYSTEM STATUS:"
curl -s http://localhost:8080/api/v1/health > /dev/null && echo "   ✅ Application: RUNNING" || echo "   ❌ Application: OFFLINE"

DOC_COUNT=$(curl -s http://localhost:8080/api/v1/documents | jq 'length' 2>/dev/null || echo "0")
echo "   📚 Total Documents: $DOC_COUNT"

echo ""
echo "🎯 TEST GLOBAL SEARCH:"
echo "   The system will now search across ALL textbook chunks"
echo "   to provide comprehensive answers to your questions!"
echo ""
echo "🌐 Your AI now has access to the ENTIRE textbook!"
