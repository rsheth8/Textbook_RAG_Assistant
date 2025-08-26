# 📚 Textbook Assistant - RAG-Powered Learning System

A sophisticated Retrieval-Augmented Generation (RAG) application that provides AI-powered tutoring based on your specific textbook content. The system ensures faithful adherence to your textbook's teaching style, terminology, and approach.

## 🌟 **GitHub Repository**

**Repository**: https://github.com/rsheth8/Textbook_RAG_Assistant

**Features**:
- ✅ **Textbook-Faithful AI**: Teaches EXACTLY as your textbook teaches
- ✅ **Global Textbook Search**: Access to entire textbook content simultaneously
- ✅ **Modern Web Interface**: Beautiful gradient design with responsive layout
- ✅ **Local AI Processing**: Powered by Ollama for privacy and control
- ✅ **Smart PDF Processing**: Intelligent chunking and organization
- ✅ **Professional Codebase**: Clean, maintainable architecture

## 🎯 **Key Features**

- **📖 Textbook-Faithful AI**: Teaches EXACTLY as your textbook teaches
- **🌐 Global Textbook Search**: Access to entire textbook content simultaneously
- **📚 Chapter Organization**: Organized by actual textbook chapters
- **🎨 Modern UI**: Beautiful gradient interface with responsive design
- **⚡ Real-time Processing**: Instant answers with comprehensive context
- **🔒 Local AI**: Powered by Ollama for privacy and control

## 🏗️ **Project Structure**

```
TextbookAssistant/
├── 📁 src/                    # Spring Boot application source
│   ├── main/java/            # Java source code
│   ├── main/resources/       # Configuration and templates
│   └── test/                 # Unit tests
├── 📁 docs/                  # Documentation
│   ├── README-SpringBoot.md  # Technical setup guide
│   ├── SETUP_COMPLETE.md     # Complete setup instructions
│   ├── RAG_SYSTEM_COMPLETE.md # RAG system overview
│   └── textbook_faithful_improvements.md # AI fidelity improvements
├── 📁 scripts/               # Utility scripts
│   ├── tools/               # Core system tools
│   ├── test/                # Testing scripts and data
│   └── logs/                # Application logs
├── 📁 data/                  # Data storage
│   ├── backups/             # Database backups
│   ├── chapter_mapping.json # Textbook chapter organization
│   └── chunks/              # PDF chunks and organized content
├── 📁 target/               # Compiled application
├── 📄 pom.xml               # Maven dependencies
├── 📄 docker-compose.yml    # Docker services
├── 📄 Dockerfile            # Application container
└── 📄 env.example           # Environment variables template
```

## 🚀 **Quick Start**

### **Prerequisites**
- Java 17 or higher
- Maven 3.6+
- Docker and Docker Compose
- Ollama with `llama2` and `nomic-embed-text` models

### **1. Setup Environment**
```bash
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
- **Health Check**: http://localhost:8080/api/v1/health

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
- **Host**: localhost:5432
- **Database**: textbook_assistant
- **Username**: textbook_user
- **Password**: (set in .env file)

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
curl http://localhost:8080/api/v1/health

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
- **No External APIs**: No data sent to external services
- **Database Encryption**: PostgreSQL with secure configuration
- **Environment Variables**: Sensitive data stored in .env file

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

### **Getting Help**
- Check the logs in `scripts/logs/`
- Review the documentation in `docs/`
- Test with the provided scripts in `scripts/test/`

---

**🎓 Your AI now teaches EXACTLY as your textbook teaches!** 📚✨
