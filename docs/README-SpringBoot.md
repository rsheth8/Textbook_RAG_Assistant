# Math Textbook RAG Assistant - Spring Boot Version

A custom RAG (Retrieval-Augmented Generation) application built with Spring Boot and Spring AI, powered by Ollama models and PostgreSQL vector database, specifically designed to help you learn from math textbooks.

## Features

- **PDF Processing**: Extract and process math textbook content using Apache PDFBox
- **Vector Database**: Store embeddings in PostgreSQL with pgvector extension
- **Spring AI Integration**: Leverage Spring AI for document processing and vector operations
- **Ollama Integration**: Use local LLM models for inference
- **RAG Pipeline**: Intelligent retrieval and generation for math learning
- **Web Interface**: Thymeleaf-based UI for easy interaction
- **REST API**: Full RESTful API for integration
- **Summarization**: High-level summaries of textbook sections
- **Teaching Mode**: Interactive learning with step-by-step explanations

## Technology Stack

- **Backend**: Spring Boot 3.2.0
- **AI Framework**: Spring AI 0.8.0
- **Database**: PostgreSQL with pgvector extension
- **LLM**: Ollama (local models)
- **PDF Processing**: Apache PDFBox
- **Frontend**: Thymeleaf + Bootstrap 5
- **Build Tool**: Maven

## Prerequisites

1. **Java 17+**
2. **PostgreSQL 12+** with pgvector extension
3. **Ollama** installed and running locally
4. **Maven 3.6+**

## Setup Instructions

### 1. Install Prerequisites

#### Java 17+
```bash
# On macOS
brew install openjdk@17

# On Ubuntu
sudo apt update
sudo apt install openjdk-17-jdk

# Verify installation
java -version
```

#### PostgreSQL with pgvector
```bash
# Install PostgreSQL
# On macOS
brew install postgresql

# On Ubuntu
sudo apt install postgresql postgresql-contrib

# Install pgvector extension
# Follow instructions at: https://github.com/pgvector/pgvector
```

#### Ollama
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama
ollama serve

# Pull a model (in another terminal)
ollama pull llama2
# or for math-specific tasks
ollama pull codellama
```

### 2. Database Setup

```bash
# Connect to PostgreSQL
psql -U postgres

# Run the setup script
\i scripts/setup_database.sql
```

### 3. Application Configuration

Create `application-local.yml` for your environment:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/textbook_assistant
    username: your_username
    password: your_password

spring.ai:
  ollama:
    base-url: http://localhost:11434
    chat:
      options:
        model: llama2
        temperature: 0.7
        max-tokens: 2048

app:
  upload:
    dir: ./data/uploads
  processed:
    dir: ./data/processed
```

### 4. Build and Run

```bash
# Build the application
mvn clean package

# Run with local profile
java -jar target/textbook-rag-assistant-1.0.0.jar --spring.profiles.active=local

# Or run with Maven
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

### 5. Access the Application

- **Web Interface**: http://localhost:8080
- **REST API**: http://localhost:8080/api/v1
- **Health Check**: http://localhost:8080/api/v1/health

## API Endpoints

### File Upload
```
POST /api/v1/upload
Content-Type: multipart/form-data
Body: file (PDF)
```

### Query Processing
```
POST /api/v1/query
Content-Type: application/json
Body: {
  "query": "What is calculus?",
  "documentId": 1,
  "learningLevel": "intermediate",
  "responseType": "explanation",
  "maxResults": 5
}
```

### Document Management
```
GET /api/v1/documents          # List all documents
GET /api/v1/documents/{id}     # Get specific document
DELETE /api/v1/documents/{id}  # Delete document
```

## Usage Guide

### 1. Upload a Math Textbook
1. Navigate to http://localhost:8080
2. Drag and drop your PDF or click "Choose File"
3. Click "Upload PDF"
4. Wait for processing to complete

### 2. Chat with Your Textbook
1. Click "Chat" on any processed document
2. Select your learning level (Beginner/Intermediate/Advanced)
3. Ask questions about the material
4. Get intelligent responses based on the textbook content

### 3. Example Questions
- "What is the fundamental theorem of calculus?"
- "Explain derivatives in simple terms"
- "Summarize chapter 3"
- "How do I solve quadratic equations?"
- "What are the applications of integration?"

## Project Structure

```
src/
├── main/
│   ├── java/com/textbookassistant/
│   │   ├── TextbookRagAssistantApplication.java
│   │   ├── config/
│   │   │   └── SpringAiConfig.java
│   │   ├── controller/
│   │   │   ├── RagController.java
│   │   │   └── WebController.java
│   │   ├── dto/
│   │   │   ├── QueryRequest.java
│   │   │   ├── QueryResponse.java
│   │   │   └── UploadResponse.java
│   │   ├── model/
│   │   │   └── Document.java
│   │   ├── repository/
│   │   │   └── DocumentRepository.java
│   │   └── service/
│   │       ├── PdfProcessingService.java
│   │       └── RagService.java
│   └── resources/
│       ├── application.yml
│       └── templates/
│           ├── index.html
│           └── chat.html
├── scripts/
│   └── setup_database.sql
└── pom.xml
```

## Configuration Options

### Ollama Models
You can use different Ollama models by changing the configuration:

```yaml
spring.ai:
  ollama:
    chat:
      options:
        model: codellama    # Better for math/code
        # model: llama2     # General purpose
        # model: mistral    # Good balance
```

### Vector Store Settings
```yaml
spring.ai:
  vectorstore:
    pgvector:
      dimensions: 384
      similarity-search-top-k: 5
      initialize-schema: true
```

### Chunking Configuration
```yaml
app:
  chunk:
    size: 1000      # Characters per chunk
    overlap: 200    # Overlap between chunks
```

## Development

### Running Tests
```bash
mvn test
```

### Code Formatting
```bash
mvn spring-javaformat:apply
```

### Docker Support
```bash
# Build Docker image
docker build -t textbook-rag-assistant .

# Run with Docker
docker run -p 8080:8080 textbook-rag-assistant
```

## Troubleshooting

### Common Issues

1. **PostgreSQL Connection Error**
   - Verify PostgreSQL is running
   - Check database credentials in application.yml
   - Ensure pgvector extension is installed

2. **Ollama Connection Error**
   - Verify Ollama is running: `ollama serve`
   - Check if model is downloaded: `ollama list`
   - Test connection: `curl http://localhost:11434/api/tags`

3. **PDF Processing Issues**
   - Ensure PDF is not corrupted
   - Check file size limits in application.yml
   - Verify upload directory permissions

4. **Vector Store Issues**
   - Ensure pgvector extension is enabled
   - Check database schema setup
   - Verify embedding dimensions match configuration

## Performance Optimization

1. **Database Indexing**: Ensure proper indexes on vector columns
2. **Chunk Size**: Adjust based on your content and requirements
3. **Model Selection**: Choose appropriate Ollama model for your use case
4. **Caching**: Consider adding Redis for response caching

## Security Considerations

1. **File Upload**: Validate file types and sizes
2. **Database**: Use strong passwords and proper access controls
3. **API**: Implement rate limiting for production use
4. **Environment**: Use environment variables for sensitive configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Spring AI documentation
3. Check Ollama documentation
4. Open an issue on GitHub
