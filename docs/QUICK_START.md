# Quick Start Guide - Math Textbook RAG Assistant

## Prerequisites

1. **Java 17+**
2. **Docker** (for PostgreSQL)
3. **Ollama** (for local LLM)

## Step 1: Install Prerequisites

### Java 17
```bash
# On macOS
brew install openjdk@17
```

### Docker
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop/
```

### Ollama
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama
ollama serve

# Pull a model (in another terminal)
ollama pull llama2
```

## Step 2: Setup Database

```bash
# Run the database setup script
./setup_postgres.sh

# Or use the management script
./manage_db.sh start
```

## Step 3: Build and Run Application

```bash
# Build the application
mvn clean package

# Run the application
mvn spring-boot:run
```

## Step 4: Access the Application

- **Web Interface**: http://localhost:8080
- **REST API**: http://localhost:8080/api/v1
- **Health Check**: http://localhost:8080/api/v1/health

## Database Management

```bash
# Check database status
./manage_db.sh status

# Start database
./manage_db.sh start

# Stop database
./manage_db.sh stop

# Connect to database
./manage_db.sh connect

# View logs
./manage_db.sh logs
```

## Usage

1. **Upload PDF**: Go to http://localhost:8080 and upload your math textbook
2. **Chat**: Click "Chat" on any processed document to ask questions
3. **API**: Use the REST API for programmatic access

## Troubleshooting

### Database Issues
```bash
# Check if database is running
./manage_db.sh status

# Restart database if needed
./manage_db.sh restart
```

### Ollama Issues
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Start Ollama if not running
ollama serve
```

### Application Issues
```bash
# Check application logs
tail -f logs/application.log

# Restart application
mvn spring-boot:run
```

## Configuration

Edit `src/main/resources/application.yml` to customize:
- Database connection
- Ollama settings
- File upload limits
- Chunking parameters
