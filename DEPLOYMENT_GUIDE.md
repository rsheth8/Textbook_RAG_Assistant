# 🚀 Deployment Guide - Host Your Textbook Assistant Online

## 🌟 **Free Hosting Options**

### **1. Railway.app (Recommended)**
- **Free tier**: $5 credit monthly
- **Easy deployment**: Git-based deployment
- **Custom domains**: Free SSL certificates
- **Database**: PostgreSQL included

### **2. Render.com**
- **Free tier**: 750 hours/month
- **Easy setup**: Connect GitHub repository
- **Custom domains**: Free SSL
- **Database**: PostgreSQL available

### **3. Heroku**
- **Free tier**: Discontinued, but affordable paid plans
- **Easy deployment**: Git-based
- **Custom domains**: Available

---

## 🚀 **Railway.app Deployment (Recommended)**

### **Step 1: Prepare Your Repository**

Your repository is already prepared with:
- ✅ `railway.json` - Railway configuration
- ✅ `nixpacks.toml` - Build configuration
- ✅ `application-cloud.yml` - Cloud configuration
- ✅ Environment variables support

### **Step 2: Deploy to Railway**

1. **Visit Railway.app**:
   - Go to https://railway.app
   - Sign up with your GitHub account

2. **Create New Project**:
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your repository: `rsheth8/Textbook_RAG_Assistant`

3. **Add PostgreSQL Database**:
   - Click "New Service"
   - Select "Database" → "PostgreSQL"
   - Railway will automatically link it

4. **Configure Environment Variables**:
   ```
   SPRING_PROFILES_ACTIVE=cloud
   DATABASE_URL=${DATABASE_URL}
   POSTGRES_USER=${POSTGRES_USER}
   POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
   OLLAMA_BASE_URL=https://api.ollama.ai
   OLLAMA_MODEL=llama2
   OLLAMA_EMBEDDING_MODEL=nomic-embed-text
   CHUNK_SIZE=300
   CHUNK_OVERLAP=50
   MAX_RETRIEVAL_RESULTS=3
   ```

5. **Deploy**:
   - Railway will automatically build and deploy
   - Monitor the build logs
   - Wait for deployment to complete

### **Step 3: Add Custom Domain**

1. **Get a Free Domain**:
   - **Freenom**: Get free domains like `.tk`, `.ml`, `.ga`
   - **GitHub Pages**: Use GitHub Pages with custom domain
   - **Cloudflare**: Free domain registration and DNS

2. **Configure Domain on Railway**:
   - Go to your Railway project
   - Click "Settings" → "Domains"
   - Add your custom domain
   - Railway provides free SSL certificate

---

## 🌐 **Render.com Deployment (Alternative)**

### **Step 1: Deploy to Render**

1. **Visit Render.com**:
   - Go to https://render.com
   - Sign up with GitHub

2. **Create New Web Service**:
   - Click "New" → "Web Service"
   - Connect your GitHub repository
   - Select the repository

3. **Configure Service**:
   ```
   Name: textbook-assistant
   Environment: Java
   Build Command: mvn clean package -DskipTests
   Start Command: java -Xmx2g -Xms1g -jar target/textbook-rag-assistant-0.0.1-SNAPSHOT.jar
   ```

4. **Add PostgreSQL Database**:
   - Create new PostgreSQL service
   - Link it to your web service

5. **Set Environment Variables**:
   ```
   SPRING_PROFILES_ACTIVE=cloud
   DATABASE_URL=${DATABASE_URL}
   OLLAMA_BASE_URL=https://api.ollama.ai
   ```

### **Step 2: Add Custom Domain**

1. **Configure Domain**:
   - Go to your web service
   - Click "Settings" → "Custom Domains"
   - Add your domain
   - Update DNS records

---

## 🔧 **Cloud Configuration**

### **Environment Variables**

```bash
# Database
DATABASE_URL=postgresql://username:password@host:port/database
POSTGRES_USER=your_username
POSTGRES_PASSWORD=your_password

# Ollama (Cloud Service)
OLLAMA_BASE_URL=https://api.ollama.ai
OLLAMA_MODEL=llama2
OLLAMA_EMBEDDING_MODEL=nomic-embed-text

# Application Settings
SPRING_PROFILES_ACTIVE=cloud
CHUNK_SIZE=300
CHUNK_OVERLAP=50
MAX_RETRIEVAL_RESULTS=3
PORT=8080
```

