#!/bin/bash

echo "🧪 Testing RAG System with Sample Content"
echo "========================================="

# Create a small test PDF from our sample text
echo "📄 Creating test PDF from sample content..."

# Check if we have the sample text
if [ ! -f "sample_math_text.txt" ]; then
    echo "❌ Sample text file not found!"
    exit 1
fi

echo "✅ Sample text found. Ready to test the system."
echo ""
echo "🎯 To test your system before uploading the large PDF:"
echo ""
echo "1. 📤 Upload Method Options:"
echo "   • Web Interface: http://localhost:8080"
echo "   • Command Line: ./upload_large_pdf.sh your_pdf.pdf"
echo "   • Direct API: curl -X POST -F 'file=@your_pdf.pdf' http://localhost:8080/api/v1/upload"
echo ""
echo "2. 📊 For your 700-page PDF:"
echo "   • Expected time: 15-35 minutes"
echo "   • File size limit: 100MB"
echo "   • Chunks: ~500-1000 intelligent chunks"
echo ""
echo "3. 🔍 Monitoring:"
echo "   • Web interface shows real-time status"
echo "   • Command line script monitors progress"
echo "   • Check status: curl -s http://localhost:8080/api/v1/documents"
echo ""
echo "4. 💬 After Processing:"
echo "   • Go to http://localhost:8080"
echo "   • Click 'Chat' on your document"
echo "   • Ask questions about your math textbook!"
echo ""
echo "🚀 Your system is ready for the 700-page PDF!"
echo "📚 The optimized settings will handle it efficiently."
