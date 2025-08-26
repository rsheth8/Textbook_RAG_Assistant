#!/bin/bash

echo "🚀 Starting Textbook RAG Assistant (Minimal Mode)..."

# Set Java options
export JAVA_OPTS="-Xmx2g -Xms1g -XX:+UseG1GC -XX:+UseContainerSupport"

# Set Spring profile
export SPRING_PROFILES_ACTIVE=simple

# Set server port
export PORT=${PORT:-8080}

echo "📋 Configuration:"
echo "   - Java Options: $JAVA_OPTS"
echo "   - Spring Profile: $SPRING_PROFILES_ACTIVE"
echo "   - Server Port: $PORT"
echo "   - Working Directory: $(pwd)"

# Check if JAR file exists
JAR_FILE="target/textbook-rag-assistant-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "❌ JAR file not found: $JAR_FILE"
    echo "📁 Available files in target/:"
    ls -la target/ 2>/dev/null || echo "   Target directory not found"
    exit 1
fi

echo "✅ JAR file found: $JAR_FILE"
echo "📦 JAR file size: $(ls -lh "$JAR_FILE" | awk '{print $5}')"

# Start the application
echo "🚀 Starting application..."
echo "=================================="

exec java $JAVA_OPTS \
    -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE \
    -Dserver.port=$PORT \
    -jar "$JAR_FILE"
