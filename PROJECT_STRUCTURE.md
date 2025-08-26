# 📁 Textbook Assistant - Project Structure

## 🏗️ **Complete Directory Layout**

```
TextbookAssistant/
├── 📁 src/                           # Spring Boot Application Source
│   ├── 📁 main/
│   │   ├── 📁 java/com/textbookassistant/
│   │   │   ├── 📁 config/            # Configuration classes
│   │   │   ├── 📁 controller/        # REST API controllers
│   │   │   ├── 📁 model/             # Data models and entities
│   │   │   ├── 📁 repository/        # Database repositories
│   │   │   └── 📁 service/           # Business logic services
│   │   └── 📁 resources/
│   │       ├── 📁 static/            # Static web resources
│   │       │   └── chapter_mapping.json
│   │       ├── 📁 templates/         # Thymeleaf templates
│   │       │   └── index.html        # Main web interface
│   │       ├── 📁 db/migration/      # Database migrations
│   │       │   └── V1__create_document_chunks_table.sql
│   │       └── application.yml       # Application configuration
│   └── 📁 test/                      # Unit tests
│
├── 📁 docs/                          # Documentation
│   ├── README-SpringBoot.md          # Technical setup guide
│   ├── SETUP_COMPLETE.md             # Complete setup instructions
│   ├── RAG_SYSTEM_COMPLETE.md        # RAG system overview
│   └── textbook_faithful_improvements.md # AI fidelity improvements
│
├── 📁 scripts/                       # Utility Scripts
│   ├── 📁 tools/                     # Core System Tools
│   │   ├── smart_pdf_splitter.sh     # Smart PDF splitting
│   │   ├── process_all_textbook_chunks.sh # Bulk processing
│   │   ├── organize_textbook_chapters.sh # Chapter organization
│   │   ├── diagnose_rag.sh           # RAG system diagnostics
│   │   ├── system_status.sh          # System health check
│   │   ├── open_web_interface.sh     # Open web UI
│   │   ├── manage_db.sh              # Database management
│   │   ├── setup_postgres.sh         # PostgreSQL setup
│   │   ├── check_preloaded_documents.sh # Document status
│   │   ├── preload_pdf.sh            # PDF preloading
│   │   ├── upload_large_pdf.sh       # Large PDF upload
│   │   ├── fix_db.sh                 # Database fixes
│   │   ├── global_search_demo.sh     # Global search demo
│   │   ├── chapter_organization_demo.sh # Chapter demo
│   │   ├── new_ui_demo.sh            # UI demo
│   │   ├── update_database_chapters.sh # Chapter updates
│   │   ├── process_key_chunks.sh     # Key chunk processing
│   │   ├── process_uploaded_chunks.sh # Upload processing
│   │   ├── split_and_upload_pdf.sh   # PDF split and upload
│   │   ├── split_and_upload_pdf_v2.sh # Enhanced PDF processing
│   │   └── setup_database.sql        # Database setup
│   │
│   ├── 📁 test/                      # Testing Scripts
│   │   ├── test_rag_simple.sh        # Simple RAG test
│   │   ├── test_rag_step_by_step.sh  # Step-by-step RAG test
│   │   ├── test_rag_step_by_step_fixed.sh # Fixed RAG test
│   │   ├── test_manual_rag.sh        # Manual RAG test
│   │   ├── test_rag_debug.sh         # RAG debugging
│   │   ├── test_minimal_rag.sh       # Minimal RAG test
│   │   ├── test_query_system.sh      # Query system test
│   │   ├── test_pdf_upload.sh        # PDF upload test
│   │   ├── test_basic_upload.sh      # Basic upload test
│   │   ├── test_single_page.sh       # Single page test
│   │   ├── test_text_file.sh         # Text file test
│   │   ├── test_small_pdf.sh         # Small PDF test
│   │   ├── test_sample_upload.sh     # Sample upload test
│   │   ├── test_rag.sh               # Basic RAG test
│   │   ├── test_minimal_fixed.txt    # Minimal test data
│   │   ├── test_rag_fixed.txt        # Fixed test data
│   │   ├── test_textbook_content.txt # Textbook test content
│   │   ├── sample_math_text.txt      # Sample math text
│   │   └── test_document.txt         # Test document
│   │
│   ├── 📁 logs/                      # Application Logs
│   │   ├── app_*.log                 # Application logs
│   │   ├── upload_*.log              # Upload logs
│   │   ├── smart_*.log               # Smart processing logs
│   │   └── app_quick_start.log       # Quick start log
│   │
│   └── quick_start.sh                # Quick start script
│
├── 📁 data/                          # Data Storage
│   ├── 📁 backups/                   # Database Backups
│   │   ├── fix_database_schema.sql   # Schema fixes
│   │   └── setup_database.sql        # Database setup
│   │
│   ├── 📁 chunks/                    # PDF Chunks
│   │   ├── pdf_chunks/               # Original PDF chunks
│   │   ├── pdf_chunks_small/         # Small PDF chunks
│   │   ├── pdf_chunks_smart/         # Smart-split chunks
│   │   └── organized_chapters/       # Organized by chapters
│   │
│   ├── chapter_mapping.json          # Textbook chapter mapping
│   └── test_rag_simple/              # Test data
│
├── 📁 target/                        # Compiled Application
├── 📁 .vscode/                       # VS Code Configuration
│
├── 📄 pom.xml                        # Maven Dependencies
├── 📄 docker-compose.yml             # Docker Services
├── 📄 Dockerfile                     # Application Container
├── 📄 env.example                    # Environment Variables Template
├── 📄 README.md                      # Main Project Documentation
└── 📄 PROJECT_STRUCTURE.md           # This File
```

