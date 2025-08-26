#!/bin/bash

echo "=========================================="
echo "🔍 Railway Environment Debug Script"
echo "=========================================="

echo "Environment Variables:"
echo "PORT: ${PORT:-'NOT SET'}"
echo "DATABASE_URL: ${DATABASE_URL:-'NOT SET'}"
echo "POSTGRES_USER: ${POSTGRES_USER:-'NOT SET'}"
echo "POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-'NOT SET'}"
echo "OLLAMA_BASE_URL: ${OLLAMA_BASE_URL:-'NOT SET'}"
echo "OLLAMA_MODEL: ${OLLAMA_MODEL:-'NOT SET'}"
echo "OLLAMA_EMBEDDING_MODEL: ${OLLAMA_EMBEDDING_MODEL:-'NOT SET'}"
echo ""

echo "Java Version:"
java -version
echo ""

echo "Available Memory:"
free -h 2>/dev/null || echo "free command not available"
echo ""

echo "Current Directory:"
pwd
echo ""

echo "Files in current directory:"
ls -la
echo ""

echo "Testing if we can start the application..."
echo "Starting with cloud profile and PORT=${PORT:-8080}..."

# Start the application with the same command Railway uses
java -Xmx2g -Xms1g -XX:+UseG1GC -Dspring.profiles.active=cloud -jar target/textbook-rag-assistant-1.0.0.jar &
APP_PID=$!

echo "Application started with PID: $APP_PID"

# Wait for startup
sleep 10

echo ""
echo "Testing health endpoint..."
HEALTH_URL="http://localhost:${PORT:-8080}/health"
echo "Health URL: $HEALTH_URL"

# Test the health endpoint
response=$(curl -s -w "%{http_code}" --max-time 10 "$HEALTH_URL" 2>/dev/null)
http_code="${response: -3}"
body="${response%???}"

echo "HTTP Status: $http_code"
echo "Response: $body"

if [ "$http_code" = "200" ]; then
    echo "✅ Health check passed!"
else
    echo "❌ Health check failed!"
    
    echo ""
    echo "Testing other endpoints..."
    curl -s "http://localhost:${PORT:-8080}/ping" || echo "Ping failed"
    curl -s "http://localhost:${PORT:-8080}/api/v1/health" || echo "API health failed"
fi

# Clean up
echo ""
echo "Stopping application..."
kill $APP_PID
wait $APP_PID 2>/dev/null

echo "Debug complete!"
