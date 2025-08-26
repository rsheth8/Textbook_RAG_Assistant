#!/bin/bash

echo "🔧 Fixing Database Schema"
echo "========================"

echo "Connecting to database and fixing processed_at column..."

# Use docker exec to run the SQL command
docker exec textbook_assistant_db psql -U textbook_user -d textbook_assistant -c "ALTER TABLE documents ALTER COLUMN processed_at DROP NOT NULL;"

if [ $? -eq 0 ]; then
    echo "✅ Database schema fixed successfully!"
    echo "The processed_at column now allows null values."
else
    echo "❌ Failed to fix database schema"
    echo "Trying alternative approach..."
    
    # Alternative: Drop and recreate the table
    echo "Dropping and recreating documents table..."
    docker exec textbook_assistant_db psql -U textbook_user -d textbook_assistant -c "
    DROP TABLE IF EXISTS documents CASCADE;
    CREATE TABLE documents (
        id BIGSERIAL PRIMARY KEY,
        filename VARCHAR(255) NOT NULL,
        original_filename VARCHAR(255) NOT NULL,
        file_path VARCHAR(500) NOT NULL,
        file_size BIGINT NOT NULL,
        content_type VARCHAR(100) NOT NULL,
        extracted_text TEXT,
        uploaded_at TIMESTAMP NOT NULL,
        processed_at TIMESTAMP,
        status VARCHAR(20) NOT NULL,
        total_chunks INTEGER,
        error_message TEXT
    );
    CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
    CREATE INDEX IF NOT EXISTS idx_documents_uploaded_at ON documents(uploaded_at);
    CREATE INDEX IF NOT EXISTS idx_documents_filename ON documents(filename);
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Documents table recreated successfully!"
    else
        echo "❌ Failed to recreate table"
        exit 1
    fi
fi

echo ""
echo "🎯 Database is now ready for PDF uploads!"
