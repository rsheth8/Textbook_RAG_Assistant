#!/bin/bash

# Demo script for chapter-based organization

echo "📚 CHAPTER-BASED TEXTBOOK ORGANIZATION - DEMO"
echo "=============================================="
echo ""

echo "✅ NEW FEATURES:"
echo "   📖 Chapter-Based Organization - Organized by actual textbook chapters"
echo "   🎯 Descriptive Chapter Names - Clear, meaningful chapter titles"
echo "   📄 Page Range Mapping - Know exactly which pages each chapter covers"
echo "   🔍 Chapter-Specific Search - Search within specific chapters"
echo "   🌐 Global Search - Still search across entire textbook"
echo ""

echo "📖 CHAPTER STRUCTURE:"
echo "====================="
echo ""

# Display chapter information from the mapping
chapters=$(curl -s http://localhost:8080/chapter_mapping.json | jq -r '.chapters[] | "\(.id). \(.name) (\(.pageRange))"')

echo "$chapters" | while IFS= read -r line; do
    echo "📖 $line"
done

echo ""
echo "🎯 SEARCH MODES:"
echo "================"
echo "🌐 Global Search: Search across ALL chapters for comprehensive answers"
echo "📚 Chapter Search: Focus on specific chapters for targeted answers"
echo ""

echo "🚀 WEB INTERFACE FEATURES:"
echo "=========================="
echo "✅ Chapter selection with descriptions"
echo "✅ Page range information for each chapter"
echo "✅ Part-based organization within chapters"
echo "✅ Easy switching between global and chapter search"
echo "✅ Modern, intuitive UI design"
echo ""

echo "📊 SYSTEM STATUS:"
echo "================="
curl -s http://localhost:8080/api/v1/health > /dev/null && echo "✅ Application: RUNNING" || echo "❌ Application: OFFLINE"

CHAPTER_COUNT=$(curl -s http://localhost:8080/chapter_mapping.json | jq '.chapters | length' 2>/dev/null || echo "0")
echo "📚 Total Chapters: $CHAPTER_COUNT"

DOC_COUNT=$(curl -s http://localhost:8080/api/v1/documents | jq 'length' 2>/dev/null || echo "0")
echo "📄 Total Documents: $DOC_COUNT"

echo ""
echo "🎓 SAMPLE CHAPTER-SPECIFIC QUESTIONS:"
echo "====================================="
echo "📖 Chapter 1: 'What are the fundamental concepts of linear algebra?'"
echo "📖 Chapter 2: 'How do I solve systems of linear equations?'"
echo "📖 Chapter 3: 'What are the basic matrix operations?'"
echo "📖 Chapter 4: 'Explain vector spaces and subspaces'"
echo "📖 Chapter 6: 'What are eigenvalues and eigenvectors?'"
echo "📖 Chapter 8: 'How does orthogonality work in linear algebra?'"
echo ""

echo "🌐 GLOBAL SEARCH QUESTIONS:"
echo "==========================="
echo "• 'How do matrices relate to linear transformations?'"
echo "• 'What are the applications of eigenvalues in real-world problems?'"
echo "• 'Explain the relationship between vector spaces and inner products'"
echo "• 'How does diagonalization work and why is it important?'"
echo ""

echo "🚀 HOW TO USE:"
echo "=============="
echo "1. Open http://localhost:8080"
echo "2. Choose search mode: Global or Chapter-specific"
echo "3. If chapter-specific, select the desired chapter"
echo "4. Ask your question and get targeted answers!"
echo ""

echo "🎉 Your textbook is now organized by actual chapters!"
echo "   Navigate easily and get focused, relevant answers!"
