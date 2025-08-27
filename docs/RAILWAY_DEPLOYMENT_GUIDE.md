# Railway Deployment Guide for Textbook Assistant

## 🎯 Overview
This guide will walk you through deploying your Textbook Assistant to Railway with:
- **PostgreSQL Database** (Railway's managed PostgreSQL)
- **Ollama Service** (Railway's Ollama service)
- **Spring Boot Application** (Your RAG application)

## 📋 Prerequisites
- Railway account (free tier available)
- GitHub repository connected
- Your application code pushed to GitHub

## 🚀 Step-by-Step Deployment

### Step 1: Create Railway Project

1. **Go to Railway Dashboard**
   - Visit: https://railway.app/dashboard
   - Sign in with GitHub

2. **Create New Project**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your repository: `rsheth8/Textbook_RAG_Assistant`

### Step 2: Add PostgreSQL Database

1. **Add PostgreSQL Service**
   - In your project, click "New Service"
   - Select "Database" → "PostgreSQL"
   - Railway will automatically provision a PostgreSQL instance

2. **Note Database Credentials**
   - Railway will provide these environment variables:
     - `DATABASE_URL`
     - `POSTGRES_USER`
     - `POSTGRES_PASSWORD`
     - `POSTGRES_HOST`
     - `POSTGRES_PORT`
   - These are automatically available to your application

### Step 3: Add Ollama Service

1. **Add Ollama Service**
   - Click "New Service" again
   - Select "Ollama" from the service catalog
   - Railway will provision an Ollama instance

2. **Configure Ollama Models**
   - In the Ollama service dashboard, pull the required models:
   ```bash
   # Pull the chat model
   ollama pull phi3
   
   # Pull the embedding model
   ollama pull nomic-embed-text
   ```

3. **Note Ollama URL**
   - Railway will provide the Ollama service URL
   - It will be something like: `https://your-ollama-service.railway.app`

### Step 4: Configure Application Environment

1. **Go to Your Application Service**
   - Click on your main application service
   - Go to "Variables" tab

2. **Set Required Environment Variables**
   ```bash
   # Database (automatically provided by Railway PostgreSQL)
   SPRING_PROFILES_ACTIVE=cloud
   
   # Ollama Configuration
   OLLAMA_BASE_URL=https://your-ollama-service.railway.app
   OLLAMA_MODEL=phi3
   OLLAMA_TEMPERATURE=0.7
   OLLAMA_MAX_TOKENS=2048
   OLLAMA_EMBEDDING_MODEL=nomic-embed-text
   
   # Application Configuration
   CHUNK_SIZE=300
   CHUNK_OVERLAP=50
   MAX_RETRIEVAL_RESULTS=3
   UPLOAD_DIR=/tmp/uploads
   PROCESSED_DIR=/tmp/processed
   ```

3. **Link Services**
   - Railway automatically links services in the same project
   - Your app will have access to both PostgreSQL and Ollama

### Step 5: Deploy Application

1. **Trigger Deployment**
   - Railway will automatically deploy when you push to main
   - Or manually trigger from the dashboard

2. **Monitor Deployment**
   - Watch the build logs
   - Check for any errors
   - Verify all services are running

### Step 6: Verify Deployment

1. **Check Application Health**
   - Visit your application URL
   - Should see the textbook assistant interface

2. **Test Database Initialization**
   - The application should automatically populate with your textbook
   - Check logs for initialization messages

3. **Test RAG Functionality**
   - Try asking a question about linear algebra
   - Should get responses based on your textbook content

## 🔧 Troubleshooting

### Common Issues:

1. **Database Connection Issues**
   - Verify `SPRING_PROFILES_ACTIVE=cloud`
   - Check Railway PostgreSQL service is running
   - Ensure environment variables are set

2. **Ollama Connection Issues**
   - Verify `OLLAMA_BASE_URL` is correct
   - Check Ollama service is running
   - Ensure models are pulled in Ollama service

3. **Application Startup Issues**
   - Check build logs for compilation errors
   - Verify Java 17 is specified in `system.properties`
   - Check memory allocation in `railway.toml`

### Useful Commands:

```bash
# Check Railway CLI (optional)
railway login
railway status

# View logs
railway logs

# Connect to database
railway connect
```

## 📊 Monitoring & Maintenance

1. **Monitor Usage**
   - Railway dashboard shows resource usage
   - Monitor database and Ollama service performance

2. **Scaling**
   - Upgrade plans as needed
   - Add more resources if required

3. **Updates**
   - Push changes to GitHub
   - Railway automatically redeploys

## 🎉 Success Indicators

✅ Application accessible via Railway URL  
✅ Database automatically populated with textbook  
✅ RAG queries returning relevant responses  
✅ All services (PostgreSQL, Ollama, App) running  
✅ No errors in application logs  

## 🔗 Useful Links

- [Railway Documentation](https://docs.railway.app/)
- [Railway PostgreSQL Guide](https://docs.railway.app/databases/postgresql)
- [Railway Ollama Guide](https://docs.railway.app/ai/ollama)
- [Your GitHub Repository](https://github.com/rsheth8/Textbook_RAG_Assistant)

---

**Your Textbook Assistant will be live and ready to help with linear algebra questions! 🚀**
