# Railway Deployment Checklist

## ✅ Pre-Deployment Checklist

### Repository Ready
- [ ] Code pushed to GitHub
- [ ] All files committed
- [ ] No large files in repository
- [ ] `.gitignore` properly configured

### Application Configuration
- [ ] `railway.toml` updated with correct settings
- [ ] `application-cloud.yml` configured
- [ ] `DataInitializationConfig.java` ready
- [ ] `textbook_content.txt` included in resources

## 🚀 Railway Deployment Steps

### Step 1: Create Project
- [ ] Go to https://railway.app/dashboard
- [ ] Click "New Project"
- [ ] Select "Deploy from GitHub repo"
- [ ] Choose `rsheth8/Textbook_RAG_Assistant`

### Step 2: Add PostgreSQL
- [ ] Click "New Service"
- [ ] Select "Database" → "PostgreSQL"
- [ ] Wait for provisioning
- [ ] Note the service URL

### Step 3: Add Ollama Service
- [ ] Click "New Service"
- [ ] Select "Ollama" from catalog
- [ ] Wait for provisioning
- [ ] Note the Ollama service URL

### Step 4: Configure Ollama Models
- [ ] Go to Ollama service dashboard
- [ ] Pull required models:
  ```bash
  ollama pull phi3
  ollama pull nomic-embed-text
  ```
- [ ] Verify models are available

### Step 5: Configure Application
- [ ] Go to main application service
- [ ] Click "Variables" tab
- [ ] Set environment variables:
  - [ ] `SPRING_PROFILES_ACTIVE=cloud`
  - [ ] `OLLAMA_BASE_URL=https://your-ollama-service.railway.app`
  - [ ] `OLLAMA_MODEL=phi3`
  - [ ] `OLLAMA_TEMPERATURE=0.7`
  - [ ] `OLLAMA_MAX_TOKENS=2048`
  - [ ] `OLLAMA_EMBEDDING_MODEL=nomic-embed-text`
  - [ ] `CHUNK_SIZE=300`
  - [ ] `CHUNK_OVERLAP=50`
  - [ ] `MAX_RETRIEVAL_RESULTS=3`
  - [ ] `UPLOAD_DIR=/tmp/uploads`
  - [ ] `PROCESSED_DIR=/tmp/processed`

### Step 6: Deploy
- [ ] Trigger deployment
- [ ] Monitor build logs
- [ ] Check for errors
- [ ] Wait for all services to be ready

## ✅ Post-Deployment Verification

### Application Health
- [ ] Application accessible via Railway URL
- [ ] Health check endpoint responding: `/actuator/health`
- [ ] No startup errors in logs

### Database Initialization
- [ ] Check logs for "Starting database initialization"
- [ ] Verify "Successfully initialized database with textbook"
- [ ] Database contains textbook content

### Ollama Integration
- [ ] Ollama service running
- [ ] Models loaded (phi3, nomic-embed-text)
- [ ] Application can connect to Ollama

### RAG Functionality
- [ ] Web interface loads
- [ ] Can ask questions about linear algebra
- [ ] Responses are relevant to textbook content
- [ ] No errors in query processing

## 🔧 Troubleshooting

### If Database Issues:
- [ ] Check `SPRING_PROFILES_ACTIVE=cloud`
- [ ] Verify PostgreSQL service is running
- [ ] Check database connection logs

### If Ollama Issues:
- [ ] Verify `OLLAMA_BASE_URL` is correct
- [ ] Check Ollama service is running
- [ ] Ensure models are pulled
- [ ] Test Ollama connection

### If Application Issues:
- [ ] Check build logs for compilation errors
- [ ] Verify Java 17 in `system.properties`
- [ ] Check memory allocation
- [ ] Review application logs

## 📊 Success Metrics

- [ ] Application responds within 5 seconds
- [ ] Database queries return relevant content
- [ ] RAG responses are accurate
- [ ] All services running without errors
- [ ] Memory usage within limits

## 🎉 Deployment Complete!

Once all checkboxes are marked, your Textbook Assistant is live and ready to help with linear algebra questions!
