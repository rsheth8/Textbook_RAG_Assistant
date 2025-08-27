-- Manual Database Setup for Railway PostgreSQL
-- Run this in Railway's PostgreSQL console if the app can't connect

-- Create the documents table
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

-- Create the document_chunks table
CREATE TABLE IF NOT EXISTS document_chunks (
    id BIGSERIAL PRIMARY KEY,
    document_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    chunk_index INTEGER NOT NULL,
    embedding TEXT,
    created_at TIMESTAMP NOT NULL,
    metadata TEXT
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
CREATE INDEX IF NOT EXISTS idx_documents_uploaded_at ON documents(uploaded_at);
CREATE INDEX IF NOT EXISTS idx_document_chunks_document_id ON document_chunks(document_id);
CREATE INDEX IF NOT EXISTS idx_document_chunks_chunk_index ON document_chunks(chunk_index);

-- Grant permissions (if needed)
GRANT ALL PRIVILEGES ON TABLE documents TO postgres;
GRANT ALL PRIVILEGES ON TABLE document_chunks TO postgres;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Verify tables were created
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('documents', 'document_chunks');
