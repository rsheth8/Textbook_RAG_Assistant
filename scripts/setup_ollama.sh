#!/bin/bash

echo "🚀 Setting up Ollama models for Textbook RAG Assistant..."

# Wait for Ollama to be ready
echo "⏳ Waiting for Ollama to be ready..."
until curl -f http://localhost:11434/api/tags > /dev/null 2>&1; do
    echo "Waiting for Ollama to start..."
    sleep 5
done

echo "✅ Ollama is ready!"

       # Pull the required models
       echo "📥 Pulling qwen3:0.6b model for chat..."
       curl -X POST http://localhost:11434/api/pull -d '{"name": "qwen3:0.6b"}'

echo "📥 Pulling nomic-embed-text model for embeddings..."
curl -X POST http://localhost:11434/api/pull -d '{"name": "nomic-embed-text"}'

echo "✅ All models pulled successfully!"
echo "🎉 Ollama setup complete!"
