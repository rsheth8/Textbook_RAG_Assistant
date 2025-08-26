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

**ONLY AFTER PostgreSQL is ready, update the Railway configuration:**

1. **Change `SPRING_PROFILES_ACTIVE` to `cloud`**
2. **Railway will automatically redeploy**
3. **Application will now use PostgreSQL instead of H2**

## 🚨 **Why This Order Matters**

### **Current Configuration (Working)**
- ✅ **Profile**: `simple`
- ✅ **Database**: H2 in-memory
- ✅ **Status**: Working and healthy

### **Target Configuration (After PostgreSQL)**
- 🔄 **Profile**: `cloud`
- 🔄 **Database**: PostgreSQL
- 🔄 **Status**: Full RAG system

## 📋 **Deployment Checklist**

- [ ] **Step 1**: Add PostgreSQL database to Railway
- [ ] **Step 2**: Set environment variables
- [ ] **Step 3**: Change profile to `cloud`
- [ ] **Step 4**: Test full system
- [ ] **Step 5**: Upload textbook data

## 🔍 **Troubleshooting**

### **If Health Checks Fail After Adding PostgreSQL:**
1. Check if `DATABASE_URL` is set correctly
2. Verify PostgreSQL service is running
3. Check application logs in Railway dashboard

### **If Application Won't Start:**
1. Make sure PostgreSQL is fully created before switching to `cloud` profile
2. Verify all environment variables are set
3. Check Railway logs for specific errors

## 🎯 **Success Indicators**

✅ **Step 1 Complete**: PostgreSQL service appears in Railway dashboard
✅ **Step 2 Complete**: Environment variables are set
✅ **Step 3 Complete**: Application redeploys successfully with `cloud` profile
✅ **Step 4 Complete**: Health checks pass with PostgreSQL
✅ **Step 5 Complete**: Web interface loads and works

## 🚀 **After Success**

Once everything is working:
1. **Upload your textbook PDFs** via the web interface
2. **Test RAG queries** to ensure AI responses work
3. **Share your tool** with others!

---

**Follow these steps in order and your RAG system will be fully functional!** 🚀📚✨
