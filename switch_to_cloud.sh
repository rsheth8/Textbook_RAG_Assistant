#!/bin/bash

echo "🔄 Switching to Cloud Profile with PostgreSQL"
echo "============================================="

echo "Updating railway.json..."
cat > railway.json << 'EOF'
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "java -Xmx2g -Xms1g -XX:+UseG1GC -Dspring.profiles.active=cloud -jar target/textbook-rag-assistant-1.0.0.jar",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 300,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
EOF

echo "Updating railway.toml..."
cat > railway.toml << 'EOF'
[deploy]
startCommand = "java -Xmx2g -Xms1g -XX:+UseG1GC -Dspring.profiles.active=cloud -jar target/textbook-rag-assistant-1.0.0.jar"
healthcheckPath = "/health"
healthcheckTimeout = 300
restartPolicyType = "ON_FAILURE"
EOF

echo "Updating nixpacks.toml..."
cat > nixpacks.toml << 'EOF'
[phases.setup]
nixPkgs = ["jdk17", "maven"]

[phases.install]
cmds = ["mvn clean package -DskipTests"]

[start]
cmd = "java -Xmx2g -Xms1g -XX:+UseG1GC -Dspring.profiles.active=cloud -jar target/textbook-rag-assistant-1.0.0.jar"
EOF

echo "Updating Procfile..."
cat > Procfile << 'EOF'
web: java -Xmx2g -Xms1g -XX:+UseG1GC -Dspring.profiles.active=cloud -jar target/textbook-rag-assistant-1.0.0.jar
EOF

echo "✅ All Railway configuration files updated to use 'cloud' profile"
echo ""
echo "🚀 Next steps:"
echo "1. git add ."
echo "2. git commit -m 'Switch to cloud profile for PostgreSQL deployment'"
echo "3. git push"
echo "4. Monitor Railway deployment logs"
echo ""
echo "📋 Make sure you have:"
echo "- Fresh PostgreSQL service added to Railway"
echo "- All environment variables set (DATABASE_URL, etc.)"
echo "- Ollama environment variables configured"
