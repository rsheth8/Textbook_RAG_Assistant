# 🚀 Step-by-Step Railway Deployment Guide

## ✅ **Current Status**
- ✅ Application deployed to Railway (using `simple` profile)
- ✅ Health checks working
- ✅ H2 in-memory database running

## 🔧 **Next Steps in Correct Order**

### **Step 1: Add PostgreSQL Database (DO THIS FIRST)**

1. **Go to Railway Dashboard**
2. **Click "New Service" → "Database" → "PostgreSQL"**
3. **Wait for database to be created**
4. **Railway will automatically:**
   - Create PostgreSQL database
   - Set `DATABASE_URL` environment variable
   - Link it to your application

### **Step 2: Configure Environment Variables**

**After PostgreSQL is added, set these environment variables:**

```bash
# Spring Profile (change to cloud AFTER database is ready)
SPRING_PROFILES_ACTIVE=cloud

# Ollama Configuration
OLLAMA_BASE_URL=https://api.ollama.ai
OLLAMA_MODEL=llama2
OLLAMA_EMBEDDING_MODEL=nomic-embed-text
OLLAMA_TEMPERATURE=0.7
OLLAMA_MAX_TOKENS=2048
```

### **Step 3: Switch to Cloud Profile**

**ONLY AFTER PostgreSQL is added and environment variables are set:**

1. **Update Railway configurations to use `cloud` profile**
2. **Redeploy the application**
3. **Test the full RAG system**

## 🚨 **Why This Order Matters**

### **Current Setup (Working)**
- ✅ **Profile**: `simple` (H2 in-memory database)
- ✅ **AI**: Local Ollama (fails in cloud)
- ✅ **Health Checks**: Working

### **Target Setup (After Steps)**
- ✅ **Profile**: `cloud` (PostgreSQL + External Ollama)
- ✅ **AI**: External Ollama API
- ✅ **Database**: PostgreSQL
- ✅ **Full RAG**: Working

## 📋 **Checklist**

- [ ] Add PostgreSQL database to Railway
- [ ] Set environment variables
- [ ] Switch to `cloud` profile
- [ ] Test RAG functionality
- [ ] Upload textbook data

## 🔍 **Troubleshooting**

### **If Health Checks Fail**
- Make sure PostgreSQL is added first
- Check environment variables are set correctly
- Verify `DATABASE_URL` is automatically set by Railway

### **If AI Responses Fail**
- Verify `OLLAMA_BASE_URL` is set to `https://api.ollama.ai`
- Check all Ollama environment variables are configured
- Ensure `SPRING_PROFILES_ACTIVE=cloud`

## 🎯 **Expected Timeline**

1. **Add PostgreSQL**: 2-3 minutes
2. **Set Environment Variables**: 5 minutes
3. **Switch to Cloud Profile**: 2-3 minutes
4. **Test System**: 5-10 minutes

**Total Time**: ~15-20 minutes
