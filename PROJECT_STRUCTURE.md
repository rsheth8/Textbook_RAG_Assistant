# 📁 Project Structure

## **Core Application**
```
src/main/java/com/textbookassistant/
├── TextbookRagAssistantApplication.java    # Main Spring Boot application
├── controller/                             # REST API controllers
│   ├── DocumentController.java            # Document upload and management
│   ├── QueryController.java               # RAG query processing
│   └── HealthController.java              # Health check endpoints
├── service/                               # Business logic
│   ├── DocumentService.java               # Document processing
│   ├── RagService.java                    # RAG implementation
│   └── OllamaService.java                 # Ollama API integration
├── repository/                            # Database access
│   ├── DocumentRepository.java            # Document entity repository
│   └── EmbeddingRepository.java           # Embedding entity repository
├── entity/                                # Database entities
│   ├── Document.java                      # Document entity
│   └── Embedding.java                     # Embedding entity
└── config/                                # Configuration classes
    └── DatabaseConfig.java                # PostgreSQL configuration
```

## **Configuration Files**
```
├── application.yml                        # Default application config
├── application-cloud.yml                  # Railway deployment config
├── docker-compose.yml                     # Local development setup
├── railway.toml                          # Railway deployment settings
├── pom.xml                               # Maven dependencies
└── Dockerfile                            # Container configuration
```

## **Data & Scripts**
```
├── data/                                 # Application data
│   ├── uploads/                          # User uploaded files
│   └── processed/                        # Processed documents
├── scripts/
│   ├── setup_database.sql               # Database initialization
│   └── setup_ollama.sh                  # Ollama model setup
└── src/main/resources/static/
    └── chapter_mapping.json             # Chapter organization
```

## **Documentation**
```
├── README.md                             # Main project documentation
├── docs/
│   ├── README.md                        # Additional docs
│   └── textbook_faithful_improvements.md # AI behavior improvements
└── PROJECT_STRUCTURE.md                 # This file
```

## **Key Features**
- ✅ **RAG System**: Textbook question answering with embeddings
- ✅ **PDF Processing**: Smart text extraction and chunking
- ✅ **Chapter Organization**: Structured textbook navigation
- ✅ **Local Development**: Docker Compose with PostgreSQL + Ollama
- ✅ **Cloud Deployment**: Railway-ready configuration
- ✅ **Health Checks**: Spring Boot Actuator integration
