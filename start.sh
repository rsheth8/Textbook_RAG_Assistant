#!/bin/bash

# 🚀 Railway Startup Script for Textbook Assistant
# This script handles the startup process for Railway deployment

set -e

echo "🚀 Starting Textbook Assistant..."

# Find the JAR file
JAR_FILE=$(find target -name "*.jar" -type f | head -n 1)

if [ -z "$JAR_FILE" ]; then
    echo "❌ No JAR file found in target directory"
    echo "📁 Contents of target directory:"
    ls -la target/
    exit 1
fi

echo "📦 Found JAR file: $JAR_FILE"

# Set Java options
export JAVA_OPTS="-Xmx2g -Xms1g -XX:+UseG1GC -XX:+UseContainerSupport"

# Start the application
echo "🌐 Starting application with JAR: $JAR_FILE"
echo "⚙️  Java options: $JAVA_OPTS"
echo "🔧 Environment: $SPRING_PROFILES_ACTIVE"

exec java $JAVA_OPTS -jar "$JAR_FILE"
