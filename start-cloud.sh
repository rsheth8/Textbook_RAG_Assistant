#!/bin/bash

echo "Starting Textbook RAG Assistant with cloud profile..."

# Start the application in the background
java -Xmx2g -Xms1g -XX:+UseG1GC -Dspring.profiles.active=cloud -jar target/textbook-rag-assistant-1.0.0.jar &

# Get the process ID
APP_PID=$!

echo "Application started with PID: $APP_PID"

# Wait for the application to be ready
echo "Waiting for application to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo "Application is ready!"
        break
    fi
    echo "Waiting... (attempt $i/30)"
    sleep 2
done

# Keep the script running
wait $APP_PID
