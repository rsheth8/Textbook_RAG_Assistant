#!/bin/bash

echo "🔍 Railway Service Connection Test"
echo "=================================="

echo ""
echo "📋 Testing Ollama Connection:"
echo "1. Go to your Textbook_RAG_Assistant service"
echo "2. Go to 'Deployments' → 'Console'"
echo "3. Run this command:"
echo "   curl -s http://ollama:11434/api/tags"
echo ""

echo "📋 Testing PostgreSQL Connection:"
echo "1. In the same console, run:"
echo "   curl -s http://postgres.railway.internal:5432"
echo ""

echo "📋 Check App Logs:"
echo "1. Go to Textbook_RAG_Assistant → 'Logs'"
echo "2. Look for these messages:"
echo "   - 'Ollama connection successful'"
echo "   - 'Database connection test successful'"
echo "   - Any error messages about connections"
echo ""

echo "📋 Test Ollama Models:"
echo "1. In the console, run:"
echo "   curl -s http://ollama:11434/api/tags | jq ."
echo "2. This should show your installed models"
echo ""

echo "📋 Manual Ollama Test:"
echo "1. Go to Ollama service → 'Console'"
echo "2. Run: ollama list"
echo "3. This should show llama2 and nomic-embed-text"
echo ""

echo "🎯 Expected Results:"
echo "- Ollama API should respond with model list"
echo "- PostgreSQL should show connection info"
echo "- App logs should show successful connections"
echo ""

echo "❌ If Connections Fail:"
echo "- Check if services are running"
echo "- Verify network connectivity"
echo "- Check environment variables"
echo "- Look for specific error messages"
