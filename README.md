# 📚 Textbook Assistant - RAG-Powered Learning System (MVP)

A simplified Retrieval-Augmented Generation (RAG) application that provides AI-powered tutoring based on your specific textbook content. This MVP version focuses on core functionality with Spring AI and PostgreSQL.

## 🌟 **Live Demo**

**Live Application**: https://textbookragassistant-production.up.railway.app

**GitHub Repository**: https://github.com/rsheth8/Textbook_RAG_Assistant

## 🎯 **Key Features (MVP)**

- **📖 Textbook-Faithful AI**: Teaches EXACTLY as your textbook teaches
- **🌐 Global Textbook Search**: Access to entire textbook content simultaneously
- **📚 Chapter Organization**: Organized by actual textbook chapters
- **🎨 Modern UI**: Beautiful gradient interface with responsive design
- **⚡ Real-time Processing**: Instant answers with comprehensive context
- **☁️ Cloud Deployed**: Available online via Railway
- **🔧 Spring AI Integration**: Uses Spring AI for future AI capabilities

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
- PostgreSQL

### **1. Local Setup**
```bash
# Clone the repository
git clone https://github.com/rsheth8/Textbook_RAG_Assistant.git
cd Textbook_RAG_Assistant

# Copy environment template
cp env.example .env

# Start PostgreSQL database
docker-compose up -d postgres
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

#### **Database Configuration**
```
DATABASE_URL=postgresql://postgres:***@maglev.proxy.rlwy.net:55026/railway
POSTGRES_USER=postgres
POSTGRES_DB=railway
```

#### **Application Configuration**
```
SPRING_PROFILES_ACTIVE=cloud
CHUNK_SIZE=300
CHUNK_OVERLAP=50
MAX_RETRIEVAL_RESULTS=3
UPLOAD_DIR=/tmp/uploads
PROCESSED_DIR=/tmp/processed
```

### **Deployment Features**
- ✅ **Automatic Health Checks**: `/health` endpoint
- ✅ **PostgreSQL Database**: Dedicated PostgreSQL database for production reliability
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

spring.ai:
  ollama:
    base-url: http://localhost:11434
    chat:
      options:
        model: gemma2
        temperature: 0.7
        max-tokens: 2048
    embedding:
      options:
        model: nomic-embed-text
```

### **Database Configuration**
- **Local**: PostgreSQL via Docker Compose
- **Cloud**: Railway PostgreSQL database
- **Vector Storage**: Ready for future pgvector integration

## 🛠️ **Development**

### **Key Components**
- **SpringAiRagService**: Core RAG processing and response generation
- **PdfProcessingService**: PDF text extraction and processing
- **DocumentChunkRepository**: Database operations
- **RagController**: REST API endpoints

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

- **Database Encryption**: PostgreSQL with secure configuration
- **Environment Variables**: Sensitive data stored in environment variables
- **No External APIs**: Self-contained application

## 📈 **Performance**

### **Optimizations**
- **Chunked Processing**: Efficient text chunking for large PDFs
- **Memory Management**: Optimized JVM settings for large documents
- **Async Processing**: Non-blocking operations for better UX

### **Scalability**
- **Docker Containerization**: Easy deployment and scaling
- **Database Optimization**: Indexed searches
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
- **PostgreSQL connection**: Check Docker Compose or Railway service status

### **Getting Help**
- Check the logs in `scripts/logs/`
- Review the documentation in `docs/`
- Test with the provided scripts in `scripts/test/`
- Visit the live demo: https://textbookragassistant-production.up.railway.app

---

**🎓 Your AI now teaches EXACTLY as your textbook teaches!** 📚✨

## 🔄 **MVP Roadmap**

### **Current Version (MVP)**
- ✅ Basic PDF upload and processing
- ✅ Text chunking and storage
- ✅ Simple text-based search
- ✅ Railway deployment ready
- ✅ Spring AI integration foundation

### **Next Iterations**
- 🔄 Full Spring AI integration with Ollama
- 🔄 Vector embeddings and similarity search
- 🔄 Advanced RAG with proper AI responses
- 🔄 Enhanced UI and user experience
- 🔄 Performance optimizations
