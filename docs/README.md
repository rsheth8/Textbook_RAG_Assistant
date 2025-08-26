# Math Textbook RAG Assistant

A custom RAG (Retrieval-Augmented Generation) application powered by Ollama models and PostgreSQL vector database, specifically designed to help you learn from math textbooks.

## Features

- **PDF Processing**: Extract and process math textbook content
- **Vector Database**: Store embeddings in PostgreSQL with pgvector extension
- **Ollama Integration**: Use local LLM models for inference
- **RAG Pipeline**: Intelligent retrieval and generation for math learning
- **Web Interface**: Streamlit-based UI for easy interaction
- **Summarization**: High-level summaries of textbook sections
- **Teaching Mode**: Interactive learning with step-by-step explanations

## Prerequisites

1. **PostgreSQL** with pgvector extension
2. **Ollama** installed and running locally
3. **Python 3.8+**

## Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. PostgreSQL Setup
```bash
# Install PostgreSQL (if not already installed)
# On macOS: brew install postgresql
# On Ubuntu: sudo apt-get install postgresql postgresql-contrib

# Install pgvector extension
# Follow instructions at: https://github.com/pgvector/pgvector
```

### 3. Environment Configuration
Create a `.env` file:
```bash
cp .env.example .env
# Edit .env with your database credentials and Ollama settings
```

### 4. Database Setup
```bash
python scripts/setup_database.py
```

### 5. Start the Application
```bash
# Start the FastAPI backend
uvicorn app.main:app --reload

# Start the Streamlit frontend (in another terminal)
streamlit run app/streamlit_app.py
```

## Usage

1. Upload your math textbook PDF
2. The system will process and chunk the content
3. Ask questions about the material
4. Get summaries and explanations at your preferred level

## Project Structure

```
TextbookAssistant/
├── app/
│   ├── main.py              # FastAPI backend
│   ├── streamlit_app.py     # Streamlit frontend
│   ├── models/              # Database models
│   ├── services/            # Business logic
│   └── utils/               # Utility functions
├── scripts/
│   └── setup_database.py    # Database initialization
├── data/                    # Uploaded PDFs and processed data
└── requirements.txt
```

## Models Used

- **Embedding Model**: sentence-transformers/all-MiniLM-L6-v2
- **LLM**: Ollama (configurable - recommend llama2 or codellama for math)
- **Vector Database**: PostgreSQL with pgvector

## License

MIT
