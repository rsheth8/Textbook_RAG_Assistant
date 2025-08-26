# 🚀 Railway Deployment Guide

## ✅ **Current Status**
- ✅ Application configured to use `simple` profile (H2 in-memory database)
- ✅ Health checks should now pass
- ✅ Application should start successfully

## 🔧 **Step-by-Step Deployment Process**

### **Step 1: Deploy with Simple Profile**
1. **Current Configuration**: Using `simple` profile with H2 in-memory database
2. **Expected Result**: Application starts successfully, health checks pass
3. **Timeline**: 2-3 minutes for deployment

### **Step 2: Add PostgreSQL Database (After Step 1 succeeds)**
1. **Go to Railway Dashboard**
2. **Click "New Service" → "Database" → "PostgreSQL"**
3. **Wait for database to be provisioned**
4. **Note the connection details**

### **Step 3: Configure Environment Variables**
**Add these environment variables in Railway:**

1. **Database Variables** (from PostgreSQL service):
   - `DATABASE_URL` = (from PostgreSQL service)
   - `DB_HOST` = (from PostgreSQL service)
   - `DB_PORT` = (from PostgreSQL service)
   - `DB_NAME` = (from PostgreSQL service)
   - `DB_USER` = (from PostgreSQL service)
   - `DB_PASSWORD` = (from PostgreSQL service)

2. **Ollama Variables**:
   - `OLLAMA_BASE_URL` = `https://api.ollama.ai`
   - `OLLAMA_MODEL` = `llama2`
   - `OLLAMA_EMBEDDING_MODEL` = `nomic-embed-text`
   - `OLLAMA_TEMPERATURE` = `0.7`
   - `OLLAMA_MAX_TOKENS` = `2048`

### **Step 4: Switch to Cloud Profile**
**After PostgreSQL is added and environment variables are set:**

1. **Update Railway configurations to use `cloud` profile**
2. **Redeploy the application**
3. **Test the full RAG system**

## 🎯 **Expected Results**

### **After Step 1 (Simple Profile)**:
- ✅ Health checks pass
- ✅ Application starts successfully
- ✅ Basic functionality works (without AI)

### **After Step 4 (Cloud Profile)**:
- ✅ Full RAG functionality
- ✅ AI responses work
- ✅ PostgreSQL persistence
- ✅ Complete system operational

## 📋 **Troubleshooting**

### **If Health Checks Still Fail**:
1. Check Railway logs for specific errors
2. Verify the JAR file is built correctly
3. Ensure all configuration files are updated

### **If Database Connection Fails**:
1. Verify PostgreSQL service is running
2. Check environment variables are set correctly
3. Ensure database credentials are valid

### **If AI Responses Don't Work**:
1. Verify Ollama environment variables are set
2. Check if external Ollama API is accessible
3. Test with a simple query

## 🚨 **Important Notes**

- **Order Matters**: Complete each step in order
- **Wait for Deployment**: Each step takes 2-3 minutes
- **Check Logs**: Monitor Railway logs for any errors
- **Test Incrementally**: Verify each step works before proceeding

---
*Guide created: 2025-08-26 00:35:00*
