# 🚀 Railway Cloud Deployment Checklist

## ✅ **What You Need to Verify**

### **1. PostgreSQL Database Service**
- [ ] PostgreSQL service is attached to your application
- [ ] Database is running and healthy
- [ ] Connection string is automatically provided via `DATABASE_URL`

### **2. Environment Variables (Required for Cloud Profile)**
Make sure these are set in your Railway application service:

#### **Database Variables (Auto-provided by PostgreSQL service)**
- [ ] `DATABASE_URL` - Automatically set by Railway PostgreSQL service
- [ ] `POSTGRES_USER` - Automatically set by Railway PostgreSQL service  
- [ ] `POSTGRES_PASSWORD` - Automatically set by Railway PostgreSQL service

#### **Ollama API Variables (You need to add these)**
- [ ] `OLLAMA_BASE_URL` = `https://api.ollama.ai`
- [ ] `OLLAMA_MODEL` = `llama2`
- [ ] `OLLAMA_EMBEDDING_MODEL` = `nomic-embed-text`
- [ ] `OLLAMA_TEMPERATURE` = `0.7`
- [ ] `OLLAMA_MAX_TOKENS` = `2048`

### **3. Application Configuration**
- [ ] Application is using `cloud` profile (✅ Already configured)
- [ ] Health check endpoint is `/actuator/health` (✅ Already configured)
- [ ] Metrics issues are fixed (✅ Already fixed)

## 🔧 **How to Check/Add Environment Variables**

1. **Go to Railway Dashboard**
2. **Click on your application service** (not the PostgreSQL service)
3. **Go to "Variables" tab**
4. **Add the Ollama variables listed above**

## 🎯 **Expected Result**

After deployment:
- ✅ Health checks pass
- ✅ Application connects to PostgreSQL
- ✅ AI responses work via external Ollama API
- ✅ Full RAG functionality available

## 📋 **Quick Test**

Once deployed, you should be able to:
1. Upload a PDF
2. Ask questions about the content
3. Get AI-generated responses

---

*If you already have the Ollama environment variables set, you're ready to go!*
