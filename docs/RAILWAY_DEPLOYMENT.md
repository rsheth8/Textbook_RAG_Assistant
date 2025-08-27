# Railway Deployment Guide

## 🚀 Deploying Textbook Assistant to Railway

### Prerequisites
- Railway account (https://railway.app)
- GitHub repository with your code
- Your textbook PDF file

### Step 1: Prepare Your Repository

1. **Push your code to GitHub**:
   ```bash
   git add .
   git commit -m "Ready for Railway deployment"
   git push origin main
   ```

2. **Ensure these files are in your repository**:
   - `railway.toml` - Railway configuration
   - `pom.xml` - Maven dependencies
   - `Dockerfile` - Container configuration
   - `src/main/resources/application-cloud.yml` - Cloud configuration

### Step 2: Create Railway Project

1. **Go to Railway Dashboard**: https://railway.app/dashboard
2. **Create New Project**: Click "New Project"
3. **Connect GitHub**: Select your repository
4. **Add PostgreSQL Database**:
   - Click "Add Service"
   - Select "Database" → "PostgreSQL"
   - Railway will automatically create a PostgreSQL instance

### Step 3: Configure Environment Variables

Railway will automatically provide these database variables:
- `DATABASE_URL`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_HOST`
- `POSTGRES_PORT`

**Additional variables to set**:
- `SPRING_PROFILES_ACTIVE=cloud`
- `OLLAMA_BASE_URL=https://your-ollama-instance.com` (update with your Ollama URL)
- `OLLAMA_MODEL=gemma2`
- `OLLAMA_TEMPERATURE=0.7`
- `OLLAMA_MAX_TOKENS=2048`
- `OLLAMA_EMBEDDING_MODEL=nomic-embed-text`

### Step 4: Deploy

1. **Railway will automatically detect your Java application**
2. **Build will start automatically** when you push to GitHub
3. **Monitor the deployment** in Railway dashboard
4. **Check logs** for any issues

### Step 5: Upload Your Textbook

Once deployed, you can upload your textbook:

1. **Via Web Interface**:
   - Go to your Railway app URL
   - Use the upload form to upload your PDF

2. **Via API**:
   ```bash
   curl -X POST -F "file=@/path/to/your/textbook.pdf" https://your-app.railway.app/api/v1/upload
   ```

### Step 6: Test the Application

1. **Health Check**: `https://your-app.railway.app/health`
2. **Main Interface**: `https://your-app.railway.app/`
3. **API Endpoints**: `https://your-app.railway.app/api/v1/`

## 🔧 Troubleshooting

### Common Issues

1. **Database Connection Failed**:
   - Check that PostgreSQL service is running
   - Verify environment variables are set correctly
   - Check Railway logs for connection errors

2. **Build Failed**:
   - Check that `pom.xml` is valid
   - Ensure all dependencies are available
   - Check Railway build logs

3. **Application Won't Start**:
   - Check Railway logs for startup errors
   - Verify `PORT` environment variable is set
   - Check health endpoint

### Monitoring

- **Railway Dashboard**: Monitor CPU, memory, and network usage
- **Application Logs**: View real-time logs in Railway dashboard
- **Health Checks**: Monitor `/health` endpoint

## 📊 Performance Optimization

### Database Optimization
- Railway PostgreSQL automatically scales
- Connection pooling is configured for optimal performance
- Indexes are created for fast queries

### Application Optimization
- JVM heap size set to 2GB (`-Xmx2g`)
- Connection pooling with HikariCP
- Batch processing for database operations

## 🔒 Security Considerations

1. **Environment Variables**: Never commit sensitive data to Git
2. **Database Access**: Railway manages database security
3. **File Uploads**: Configured with size limits and validation
4. **CORS**: Configured for web access

## 📈 Scaling

Railway automatically scales your application based on:
- CPU usage
- Memory usage
- Request volume

You can also manually scale in the Railway dashboard.

## 🔄 Updates

To update your application:
1. Push changes to GitHub
2. Railway automatically redeploys
3. Monitor deployment in dashboard
4. Test the updated application

## 📞 Support

- **Railway Documentation**: https://docs.railway.app
- **Railway Discord**: https://discord.gg/railway
- **Application Logs**: Check Railway dashboard for detailed logs
