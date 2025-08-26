# 🚀 Cloud Deployment Guide - Railway

## ✅ **Current Status**
- ✅ Application deployed to Railway
- ✅ Health checks working
- ✅ Basic application running

## 🔧 **Next Steps for Full RAG System**

### **1. Add PostgreSQL Database**

1. **Go to Railway Dashboard**
2. **Click "New Service" → "Database" → "PostgreSQL"**
3. **Railway will automatically:**
   - Create a PostgreSQL database
   - Set `DATABASE_URL` environment variable
   - Link it to your application

### **2. Configure Environment Variables**

In your Railway project settings, add these environment variables:

```bash
# Spring Profile
SPRING_PROFILES_ACTIVE=cloud

# Ollama Configuration
OLLAMA_BASE_URL=https://api.ollama.ai
OLLAMA_MODEL=llama2
OLLAMA_EMBEDDING_MODEL=nomic-embed-text
OLLAMA_TEMPERATURE=0.7
OLLAMA_MAX_TOKENS=2048

# Optional: Ollama API Key (if using paid service)
OLLAMA_API_KEY=your_api_key_here
```

### **3. Deploy Updated Configuration**

The application is now configured to:
- ✅ Use `cloud` profile with PostgreSQL
- ✅ Connect to external Ollama API
- ✅ Use Railway's PostgreSQL database
- ✅ Handle environment variables properly

### **4. Test the Full System**

After deployment, test these endpoints:

```bash
# Health Check
curl https://your-railway-url.railway.app/health

# Status Check
curl https://your-railway-url.railway.app/status

# Web Interface
# Open https://your-railway-url.railway.app in browser
```

### **5. Upload Your Textbook Data**

Once the system is running:

1. **Open the web interface**
2. **Upload your textbook PDFs**
3. **The system will:**
   - Process PDFs into chunks
   - Generate embeddings using Ollama
   - Store data in PostgreSQL
   - Enable RAG queries

### **6. Test RAG Functionality**

Test with queries like:
- "Explain linear algebra concepts"
- "What are eigenvalues?"
- "How do matrices work?"

## 🔗 **Railway Services**

Your Railway project should have:
- ✅ **Web Service**: Your Spring Boot application
- 🔄 **PostgreSQL**: Database (add this)
- 🔄 **Environment Variables**: Configure these

## 📊 **Monitoring**

- **Railway Dashboard**: Monitor logs and performance
- **Health Checks**: `/health` endpoint
- **Application Logs**: View in Railway dashboard

## 🚨 **Troubleshooting**

### **If Database Connection Fails:**
- Check `DATABASE_URL` environment variable
- Verify PostgreSQL service is running
- Check application logs

### **If Ollama API Fails:**
- Verify `OLLAMA_BASE_URL` is correct
- Check if you need an API key
- Test with a simple query first

### **If Application Won't Start:**
- Check environment variables
- Verify `SPRING_PROFILES_ACTIVE=cloud`
- Review Railway logs

## 🎯 **Success Criteria**

✅ Application deploys successfully
✅ Health checks pass
✅ Database connects
✅ Ollama API responds
✅ Web interface loads
✅ PDF uploads work
✅ RAG queries work

## 📞 **Next Steps After Success**

1. **Add custom domain** (optional)
2. **Set up monitoring** and alerts
3. **Scale resources** as needed
4. **Share your tool** with others!

---

**Your RAG system will be fully functional in the cloud!** 🚀📚✨
