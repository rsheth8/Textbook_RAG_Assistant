# Setup Bundled Open WebUI + Ollama Service

## Step 1: Create the Bundled Service in Railway Dashboard

1. Go to your Railway project dashboard
2. Click "New Service"
3. Choose "Deploy from Docker Image"
4. Enter: `ghcr.io/open-webui/open-webui:ollama`
5. Name it: `open-webui-ollama`
6. Set these environment variables:
   - `OLLAMA_HOST=0.0.0.0`
   - `OLLAMA_ORIGINS=*`

## Step 2: Wait for Deployment

The service will take a few minutes to deploy and pull the models.

## Step 3: Get the Service URL

Once deployed, note the public URL (e.g., `https://open-webui-ollama-production-xxxx.up.railway.app`)

## Step 4: Update Spring Boot Configuration

Update your Railway variables for the `web` service:

```bash
railway variables --set OLLAMA_BASE_URL=https://your-bundled-service-url.up.railway.app
railway variables --set OPEN_WEBUI_API_KEY=sk-d023fa4607704ac1bc6f8b7a6a7d2ba4
```

## Step 5: Test the Setup

1. Visit the bundled service URL to access Open WebUI interface
2. Test your Spring Boot API
3. Check logs for any issues

## Benefits

- ✅ Single service (no networking issues)
- ✅ Built-in Ollama with models
- ✅ Open WebUI interface for management
- ✅ API access for your Spring Boot app
