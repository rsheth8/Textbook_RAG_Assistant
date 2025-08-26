# 🚀 Quick Deployment Guide

## ⚡ **Deploy Your Textbook Assistant in 5 Minutes**

### **Option 1: Railway.app (Recommended - Free)**

1. **Visit Railway.app**:
   - Go to https://railway.app
   - Sign up with your GitHub account

2. **Deploy from GitHub**:
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose: `rsheth8/Textbook_RAG_Assistant`

3. **Add Database**:
   - Click "New Service"
   - Select "Database" → "PostgreSQL"
   - Railway auto-links it

4. **Set Environment Variables**:
   ```
   SPRING_PROFILES_ACTIVE=cloud
   OLLAMA_BASE_URL=https://api.ollama.ai
   OLLAMA_MODEL=llama2
   OLLAMA_EMBEDDING_MODEL=nomic-embed-text
   ```

5. **Deploy**:
   - Railway builds and deploys automatically
   - Get your URL: `https://your-app.railway.app`

### **Option 2: Render.com (Alternative - Free)**

1. **Visit Render.com**:
   - Go to https://render.com
   - Sign up with GitHub

2. **Create Web Service**:
   - Click "New" → "Web Service"
   - Connect your GitHub repo
   - Select: `rsheth8/Textbook_RAG_Assistant`

3. **Configure**:
   ```
   Build Command: mvn clean package -DskipTests
   Start Command: java -Xmx2g -Xms1g -jar target/textbook-rag-assistant-0.0.1-SNAPSHOT.jar
   ```

4. **Add PostgreSQL**:
   - Create new PostgreSQL service
   - Link to web service

5. **Deploy**:
   - Render builds and deploys
   - Get your URL: `https://your-app.onrender.com`

---

## 🌐 **Add Custom Domain (Free)**

### **Get Free Domain**:
1. **Freenom**: Get `.tk`, `.ml`, `.ga` domains
2. **GitHub Pages**: Use with custom domain
3. **Cloudflare**: Free domain registration

### **Configure Domain**:
- **Railway**: Settings → Domains → Add domain
- **Render**: Settings → Custom Domains → Add domain
- **DNS**: Point to your app URL

---

## 🔧 **Environment Variables**

```bash
# Required
SPRING_PROFILES_ACTIVE=cloud
DATABASE_URL=${DATABASE_URL}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

# Ollama Configuration
OLLAMA_BASE_URL=https://api.ollama.ai
OLLAMA_MODEL=llama2
OLLAMA_EMBEDDING_MODEL=nomic-embed-text

# Application Settings
CHUNK_SIZE=300
CHUNK_OVERLAP=50
MAX_RETRIEVAL_RESULTS=3
PORT=8080
```

---

## 🎯 **Post-Deployment Checklist**

- ✅ **Health Check**: Visit `/api/v1/health`
- ✅ **Web Interface**: Test main page
- ✅ **File Upload**: Test PDF upload
- ✅ **RAG Processing**: Test queries
- ✅ **Mobile Test**: Check mobile responsiveness
- ✅ **Custom Domain**: Verify domain works
- ✅ **SSL**: Confirm HTTPS works

---

## 🌟 **Share Your Application**

### **Share Links**:
- **Direct URL**: `https://your-domain.com`
- **GitHub**: https://github.com/rsheth8/Textbook_RAG_Assistant

### **Promote**:
- 📚 **Educational communities**
- 🎓 **University groups**
- 💻 **Developer forums**
- 📖 **Study groups**

---

## 🎉 **Success!**

**Your Textbook Assistant is now live online!**

**Features**:
- 🌐 **Global Access**: Anyone can use it
- 📱 **Mobile Friendly**: Works on all devices
- 🔒 **Secure**: HTTPS and environment variables
- 📚 **Textbook-Faithful**: AI teaches exactly as textbooks do
- 🎨 **Beautiful UI**: Modern gradient design
- ⚡ **Fast**: Optimized for cloud deployment

**Share and help others learn!** 🚀📚✨
