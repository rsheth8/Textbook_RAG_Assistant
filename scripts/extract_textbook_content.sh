#!/bin/bash

# Extract Textbook Content Script
# This script extracts the full textbook content from the local database
# and saves it to a file that can be used in the cloud initialization

echo "Extracting textbook content from local database..."

# Extract the full content from the database
content=$(docker exec textbook_assistant_db psql -U postgres -d textbook_assistant -t -c "SELECT extracted_text FROM documents WHERE id = 1;" 2>/dev/null)

if [ $? -eq 0 ] && [ ! -z "$content" ]; then
    echo "Successfully extracted content from database"
    
    # Create the output file
    cat > src/main/resources/textbook_content.txt << 'EOF'
// This file contains the extracted content from Applied Linear Algebra textbook
// Used for automatic database initialization in cloud deployment

public static String getTextbookContent() {
    return """
EOF

    # Add the content with proper escaping
    echo "$content" | sed 's/"/\\"/g' | sed 's/\\/\\\\/g' >> src/main/resources/textbook_content.txt
    
    # Close the method
    cat >> src/main/resources/textbook_content.txt << 'EOF'
    """;
}
EOF

    echo "✅ Textbook content extracted and saved to src/main/resources/textbook_content.txt"
    echo "📄 Content length: $(echo "$content" | wc -c) characters"
    
else
    echo "❌ Failed to extract content from database"
    echo "Make sure the application is running and the textbook is uploaded"
    exit 1
fi
