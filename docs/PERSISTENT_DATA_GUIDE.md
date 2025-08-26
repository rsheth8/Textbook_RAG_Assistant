# 💾 Persistent Data Management Guide

## 🎯 **One-Time Setup for Permanent PDF Storage**

Your RAG system can store PDFs permanently in the database, so they're always available when you restart the application.

## 🚀 **How to Pre-Load Your 700-Page PDF**

### **Step 1: Pre-Load Your PDF (One-Time Process)**
```bash
# Make scripts executable
chmod +x preload_pdf.sh check_preloaded_documents.sh

# Pre-load your PDF (this will start the app if needed)
./preload_pdf.sh /path/to/your/math_textbook.pdf
```

**What happens:**
- ✅ Starts the application automatically if not running
- ✅ Uploads your PDF to the database
- ✅ Processes it once (15-35 minutes for 700 pages)
- ✅ Stores it permanently in PostgreSQL
- ✅ Saves document info to `preloaded_documents.txt`

### **Step 2: Verify Pre-Loaded Documents**
```bash
# Check what documents are in the database
./check_preloaded_documents.sh
```

### **Step 3: Use Your Persistent Data**
```bash
# Start the application (if not running)
mvn spring-boot:run

# Open in browser
open http://localhost:8080
```

## 📊 **Data Persistence Architecture**

### **🗄️ Database Storage:**
- **Documents Table**: Metadata about your PDFs
- **Document Chunks Table**: Text chunks with vector embeddings
- **PostgreSQL with pgvector**: Efficient vector similarity search

### **💾 What Gets Stored Permanently:**
- ✅ **PDF Metadata**: Filename, size, upload date
- ✅ **Extracted Text**: Full text content from PDF
- ✅ **Text Chunks**: 1500-character chunks with 300-character overlap
- ✅ **Vector Embeddings**: 4096-dimensional vectors for each chunk
- ✅ **Processing Status**: Completion status and error messages

### **🔄 What Persists Across Restarts:**
- ✅ **All uploaded PDFs**
- ✅ **All processed chunks and embeddings**
- ✅ **All document metadata**
- ✅ **All chat history** (if implemented)

## 🛠️ **Management Commands**

### **📋 Check Pre-Loaded Documents**
```bash
./check_preloaded_documents.sh
```

### **📤 Pre-Load Additional PDFs**
```bash
./preload_pdf.sh /path/to/another_textbook.pdf
```

### **🗑️ Remove Documents (if needed)**
```bash
# Delete document by ID (replace 1 with actual ID)
curl -X DELETE http://localhost:8080/api/v1/documents/1
```

### **📊 Database Management**
```bash
# Check database status
./manage_db.sh status

# Connect to database
./manage_db.sh connect

# View tables
\dt
SELECT * FROM documents;
SELECT COUNT(*) FROM document_chunks;
```

## 🎯 **Workflow for Your 700-Page PDF**

### **One-Time Setup:**
1. **Pre-load your PDF**:
   ```bash
   ./preload_pdf.sh ~/Downloads/math_textbook.pdf
   ```

2. **Wait for processing** (15-35 minutes):
   - Text extraction: 5-10 minutes
   - Chunking: 2-5 minutes
   - Embedding generation: 10-20 minutes

3. **Verify completion**:
   ```bash
   ./check_preloaded_documents.sh
   ```

### **Daily Usage:**
1. **Start the application**:
   ```bash
   mvn spring-boot:run
   ```

2. **Access the web interface**:
   - Go to http://localhost:8080
   - Your PDF will be listed in the documents

3. **Start chatting**:
   - Click "Chat" on your document
   - Ask questions about your math textbook

4. **Stop when done**:
   - Press Ctrl+C to stop the application
   - Your data remains in the database

## 📈 **Performance Benefits**

### **🚀 Fast Startup:**
- No need to re-upload PDFs
- No need to re-process text
- No need to re-generate embeddings
- Application starts in ~30 seconds

### **💾 Efficient Storage:**
- PostgreSQL handles large datasets efficiently
- pgvector provides fast similarity search
- Compressed storage of embeddings
- Indexed for quick retrieval

### **🔄 Scalability:**
- Add multiple PDFs
- Each PDF processed once
- All available for questions
- No storage limits (within disk space)

## 🔧 **Troubleshooting**

### **If Pre-Loading Fails:**
```bash
# Check application logs
tail -f app.log

# Check database connection
./manage_db.sh status

# Restart and try again
pkill -f "mvn spring-boot:run"
./preload_pdf.sh your_pdf.pdf
```

### **If Documents Don't Appear:**
```bash
# Check database directly
./manage_db.sh connect
SELECT * FROM documents;
SELECT COUNT(*) FROM document_chunks;
```

### **If Processing Takes Too Long:**
- **Normal**: 15-35 minutes for 700 pages
- **Check Ollama**: `curl -s http://localhost:11434/api/tags`
- **Monitor memory**: `top` or Activity Monitor

## 🎉 **Benefits of This Approach**

### **✅ One-Time Processing:**
- Upload and process your 700-page PDF once
- Never need to re-upload or re-process
- Saves time and computational resources

### **✅ Always Available:**
- Start/stop application anytime
- Your PDF is always ready for questions
- No waiting for processing

### **✅ Multiple PDFs:**
- Add more textbooks as needed
- All available simultaneously
- Cross-reference between documents

### **✅ Persistent Storage:**
- Data survives application restarts
- Data survives system reboots
- Only lost if you delete the database

## 🚀 **Ready to Pre-Load Your PDF?**

Your system is ready for persistent data storage! Just run:

```bash
./preload_pdf.sh /path/to/your/700-page-math-textbook.pdf
```

**After the one-time processing, your PDF will be permanently available for questions!** 🎓📚
