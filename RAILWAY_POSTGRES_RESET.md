# Railway PostgreSQL Reset Guide

## Step 1: Remove Current PostgreSQL Service
1. Go to your Railway project dashboard
2. Find the PostgreSQL service in your project
3. Click on the PostgreSQL service
4. Go to **Settings** tab
5. Scroll down to **Danger Zone**
6. Click **Delete Service**
7. Confirm the deletion

## Step 2: Add New PostgreSQL Service
1. In your Railway project dashboard
2. Click **New Service** → **Database** → **PostgreSQL**
3. Wait for the service to be created (usually takes 1-2 minutes)
4. The service will automatically be connected to your main application

## Step 3: Verify Environment Variables
After the new PostgreSQL service is created, check that these environment variables are automatically set:
- `DATABASE_URL` (should be something like `postgresql://postgres:password@postgres.railway.internal:5432/railway`)
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_HOST`
- `POSTGRES_PORT`
- `POSTGRES_DB`

## Step 4: Switch Back to Cloud Profile
Once the new PostgreSQL service is ready, we'll switch back to the `cloud` profile:

1. Update `railway.json`:
```json
{
  "deploy": {
    "startCommand": "java -Xmx2g -Xms1g -XX:+UseG1GC -Dspring.profiles.active=cloud -jar target/textbook-rag-assistant-1.0.0.jar"
  }
}
```

2. Update `railway.toml`:
```toml
[deploy]
startCommand = "java -Xmx2g -Xms1g -XX:+UseG1GC -Dspring.profiles.active=cloud -jar target/textbook-rag-assistant-1.0.0.jar"
```

3. Commit and push the changes

## Step 5: Monitor Deployment
- Watch the Railway deployment logs
- The application should now connect successfully to the fresh PostgreSQL database
- Health checks should pass

## Troubleshooting
If you still see connection issues:
1. Check that the `DATABASE_URL` format is correct
2. Verify the PostgreSQL service is fully provisioned
3. Check Railway's status page for any service issues
4. Use the debug script: `./debug_railway_db.sh`

## Expected Result
After this process:
- ✅ Fresh PostgreSQL database
- ✅ Clean connection parameters
- ✅ No stale connection issues
- ✅ Application starts successfully
- ✅ Health checks pass
