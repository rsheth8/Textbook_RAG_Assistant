#!/bin/bash

# Textbook Upload Script
# Usage: ./upload_textbook.sh /path/to/your/textbook.pdf

if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/your/textbook.pdf"
    echo "Example: $0 ~/Downloads/Applied_Linear_Algebra.pdf"
    exit 1
fi

TEXTBOOK_PATH="$1"
APP_URL="http://localhost:8080"

if [ ! -f "$TEXTBOOK_PATH" ]; then
    echo "Error: File not found: $TEXTBOOK_PATH"
    exit 1
fi

echo "Uploading textbook: $TEXTBOOK_PATH"
echo "Application URL: $APP_URL"
echo ""

# Upload the file
response=$(curl -s -X POST -F "file=@$TEXTBOOK_PATH" "$APP_URL/api/v1/upload")

if [ $? -eq 0 ]; then
    echo "✅ Upload successful!"
    echo "Response: $response"
else
    echo "❌ Upload failed!"
    echo "Make sure the application is running on $APP_URL"
fi
