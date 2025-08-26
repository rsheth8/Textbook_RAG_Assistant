-- Create database
CREATE DATABASE textbook_assistant;

-- Connect to the database
\c textbook_assistant;

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create documents table
CREATE TABLE IF NOT EXISTS documents (
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
CREATE INDEX IF NOT EXISTS idx_documents_uploaded_at ON documents(uploaded_at);
CREATE INDEX IF NOT EXISTS idx_documents_filename ON documents(filename);

-- Create vector store table for Spring AI
CREATE TABLE IF NOT EXISTS vector_store (
    id BIGSERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    metadata JSONB,
    embedding VECTOR(384)
);

-- Create index for vector similarity search
CREATE INDEX IF NOT EXISTS idx_vector_store_embedding ON vector_store USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Create user (optional - adjust as needed)
-- CREATE USER textbook_user WITH PASSWORD 'your_password';
-- GRANT ALL PRIVILEGES ON DATABASE textbook_assistant TO textbook_user;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO textbook_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO textbook_user;
