#!/bin/bash

echo "🔍 Railway Database Connection Test"
echo "=================================="

# Check if we're in Railway environment
echo "📋 Environment Check:"
echo "RAILWAY_ENVIRONMENT: $RAILWAY_ENVIRONMENT"
echo "RAILWAY_PROJECT_ID: $RAILWAY_PROJECT_ID"
echo ""

# Check for database environment variables
echo "🔑 Database Environment Variables:"
echo "DATABASE_URL: ${DATABASE_URL:0:50}..."
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:0:10}..."
echo "POSTGRES_HOST: $POSTGRES_HOST"
echo "POSTGRES_PORT: $POSTGRES_PORT"
echo "POSTGRES_DB: $POSTGRES_DB"
echo ""

# Check for Railway-specific variables
echo "🚂 Railway Variables:"
echo "RAILWAY_PRIVATE_DOMAIN: $RAILWAY_PRIVATE_DOMAIN"
echo "RAILWAY_TCP_PROXY_DOMAIN: $RAILWAY_TCP_PROXY_DOMAIN"
echo "RAILWAY_TCP_PROXY_PORT: $RAILWAY_TCP_PROXY_PORT"
echo ""

# Test network connectivity
echo "🌐 Network Connectivity Tests:"
echo "Testing postgres.railway.internal:5432..."
nc -zv postgres.railway.internal 5432 2>&1 || echo "❌ Failed to connect to postgres.railway.internal:5432"

echo "Testing maglev.proxy.rlwy.net:55026..."
nc -zv maglev.proxy.rlwy.net 55026 2>&1 || echo "❌ Failed to connect to maglev.proxy.rlwy.net:55026"

if [ ! -z "$RAILWAY_PRIVATE_DOMAIN" ]; then
    echo "Testing $RAILWAY_PRIVATE_DOMAIN:5432..."
    nc -zv $RAILWAY_PRIVATE_DOMAIN 5432 2>&1 || echo "❌ Failed to connect to $RAILWAY_PRIVATE_DOMAIN:5432"
fi

if [ ! -z "$RAILWAY_TCP_PROXY_DOMAIN" ]; then
    echo "Testing $RAILWAY_TCP_PROXY_DOMAIN:$RAILWAY_TCP_PROXY_PORT..."
    nc -zv $RAILWAY_TCP_PROXY_DOMAIN $RAILWAY_TCP_PROXY_PORT 2>&1 || echo "❌ Failed to connect to $RAILWAY_TCP_PROXY_DOMAIN:$RAILWAY_TCP_PROXY_PORT"
fi
echo ""

# Test PostgreSQL connection if we have credentials
echo "🐘 PostgreSQL Connection Tests:"

# Test with DATABASE_URL
if [ ! -z "$DATABASE_URL" ]; then
    echo "Testing with DATABASE_URL..."
    PGPASSWORD=$(echo $DATABASE_URL | sed 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/') psql "$DATABASE_URL" -c "SELECT version();" 2>&1 || echo "❌ Failed to connect with DATABASE_URL"
fi

# Test with individual components
if [ ! -z "$POSTGRES_USER" ] && [ ! -z "$POSTGRES_PASSWORD" ] && [ ! -z "$POSTGRES_HOST" ]; then
    echo "Testing with individual components..."
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p ${POSTGRES_PORT:-5432} -U $POSTGRES_USER -d ${POSTGRES_DB:-railway} -c "SELECT version();" 2>&1 || echo "❌ Failed to connect with individual components"
fi

# Test with Railway public URL
if [ ! -z "$RAILWAY_TCP_PROXY_DOMAIN" ] && [ ! -z "$RAILWAY_TCP_PROXY_PORT" ] && [ ! -z "$POSTGRES_USER" ] && [ ! -z "$POSTGRES_PASSWORD" ]; then
    echo "Testing with Railway public URL..."
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $RAILWAY_TCP_PROXY_DOMAIN -p $RAILWAY_TCP_PROXY_PORT -U $POSTGRES_USER -d ${POSTGRES_DB:-railway} -c "SELECT version();" 2>&1 || echo "❌ Failed to connect with Railway public URL"
fi

echo ""
echo "✅ Database connection test complete!"
