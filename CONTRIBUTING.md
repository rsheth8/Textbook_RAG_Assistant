# Contributing to Textbook RAG Assistant

Retrieval today is **keyword scoring**, not embeddings. Don't describe PRs as "vector RAG" unless you actually wire pgvector.

## Prerequisites
- Java 17, Maven (or `./mvnw`)
- Docker (Postgres)
- Ollama locally (`ollama pull gemma2`)

## Run
```bash
cp env.example .env
docker-compose up -d postgres
./mvnw spring-boot:run
```

http://localhost:8080

## Tests
```bash
./mvnw test
```

Don't commit uploaded PDFs or `.env`.
