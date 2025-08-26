#!/bin/bash

echo "🔍 Railway Database Connection Debug Script"
echo "=========================================="

echo ""
echo "📋 Environment Variables:"
echo "DATABASE_URL: ${DATABASE_URL:-NOT SET}"
echo "POSTGRES_USER: ${POSTGRES_USER:-NOT SET}"
echo "POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-NOT SET}"
echo "POSTGRES_HOST: ${POSTGRES_HOST:-NOT SET}"
echo "POSTGRES_PORT: ${POSTGRES_PORT:-NOT SET}"
echo "POSTGRES_DB: ${POSTGRES_DB:-NOT SET}"

echo ""
echo "🌐 Network Connectivity:"
if [ -n "$POSTGRES_HOST" ]; then
    echo "Testing connection to $POSTGRES_HOST:$POSTGRES_PORT..."
    nc -zv "$POSTGRES_HOST" "${POSTGRES_PORT:-5432}" 2>&1 || echo "❌ Connection failed"
else
    echo "No POSTGRES_HOST found, trying to extract from DATABASE_URL..."
    if [[ "$DATABASE_URL" =~ postgresql://[^:]+:[^@]+@([^:]+):([^/]+)/(.+) ]]; then
        HOST="${BASH_REMATCH[1]}"
        PORT="${BASH_REMATCH[2]}"
        echo "Extracted HOST: $HOST, PORT: $PORT"
        nc -zv "$HOST" "$PORT" 2>&1 || echo "❌ Connection failed"
    fi
fi

echo ""
echo "🐘 PostgreSQL Client Test:"
if command -v psql &> /dev/null; then
    echo "psql is available"
    if [ -n "$DATABASE_URL" ]; then
        echo "Testing with psql..."
        timeout 10 psql "$DATABASE_URL" -c "SELECT version();" 2>&1 || echo "❌ psql connection failed"
    fi
else
    echo "psql not available"
fi

echo ""
echo "🔧 Java Version:"
java -version 2>&1

echo ""
echo "📦 Available JARs:"
ls -la target/*.jar 2>/dev/null || echo "No JAR files found in target/"

echo ""
echo "🚀 Railway Environment Info:"
echo "PORT: ${PORT:-NOT SET}"
echo "RAILWAY_ENVIRONMENT: ${RAILWAY_ENVIRONMENT:-NOT SET}"
echo "RAILWAY_PROJECT_ID: ${RAILWAY_PROJECT_ID:-NOT SET}"
echo "RAILWAY_SERVICE_ID: ${RAILWAY_SERVICE_ID:-NOT SET}"

echo ""
echo "✅ Debug script completed"
