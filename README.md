# 📚 Textbook Assistant - RAG-Powered Learning System

A sophisticated Retrieval-Augmented Generation (RAG) application that provides AI-powered tutoring based on your specific textbook content. The system ensures faithful adherence to your textbook's teaching style, terminology, and approach.

## 🌟 **Live Demo**

**Live Application**: https://textbookragassistant-production.up.railway.app

**GitHub Repository**: https://github.com/rsheth8/Textbook_RAG_Assistant

## 🎯 **Key Features**

- **📖 Textbook-Faithful AI**: Teaches EXACTLY as your textbook teaches
- **🌐 Global Textbook Search**: Access to entire textbook content simultaneously
- **📚 Chapter Organization**: Organized by actual textbook chapters
- **🎨 Modern UI**: Beautiful gradient interface with responsive design
- **⚡ Real-time Processing**: Instant answers with comprehensive context
- **🔒 Local AI**: Powered by Ollama for privacy and control
- **☁️ Cloud Deployed**: Available online via Railway

## 🏗️ **Project Structure**

```
TextbookAssistant/
├── 📁 src/                    # Spring Boot application source
│   ├── main/java/            # Java source code
│   ├── main/resources/       # Configuration and templates
│   └── test/                 # Unit tests
├── 📁 docs/                  # Documentation
├── 📁 scripts/               # Utility scripts
├── 📁 data/                  # Data storage
├── 📁 target/               # Compiled application
├── 📄 pom.xml               # Maven dependencies
├── 📄 docker-compose.yml    # Docker services
├── 📄 Dockerfile            # Application container
├── 📄 railway.json          # Railway deployment config
├── 📄 railway.toml          # Railway deployment config
├── 📄 nixpacks.toml         # Railway build config
├── 📄 Procfile              # Railway startup config
└── 📄 env.example           # Environment variables template
```

## 🚀 **Quick Start**

### **Prerequisites**
- Java 17 or higher
- Maven 3.6+
- Docker and Docker Compose
- Ollama with `llama2` and `nomic-embed-text` models

### **1. Local Setup**
```bash
# Clone the repository
git clone https://github.com/rsheth8/Textbook_RAG_Assistant.git
cd Textbook_RAG_Assistant

# Copy environment template
cp env.example .env

# Start PostgreSQL database
docker-compose up -d postgres

# Install Ollama models
ollama pull llama2
ollama pull nomic-embed-text
```

### **2. Build and Run**
```bash
# Build the application
mvn clean package

# Run with increased memory
MAVEN_OPTS="-Xmx8g -Xms4g" mvn spring-boot:run
```

### **3. Access the Application**
- **Web Interface**: http://localhost:8080
- **Health Check**: http://localhost:8080/health

## ☁️ **Cloud Deployment (Railway)**

### **Deployment Status**
✅ **Successfully Deployed**: https://textbookragassistant-production.up.railway.app

### **Environment Variables**
The following environment variables are configured in Railway:

#### **Ollama Configuration**
```
OLLAMA_BASE_URL=https://api.ollama.ai
OLLAMA_MODEL=llama2
OLLAMA_EMBEDDING_MODEL=nomic-embed-text
OLLAMA_TEMPERATURE=0.7
OLLAMA_MAX_TOKENS=2048
```

#### **Application Configuration**
```
CHUNK_SIZE=300
CHUNK_OVERLAP=50
MAX_RETRIEVAL_RESULTS=3
UPLOAD_DIR=/tmp/uploads
PROCESSED_DIR=/tmp/processed
```

#### **Database Configuration**
- **PostgreSQL**: Automatically provided by Railway
- **Fallback**: H2 in-memory database if PostgreSQL fails

### **Deployment Features**
- ✅ **Automatic Health Checks**: `/health` endpoint
- ✅ **Robust Fallback**: H2 database if PostgreSQL unavailable
- ✅ **Enhanced Logging**: Detailed connection and error reporting
- ✅ **Memory Optimization**: 2GB heap size for large documents
- ✅ **Connection Pooling**: Optimized for cloud environment

## 📖 **Usage Guide**

### **Uploading Your Textbook**
1. **Single PDF**: Upload directly through the web interface
2. **Large PDFs**: Use the smart splitting script:
   ```bash
   ./scripts/tools/smart_pdf_splitter.sh "/path/to/your/textbook.pdf"
   ```