## 🔧 **Key Components**

### **📁 src/main/java/com/textbookassistant/**
- **config/**: Application configuration classes
- **controller/**: REST API endpoints for web interface
- **model/**: JPA entities (Document, DocumentChunk)
- **repository/**: Database access layer with vector operations
- **service/**: Core business logic (RAG, embeddings, PDF processing)

### **📁 scripts/tools/**
- **PDF Processing**: Smart splitting, bulk processing, chapter organization
- **System Management**: Database management, health checks, diagnostics
- **Demo Scripts**: Feature demonstrations and testing
- **Setup Scripts**: Environment and database setup

### **📁 scripts/test/**
- **RAG Testing**: Various RAG system tests and debugging
- **Upload Testing**: PDF and text file upload testing
- **System Testing**: End-to-end system validation
- **Test Data**: Sample files and test content

### **📁 data/**
- **Backups**: Database schema and setup scripts
- **Chunks**: Processed PDF chunks organized by different methods
- **Mapping**: Chapter organization and structure data

## 🎯 **File Purposes**

### **Core Application Files**
- `pom.xml`: Maven dependencies and build configuration
- `application.yml`: Spring Boot configuration
- `docker-compose.yml`: PostgreSQL database service
- `Dockerfile`: Application containerization

### **Key Scripts**
- `quick_start.sh`: Complete system setup and startup
- `smart_pdf_splitter.sh`: Intelligent PDF splitting for large files
- `system_status.sh`: Comprehensive system health check
- `diagnose_rag.sh`: RAG system troubleshooting

### **Documentation**
- `README.md`: Main project overview and usage guide
- `PROJECT_STRUCTURE.md`: This detailed structure overview
- `docs/`: Technical documentation and guides

## 🚀 **Quick Navigation**

### **Getting Started**
```bash
# Quick start everything
./scripts/quick_start.sh

# Check system status
./scripts/tools/system_status.sh

# Open web interface
./scripts/tools/open_web_interface.sh
```

### **PDF Processing**
```bash
# Smart split large PDF
./scripts/tools/smart_pdf_splitter.sh "/path/to/textbook.pdf"

# Process all chunks
./scripts/tools/process_all_textbook_chunks.sh

# Organize by chapters
./scripts/tools/organize_textbook_chapters.sh
```

### **Testing**
```bash
# Test RAG system
./scripts/test/test_rag_simple.sh

# Test PDF upload
./scripts/test/test_pdf_upload.sh

# Debug RAG issues
./scripts/tools/diagnose_rag.sh
```

### **Database Management**
```bash
# Backup database
./scripts/tools/manage_db.sh backup

# Check documents
./scripts/tools/check_preloaded_documents.sh

# Fix database issues
./scripts/tools/fix_db.sh
```

## 📊 **Log Locations**

- **Application Logs**: `scripts/logs/app_*.log`
- **Upload Logs**: `scripts/logs/upload_*.log`
- **Processing Logs**: `scripts/logs/smart_*.log`
- **Quick Start Log**: `scripts/logs/app_quick_start.log`

## 🎨 **Web Interface**

- **Main Template**: `src/main/resources/templates/index.html`
- **Static Resources**: `src/main/resources/static/`
- **Chapter Mapping**: `data/chapter_mapping.json`

## 🔒 **Configuration**

- **Environment**: `env.example` → `.env`
- **Application**: `src/main/resources/application.yml`
- **Database**: `docker-compose.yml`

---

**📚 This structure provides a clean, organized, and maintainable codebase for the Textbook Assistant RAG system!** ✨
