#!/bin/bash

echo "Setting up PostgreSQL with pgvector using Docker..."

# Stop any existing containers
docker stop textbook_assistant_db 2>/dev/null || true
docker rm textbook_assistant_db 2>/dev/null || true

# Run PostgreSQL with pgvector
docker run -d \
  --name textbook_assistant_db \
  -e POSTGRES_DB=textbook_assistant \
  -e POSTGRES_USER=textbook_user \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  pgvector/pgvector:pg16

echo "Waiting for PostgreSQL to start..."
sleep 10

# Test connection
echo "Testing connection..."
docker exec textbook_assistant_db psql -U textbook_user -d textbook_assistant -c "SELECT version();"

echo "Enabling pgvector extension..."
docker exec textbook_assistant_db psql -U textbook_user -d textbook_assistant -c "CREATE EXTENSION IF NOT EXISTS vector;"

echo "Setting up database schema..."
docker exec -i textbook_assistant_db psql -U textbook_user -d textbook_assistant < scripts/setup_database.sql

echo "PostgreSQL setup complete!"
echo "Connection details:"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  Database: textbook_assistant"
echo "  Username: textbook_user"
echo "  Password: password"