### **Asking Questions**
- **🌐 Global Search**: Search across entire textbook
- **📚 Chapter Search**: Focus on specific chapters
- **🎓 Learning Levels**: Beginner, Intermediate, Advanced
- **📝 Response Types**: Concise, Detailed, Step-by-step

### **System Features**
- **Textbook-Faithful Responses**: AI uses ONLY your textbook content
- **Consistent Teaching Style**: Matches your professor's approach
- **Mathematical Notation**: Uses exact same symbols and conventions
- **Example Alignment**: Uses textbook examples and explanations

## 🔧 **Configuration**

### **Application Settings** (`application.yml`)
```yaml
app:
  chunk:
    size: 500          # Text chunk size
    overlap: 100       # Chunk overlap
  max-retrieval-results: 5

ollama:
  base-url: http://localhost:11434
  model: llama2
  embedding-model: nomic-embed-text
  temperature: 0.7
  max-tokens: 2048
```

### **Database Configuration**
- **Local**: PostgreSQL via Docker Compose
- **Cloud**: Railway PostgreSQL with H2 fallback
- **Vector Storage**: pgvector for embeddings

## 🛠️ **Development**

### **Key Components**
- **RagService**: Core RAG processing and response generation
- **EmbeddingService**: Vector embeddings using Ollama
- **OllamaService**: LLM interaction for responses
- **PdfProcessingService**: PDF text extraction and processing
- **DocumentChunkRepository**: Vector database operations

### **Textbook-Faithful AI**
The system is specifically designed to:
- Use ONLY textbook content for responses
- Follow the textbook's exact teaching style
- Maintain mathematical notation consistency
- Preserve pedagogical approach and rigor

### **Testing**
```bash
# Run unit tests
mvn test

# Test RAG system
./scripts/test/test_rag_simple.sh

# Check system status
./scripts/tools/system_status.sh
```

## 📊 **System Status**

### **Health Monitoring**
```bash
# Check application health
curl http://localhost:8080/health

# Monitor system status
./scripts/tools/system_status.sh

# View application logs
tail -f scripts/logs/app_*.log
```

### **Database Management**
```bash
# Backup database
./scripts/tools/manage_db.sh backup

# Restore database
./scripts/tools/manage_db.sh restore

# Check document status
./scripts/tools/check_preloaded_documents.sh
```

## 🎨 **UI Features**

### **Modern Design**
- **HSL Gradient Background**: Beautiful blue-green-purple gradient
- **Glassmorphism Effects**: Modern card and button styling
- **Responsive Layout**: Works on desktop and mobile
- **White Text**: High contrast for readability

### **Interactive Elements**
- **Real-time Chat**: Instant AI responses
- **Chapter Selection**: Easy navigation by textbook chapters
- **Search Modes**: Global vs. chapter-specific search
- **Learning Preferences**: Customizable response styles

## 🔒 **Security & Privacy**

- **Local AI Processing**: All AI operations run locally via Ollama
- **No External APIs**: No data sent to external services (except Ollama API)
- **Database Encryption**: PostgreSQL with secure configuration
- **Environment Variables**: Sensitive data stored in environment variables

## 📈 **Performance**

### **Optimizations**
- **Chunked Processing**: Efficient text chunking for large PDFs
- **Vector Indexing**: Fast similarity search with pgvector
- **Memory Management**: Optimized JVM settings for large documents
- **Async Processing**: Non-blocking operations for better UX

### **Scalability**
- **Docker Containerization**: Easy deployment and scaling
- **Database Optimization**: Indexed vector searches
- **Caching**: Efficient embedding storage and retrieval
- **Cloud Deployment**: Railway with automatic scaling

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 **Support**

### **Common Issues**
- **Port 8080 in use**: `lsof -ti:8080 | xargs kill -9`
- **Memory issues**: Increase JVM heap size in MAVEN_OPTS
- **Ollama connection**: Ensure Ollama is running on port 11434
- **PostgreSQL connection**: Check Docker Compose or Railway service status

### **Getting Help**
- Check the logs in `scripts/logs/`
- Review the documentation in `docs/`
- Test with the provided scripts in `scripts/test/`
- Visit the live demo: https://textbookragassistant-production.up.railway.app

---

**🎓 Your AI now teaches EXACTLY as your textbook teaches!** 📚✨
