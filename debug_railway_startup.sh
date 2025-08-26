#!/bin/bash

echo "🔍 Railway Startup Debug Script"
echo "==============================="

echo ""
echo "📋 Environment Variables Check:"
echo "DATABASE_URL: ${DATABASE_URL:-NOT SET}"
echo "OLLAMA_BASE_URL: ${OLLAMA_BASE_URL:-NOT SET}"
echo "OLLAMA_MODEL: ${OLLAMA_MODEL:-NOT SET}"
echo "OLLAMA_EMBEDDING_MODEL: ${OLLAMA_EMBEDDING_MODEL:-NOT SET}"

echo ""
echo "🔧 Java Version:"
java -version 2>&1

echo ""
echo "📦 JAR File Check:"
if [ -f "target/textbook-rag-assistant-1.0.0.jar" ]; then
    echo "✅ JAR file exists"
    ls -la target/textbook-rag-assistant-1.0.0.jar
else
    echo "❌ JAR file not found"
    echo "Available files in target/:"
    ls -la target/ 2>/dev/null || echo "No target directory"
fi

echo ""
echo "🚀 Testing Cloud Profile Startup:"
echo "Starting application with cloud profile..."

# Start the app in background
java -Xmx2g -Xms1g -XX:+UseG1GC -Dspring.profiles.active=cloud -jar target/textbook-rag-assistant-1.0.0.jar > startup.log 2>&1 &
APP_PID=$!

echo "Application started with PID: $APP_PID"

# Wait a bit for startup
sleep 10

echo ""
echo "📊 Startup Log (last 20 lines):"
tail -20 startup.log

echo ""
echo "🔍 Health Check Test:"
for i in {1..5}; do
    echo "Attempt $i:"
    curl -s http://localhost:8080/health 2>&1 || echo "Health check failed"
    echo ""
    sleep 2
done

echo ""
echo "🛑 Stopping application..."
kill $APP_PID 2>/dev/null
wait $APP_PID 2>/dev/null

echo ""
echo "✅ Debug script completed"