### **Cloud Ollama Services**

Since Ollama runs locally, you'll need a cloud alternative:

1. **Ollama Cloud** (if available)
2. **OpenAI API** (modify service to use OpenAI)
3. **Hugging Face Inference API**
4. **Self-hosted Ollama** on a VPS

---

## 🌐 **Custom Domain Setup**

### **Free Domain Options**

1. **Freenom**:
   - Get free domains: `.tk`, `.ml`, `.ga`, `.cf`
   - Point to your hosting service

2. **GitHub Pages + Custom Domain**:
   - Use GitHub Pages for static hosting
   - Add custom domain
   - Redirect to your app

3. **Cloudflare**:
   - Free domain registration
   - Free DNS and SSL

### **DNS Configuration**

```
Type: CNAME
Name: @
Value: your-app.railway.app
TTL: 300
```

---

## 📱 **Mobile Optimization**

Your application is already mobile-responsive with:
- ✅ Bootstrap 5 responsive design
- ✅ Mobile-friendly interface
- ✅ Touch-optimized controls
- ✅ Responsive text sizing

---

## 🔒 **Security Considerations**

### **Production Security**

1. **Environment Variables**:
   - Never commit secrets to Git
   - Use platform environment variables

2. **HTTPS**:
   - All platforms provide free SSL
   - Force HTTPS redirect

3. **Rate Limiting**:
   - Consider adding rate limiting
   - Monitor usage

4. **File Upload Security**:
   - Validate file types
   - Limit file sizes
   - Scan for malware

---

## 📊 **Monitoring and Analytics**

### **Free Monitoring Tools**

1. **Railway/Render Built-in**:
   - Logs and metrics
   - Performance monitoring

2. **Google Analytics**:
   - Add to your web interface
   - Track usage and users

3. **Uptime Monitoring**:
   - UptimeRobot (free)
   - Pingdom (free tier)

---

## 🚀 **Quick Deployment Commands**

### **Railway CLI (Alternative)**

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Deploy from local directory
railway up

# View logs
railway logs

# Open in browser
railway open
```

### **Heroku CLI (Alternative)**

```bash
# Install Heroku CLI
# Create Heroku app
heroku create your-app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set SPRING_PROFILES_ACTIVE=cloud

# Deploy
git push heroku main

# Open app
heroku open
```

---

## 🎯 **Post-Deployment Checklist**

### **Essential Checks**

- ✅ **Application Health**: Check `/api/v1/health`
- ✅ **Database Connection**: Verify PostgreSQL connection
- ✅ **File Upload**: Test PDF upload functionality
- ✅ **RAG Processing**: Test query functionality
- ✅ **Mobile Responsiveness**: Test on mobile devices
- ✅ **Custom Domain**: Verify domain works
- ✅ **SSL Certificate**: Confirm HTTPS works
- ✅ **Performance**: Monitor response times

### **User Experience**

- ✅ **Loading Times**: Optimize for speed
- ✅ **Error Handling**: Graceful error messages
- ✅ **User Feedback**: Loading indicators
- ✅ **Accessibility**: Screen reader support

---

## 🌟 **Sharing Your Application**

### **Share Links**

Once deployed, share your application:

1. **Direct Link**: `https://your-domain.com`
2. **GitHub Repository**: Include deployment instructions
3. **Demo Video**: Create a quick demo
4. **Documentation**: User guide for others

### **Promotion Ideas**

- 📚 **Educational Communities**: Share with students and teachers
- 🎓 **University Groups**: Post in academic forums
- 💻 **Developer Communities**: Share on Reddit, Hacker News
- 📖 **Study Groups**: Share with classmates

---

## 🎉 **Success!**

**Your Textbook Assistant is now live online!**

**Features Available**:
- 🌐 **Global Access**: Anyone can use your tool
- 📱 **Mobile Friendly**: Works on all devices
- 🔒 **Secure**: HTTPS and environment variables
- 📚 **Textbook-Faithful**: AI teaches exactly as textbooks do
- 🎨 **Beautiful UI**: Modern gradient design
- ⚡ **Fast**: Optimized for cloud deployment

**Share your application and help others learn!** 🚀📚✨
