#!/bin/bash

echo "=========================================="
echo "🚀 Railway Health Check Emulator"
echo "=========================================="

# Configuration (matching Railway's behavior)
HEALTH_ENDPOINT="/health"
TIMEOUT_SECONDS=300
RETRY_INTERVAL=5
MAX_ATTEMPTS=$((TIMEOUT_SECONDS / RETRY_INTERVAL))

echo "Configuration:"
echo "- Health endpoint: $HEALTH_ENDPOINT"
echo "- Timeout: ${TIMEOUT_SECONDS}s"
echo "- Retry interval: ${RETRY_INTERVAL}s"
echo "- Max attempts: $MAX_ATTEMPTS"
echo ""

# Start the application
echo "📦 Starting application..."
java -Dspring.profiles.active=cloud -Dserver.port=8080 -jar target/textbook-rag-assistant-1.0.0.jar &
APP_PID=$!

echo "Application started with PID: $APP_PID"
echo ""

# Wait a bit for initial startup
echo "⏳ Waiting for initial startup..."
sleep 5

# Health check loop (emulating Railway's behavior)
echo "🔍 Starting health checks..."
for attempt in $(seq 1 $MAX_ATTEMPTS); do
    echo "Attempt #$attempt/$MAX_ATTEMPTS"
    
    # Try to connect to the health endpoint
    response=$(curl -s -w "%{http_code}" --max-time 10 "http://localhost:8080$HEALTH_ENDPOINT" 2>/dev/null)
    http_code="${response: -3}"
    body="${response%???}"
    
    echo "  HTTP Status: $http_code"
    echo "  Response: $body"
    
    # Check if health check passed
    if [ "$http_code" = "200" ]; then
        echo ""
        echo "✅ HEALTH CHECK PASSED!"
        echo "Application is healthy and ready to serve requests."
        echo ""
        echo "📋 Health check details:"
        echo "- Status: $http_code"
        echo "- Response: $body"
        echo "- Total attempts: $attempt"
        echo "- Time elapsed: $((attempt * RETRY_INTERVAL))s"
        
        # Keep the application running for a bit to show it's stable
        echo ""
        echo "🔄 Keeping application running for 30 seconds to verify stability..."
        sleep 30
        
        # Clean up
        echo "🧹 Stopping application..."
        kill $APP_PID
        wait $APP_PID 2>/dev/null
        
        echo "✅ Railway health check emulation completed successfully!"
        exit 0
    else
        echo "  ❌ Health check failed (HTTP $http_code)"
        
        if [ $attempt -lt $MAX_ATTEMPTS ]; then
            echo "  ⏳ Waiting ${RETRY_INTERVAL}s before next attempt..."
            sleep $RETRY_INTERVAL
        fi
    fi
done

# If we get here, health checks failed
echo ""
echo "❌ HEALTH CHECK FAILED!"
echo "Application did not become healthy within ${TIMEOUT_SECONDS}s"
echo "Total attempts: $MAX_ATTEMPTS"
echo ""

# Clean up
echo "🧹 Stopping application..."
kill $APP_PID
wait $APP_PID 2>/dev/null

echo "❌ Railway health check emulation failed!"
exit 1
