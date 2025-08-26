# Railway Environment Variables Setup

## Where to Add Environment Variables
**Important**: Add these to your **main application service** (not the PostgreSQL service).

## Required Environment Variables

### 1. Ollama Configuration
```
OLLAMA_BASE_URL=https://api.ollama.ai
OLLAMA_MODEL=llama2
OLLAMA_EMBEDDING_MODEL=nomic-embed-text
OLLAMA_TEMPERATURE=0.7
OLLAMA_MAX_TOKENS=2048
```

### 2. Application Configuration (Optional - these are defaults)
```
CHUNK_SIZE=300
CHUNK_OVERLAP=50
MAX_RETRIEVAL_RESULTS=3
UPLOAD_DIR=/tmp/uploads
PROCESSED_DIR=/tmp/processed
```

## How to Add Environment Variables in Railway

### Step 1: Go to Your Application Service
1. In your Railway project dashboard
2. Click on your **main application service** (not PostgreSQL)
3. Go to the **Variables** tab

### Step 2: Add Each Variable
1. Click **New Variable**
2. Add each variable from the list above
3. Make sure to use the exact names and values

### Step 3: Verify PostgreSQL Variables
The PostgreSQL service should automatically provide these:
- `DATABASE_URL`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_HOST`
- `POSTGRES_PORT`
- `POSTGRES_DB`

## Quick Copy-Paste List
```
OLLAMA_BASE_URL=https://api.ollama.ai
OLLAMA_MODEL=llama2
OLLAMA_EMBEDDING_MODEL=nomic-embed-text
OLLAMA_TEMPERATURE=0.7
OLLAMA_MAX_TOKENS=2048
CHUNK_SIZE=300
CHUNK_OVERLAP=50
MAX_RETRIEVAL_RESULTS=3
UPLOAD_DIR=/tmp/uploads
PROCESSED_DIR=/tmp/processed
```

## After Adding Variables
1. Railway will automatically redeploy your application
2. Check the deployment logs to see if everything connects properly
3. Test the application functionality

## Expected Log Messages
You should see in the logs:
- ✅ "Database connection test successful!"
- ✅ "Database configuration complete"
- ✅ "Application is ready to serve requests"
