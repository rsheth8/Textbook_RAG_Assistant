-- Fix database schema for document_chunks table
-- Drop and recreate the table with correct column types

DROP TABLE IF EXISTS document_chunks CASCADE;

CREATE TABLE document_chunks (
    id BIGSERIAL PRIMARY KEY,
    document_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    chunk_index INTEGER NOT NULL,
    embedding TEXT,  -- Changed from VARCHAR(255) to TEXT to handle large embeddings
    created_at TIMESTAMP NOT NULL,
    metadata TEXT
);

-- Create index for better query performance
CREATE INDEX idx_document_chunks_document_id ON document_chunks(document_id);
CREATE INDEX idx_document_chunks_chunk_index ON document_chunks(chunk_index);

-- Add foreign key constraint if documents table exists
-- ALTER TABLE document_chunks ADD CONSTRAINT fk_document_chunks_document_id 
--     FOREIGN KEY (document_id) REFERENCES documents(id);
