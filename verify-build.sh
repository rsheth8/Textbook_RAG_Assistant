#!/bin/bash

echo "🔍 Verifying build..."

# Check if target directory exists
if [ ! -d "target" ]; then
    echo "❌ Target directory not found"
    exit 1
fi

# List contents of target directory
echo "📁 Contents of target directory:"
ls -la target/

# Find JAR files
JAR_FILES=$(find target -name "*.jar" -type f)
if [ -z "$JAR_FILES" ]; then
    echo "❌ No JAR files found in target directory"
    exit 1
fi

echo "✅ Found JAR files:"
echo "$JAR_FILES"

# Check if our specific JAR exists
if [ -f "target/textbook-rag-assistant-1.0.0.jar" ]; then
    echo "✅ Main JAR file exists: target/textbook-rag-assistant-1.0.0.jar"
    echo "📦 JAR file size: $(ls -lh target/textbook-rag-assistant-1.0.0.jar | awk '{print $5}')"
else
    echo "⚠️  Main JAR file not found, but other JAR files exist"
    echo "📦 Available JAR files:"
    for jar in $JAR_FILES; do
        echo "   - $jar ($(ls -lh "$jar" | awk '{print $5}'))"
    done
fi

echo "🎉 Build verification complete!"
