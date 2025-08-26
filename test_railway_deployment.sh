#!/bin/bash

echo "=========================================="
echo "🚀 Railway Deployment Test Script"
echo "=========================================="

# Get the Railway app URL from environment or prompt user
if [ -z "$RAILWAY_APP_URL" ]; then
    echo "Please enter your Railway app URL (e.g., https://your-app.railway.app):"
    read RAILWAY_APP_URL
fi

echo ""
echo "📋 Testing Railway Deployment..."
echo "App URL: $RAILWAY_APP_URL"
echo ""

# Test basic connectivity
echo "🔍 Testing basic connectivity..."
if curl -s --max-time 10 "$RAILWAY_APP_URL" > /dev/null; then
    echo "✅ Basic connectivity: OK"
else
    echo "❌ Basic connectivity: FAILED"
    echo "   The app might not be running or accessible"
    exit 1
fi

# Test health endpoint
echo ""
echo "🏥 Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s --max-time 10 "$RAILWAY_APP_URL/health" 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$HEALTH_RESPONSE" ]; then
    echo "✅ Health endpoint (/health): OK"
    echo "   Response: $HEALTH_RESPONSE"
else
    echo "❌ Health endpoint (/health): FAILED"
fi

# Test actuator health endpoint
echo ""
echo "🔧 Testing actuator health endpoint..."
ACTUATOR_RESPONSE=$(curl -s --max-time 10 "$RAILWAY_APP_URL/actuator/health" 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$ACTUATOR_RESPONSE" ]; then
    echo "✅ Actuator health endpoint (/actuator/health): OK"
    echo "   Response: $ACTUATOR_RESPONSE"
else
    echo "❌ Actuator health endpoint (/actuator/health): FAILED"
fi

# Test API health endpoint
echo ""
echo "🌐 Testing API health endpoint..."
API_RESPONSE=$(curl -s --max-time 10 "$RAILWAY_APP_URL/api/v1/health" 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$API_RESPONSE" ]; then
    echo "✅ API health endpoint (/api/v1/health): OK"
    echo "   Response: $API_RESPONSE"
else
    echo "❌ API health endpoint (/api/v1/health): FAILED"
fi

echo ""
echo "=========================================="
echo "📋 Next Steps:"
echo "1. If any endpoints failed, check Railway logs"
echo "2. Verify environment variables are set in Railway"
echo "3. Check if PostgreSQL is connected properly"
echo "4. Ensure the application is using 'cloud' profile"
echo "=========================================="
