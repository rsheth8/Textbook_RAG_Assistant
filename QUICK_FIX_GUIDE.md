# 🚀 Quick Fix: Set Environment Variables in Railway

## ✅ **Current Status**
- ✅ PostgreSQL database is connected
- ✅ Application is using `cloud` profile
- ❌ **Missing**: Environment variables for external Ollama API

## 🔧 **The Fix: Add These Environment Variables**

**Go to Railway Dashboard → Your Application Service → Variables Tab**

### **Add These Variables:**

1. **OLLAMA_BASE_URL**
   - **Value**: `https://api.ollama.ai`

2. **OLLAMA_MODEL**
   - **Value**: `llama2`

3. **OLLAMA_EMBEDDING_MODEL**
   - **Value**: `nomic-embed-text`

4. **OLLAMA_TEMPERATURE**
   - **Value**: `0.7`

5. **OLLAMA_MAX_TOKENS**
   - **Value**: `2048`

## 🎯 **What This Fixes**

- ✅ **Eliminates "Connection refused" error**
- ✅ **Uses external Ollama API instead of localhost**
- ✅ **Enables AI responses in the cloud**
- ✅ **Full RAG functionality**

## 📋 **Step-by-Step**

1. **Open Railway Dashboard**
2. **Click on your application service**
3. **Go to "Variables" tab**
4. **Click "New Variable" for each one above**
5. **Save and wait for redeployment**
6. **Test the application**

## 🚨 **Expected Result**

After adding these variables:
- ✅ Health checks will pass
- ✅ AI responses will work
- ✅ No more "Connection refused" errors
- ✅ Full RAG system functional

## ⏱️ **Timeline**

- **Add variables**: 2-3 minutes
- **Redeployment**: 2-3 minutes
- **Testing**: 1-2 minutes

**Total**: ~5-8 minutes
