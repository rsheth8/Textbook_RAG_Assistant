package com.textbookassistant.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.textbookassistant.dto.QueryRequest;
import com.textbookassistant.dto.QueryResponse;
import com.textbookassistant.model.Document;
import com.textbookassistant.model.DocumentChunk;
import com.textbookassistant.repository.DocumentChunkRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;
import java.lang.Thread;

@Service
public class RagService {
    
    private static final Logger logger = LoggerFactory.getLogger(RagService.class);
    
    private final EmbeddingService embeddingService;
    private final OllamaService ollamaService;
    private final DocumentChunkRepository documentChunkRepository;
    private final ObjectMapper objectMapper;
    
    @Value("${app.chunk.size:1000}")
    private int chunkSize;
    
    @Value("${app.chunk.overlap:200}")
    private int chunkOverlap;
    
    @Value("${app.max-retrieval-results:5}")
    private int maxRetrievalResults;
    
    public RagService(EmbeddingService embeddingService, 
                     OllamaService ollamaService,
                     DocumentChunkRepository documentChunkRepository) {
        this.embeddingService = embeddingService;
        this.ollamaService = ollamaService;
        this.documentChunkRepository = documentChunkRepository;
        this.objectMapper = new ObjectMapper();
    }
    
    public void processDocumentForRag(Document document) {
        try {
            logger.info("Processing document for RAG: {}", document.getOriginalFilename());
            
            // Delete existing chunks for this document
            documentChunkRepository.deleteByDocumentId(document.getId());
            
            // Split text into chunks
            List<String> chunks = splitTextIntoChunks(document.getExtractedText());
            
            // Process each chunk
            for (int i = 0; i < chunks.size(); i++) {
                String chunk = chunks.get(i);
                
                // Generate embedding
                List<Double> embedding = embeddingService.generateEmbedding(chunk);
                
                if (!embedding.isEmpty()) {
                    // Create document chunk
                    DocumentChunk documentChunk = new DocumentChunk(document.getId(), chunk, i);
                    documentChunk.setEmbedding(convertEmbeddingToString(embedding));
                    documentChunk.setMetadata("{\"documentId\": " + document.getId() + 
                                           ", \"filename\": \"" + document.getOriginalFilename() + "\"}");
                    
                    documentChunkRepository.save(documentChunk);
                }
            }
            
            logger.info("Successfully processed {} chunks for document {}", chunks.size(), document.getId());
            
        } catch (Exception e) {
            logger.error("Error processing document for RAG: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to process document for RAG", e);
        }
    }
    
    public void processTextChunks(Long documentId, String text) {
        try {
            logger.info("Processing text chunks for document ID: {}", documentId);
            
            if (text == null || text.trim().isEmpty()) {
                logger.warn("Empty text provided for document ID {}", documentId);
                return;
            }
            
            // Split text into chunks
            List<String> chunks = splitTextIntoChunks(text);
            logger.info("Split text into {} chunks for document ID {}", chunks.size(), documentId);
            
            if (chunks.isEmpty()) {
                logger.warn("No chunks created for document ID {}", documentId);
                return;
            }
            
            int successfulChunks = 0;
            int failedChunks = 0;
            
            // Process each chunk with individual error handling
            for (int i = 0; i < chunks.size(); i++) {
                String chunk = chunks.get(i);
                
                try {
                    // Skip empty chunks
                    if (chunk == null || chunk.trim().isEmpty()) {
                        logger.debug("Skipping empty chunk {} for document ID {}", i, documentId);
                        continue;
                    }
                    
                    // Limit chunk size to avoid embedding issues
                    if (chunk.length() > 3000) {
                        logger.warn("Chunk {} for document ID {} is too large ({} chars), truncating", i, documentId, chunk.length());
                        chunk = chunk.substring(0, 3000);
                    }
                    
                    logger.debug("Processing chunk {} for document ID {} ({} chars)", i, documentId, chunk.length());
                    
                    // Generate embedding with timeout handling
                    List<Double> embedding = embeddingService.generateEmbedding(chunk);
                    
                    if (!embedding.isEmpty()) {
                        // Create document chunk
                        DocumentChunk documentChunk = new DocumentChunk(documentId, chunk, i);
                        documentChunk.setEmbedding(convertEmbeddingToString(embedding));
                        
                        documentChunkRepository.save(documentChunk);
                        successfulChunks++;
                        
                        logger.debug("Successfully processed chunk {} for document ID {}", i, documentId);
                        
                        // Add small delay to prevent overwhelming the system
                        if (i % 5 == 0 && i > 0) {
                            Thread.sleep(100);
                        }
                    } else {
                        logger.warn("Empty embedding for chunk {} of document ID {}", i, documentId);
                        failedChunks++;
                    }
                    
                } catch (Exception chunkError) {
                    logger.error("Error processing chunk {} for document ID {}: {}", i, documentId, chunkError.getMessage());
                    failedChunks++;
                    // Continue with next chunk instead of failing entire process
                }
            }
            
            logger.info("Completed processing for document ID {}: {} successful, {} failed chunks", 
                       documentId, successfulChunks, failedChunks);
            
            if (successfulChunks == 0) {
                logger.error("No chunks were successfully processed for document ID {}", documentId);
            }
            
        } catch (Exception e) {
            logger.error("Error processing text chunks for document ID {}: {}", documentId, e.getMessage(), e);
            throw new RuntimeException("Failed to process text chunks", e);
        }
    }
    
    public QueryResponse processQuery(QueryRequest request) {
        try {
            logger.info("Processing query: {}", request.getQuery());
            
            // Generate embedding for the query
            List<Double> queryEmbedding = embeddingService.generateEmbedding(request.getQuery());
            
            if (queryEmbedding.isEmpty()) {
                return new QueryResponse(
                    "Sorry, I couldn't process your query at this time.",
                    List.of(),
                    request.getLearningLevel(),
                    request.getResponseType(),
                    request.getQuery(),
                    request.getDocumentId()
                );
            }
            
            // Find relevant chunks
            List<DocumentChunk> relevantChunks = findRelevantChunks(request.getDocumentId(), queryEmbedding);
            
            // Extract content from chunks
            List<String> chunkContents = relevantChunks.stream()
                .map(DocumentChunk::getContent)
                .collect(Collectors.toList());
            
            // Generate response using Ollama
            String answer = generateRagResponse(request, chunkContents);
            
            return new QueryResponse(
                answer,
                chunkContents,
                request.getLearningLevel(),
                request.getResponseType(),
                request.getQuery(),
                request.getDocumentId()
            );
            
        } catch (Exception e) {
            logger.error("Error processing query: {}", e.getMessage(), e);
            return new QueryResponse(
                "Sorry, I encountered an error while processing your question.",
                List.of(),
                request.getLearningLevel(),
                request.getResponseType(),
                request.getQuery(),
                request.getDocumentId()
            );
        }
    }
    
    private List<String> splitTextIntoChunks(String text) {
        List<String> chunks = new ArrayList<>();
        
        if (text == null || text.length() == 0) {
            return chunks;
        }
        
        // Clean up text first - remove extra whitespace
        text = text.replaceAll("\\s+", " ").trim();
        
        // If text is small enough, return as single chunk
        if (text.length() <= chunkSize) {
            chunks.add(text);
            return chunks;
        }
        
        // Simple chunking by sentences first, then by size
        String[] sentences = text.split("(?<=[.!?])\\s+");
        StringBuilder currentChunk = new StringBuilder();
        
        for (String sentence : sentences) {
            sentence = sentence.trim();
            if (sentence.isEmpty()) continue;
            
            // If adding this sentence would exceed chunk size, save current chunk and start new one
            if (currentChunk.length() + sentence.length() + 1 > chunkSize) {
                if (currentChunk.length() > 0) {
                    chunks.add(currentChunk.toString().trim());
                    currentChunk = new StringBuilder();
                }
                
                // If single sentence is too long, split it
                if (sentence.length() > chunkSize) {
                    int start = 0;
                    while (start < sentence.length()) {
                        int end = Math.min(start + chunkSize, sentence.length());
                        String subChunk = sentence.substring(start, end).trim();
                        if (subChunk.length() > 10) {
                            chunks.add(subChunk);
                        }
                        start = end;
                    }
                } else {
                    currentChunk.append(sentence);
                }
            } else {
                if (currentChunk.length() > 0) {
                    currentChunk.append(" ");
                }
                currentChunk.append(sentence);
            }
        }
        
        // Add remaining chunk
        if (currentChunk.length() > 0) {
            chunks.add(currentChunk.toString().trim());
        }
        
        logger.debug("Created {} chunks from text of length {}", chunks.size(), text.length());
        return chunks;
    }
    
    private List<DocumentChunk> findRelevantChunks(Long documentId, List<Double> queryEmbedding) {
        List<DocumentChunk> allChunks;
        
        // If documentId is null or 0, search across ALL textbook chunks
        if (documentId == null || documentId == 0) {
            logger.info("Searching across ALL textbook chunks for comprehensive answers");
            allChunks = documentChunkRepository.findAllTextbookChunks();
        } else {
            logger.info("Searching within specific document ID: {}", documentId);
            allChunks = documentChunkRepository.findByDocumentIdOrderByChunkIndex(documentId);
        }
        
        // Calculate similarities and sort
        List<Map.Entry<DocumentChunk, Double>> chunkSimilarities = allChunks.stream()
            .map(chunk -> {
                List<Double> chunkEmbedding = convertStringToEmbedding(chunk.getEmbedding());
                double similarity = embeddingService.calculateCosineSimilarity(queryEmbedding, chunkEmbedding);
                return Map.entry(chunk, similarity);
            })
            .sorted((a, b) -> Double.compare(b.getValue(), a.getValue()))
            .limit(maxRetrievalResults)
            .collect(Collectors.toList());
        
        logger.info("Found {} relevant chunks with similarities ranging from {:.3f} to {:.3f}", 
                   chunkSimilarities.size(),
                   chunkSimilarities.isEmpty() ? 0.0 : chunkSimilarities.get(chunkSimilarities.size() - 1).getValue(),
                   chunkSimilarities.isEmpty() ? 0.0 : chunkSimilarities.get(0).getValue());
        
        return chunkSimilarities.stream()
            .map(Map.Entry::getKey)
            .collect(Collectors.toList());
    }
    
    private String generateRagResponse(QueryRequest request, List<String> relevantChunks) {
        try {
            String context = String.join("\n\n", relevantChunks);
            
            // Create a textbook-faithful prompt that prioritizes the book's teaching style
            String prompt = String.format(
                "You are an expert tutor for Applied Linear Algebra, and your role is to teach EXACTLY as this specific textbook teaches. " +
                "CRITICAL: Base your explanations SOLELY on the textbook content provided. Do NOT use external knowledge, different teaching methods, " +
                "or alternative explanations that aren't in this textbook.\n\n" +
                "TEXTBOOK CONTENT:\n%s\n\n" +
                "STUDENT QUESTION: %s\n\n" +
                "STRICT INSTRUCTIONS:\n" +
                "1. Use ONLY the textbook content above to answer - no external knowledge\n" +
                "2. Follow the textbook's exact teaching style, terminology, and approach\n" +
                "3. Use the same examples, definitions, and explanations as the textbook\n" +
                "4. Maintain the textbook's level of detail and mathematical rigor\n" +
                "5. If the textbook uses specific notation, formulas, or methods, use those exactly\n" +
                "6. Provide a %s response at %s level\n" +
                "7. If the textbook doesn't cover something, say 'This topic is not covered in the textbook' rather than using external knowledge\n" +
                "8. Stay true to the textbook's pedagogical approach and mathematical conventions\n\n" +
                "TEXTBOOK-BASED ANSWER:",
                context,
                request.getQuery(),
                request.getResponseType(),
                request.getLearningLevel()
            );
            
            logger.debug("Generated textbook-faithful prompt for query: {}", request.getQuery());
            return ollamaService.generateResponse(prompt);
            
        } catch (Exception e) {
            logger.error("Error generating RAG response: {}", e.getMessage(), e);
            return "Sorry, I encountered an error while processing your request.";
        }
    }
    
    private String buildPromptTemplate(String learningLevel, String responseType) {
        return String.format(
            "You are a helpful math tutor assistant. " +
            "You are teaching at a %s level. " +
            "Provide a %s response. " +
            "Use the following context from a math textbook to answer the question:\n\n" +
            "CONTEXT:\n%%s\n\n" +
            "QUESTION: %%s\n\n" +
            "ANSWER:",
            learningLevel, responseType
        );
    }
    
    private String convertEmbeddingToString(List<Double> embedding) {
        try {
            return objectMapper.writeValueAsString(embedding);
        } catch (JsonProcessingException e) {
            logger.error("Error converting embedding to string: {}", e.getMessage());
            return "[]";
        }
    }
    
    private List<Double> convertStringToEmbedding(String embeddingString) {
        try {
            return objectMapper.readValue(embeddingString, 
                objectMapper.getTypeFactory().constructCollectionType(List.class, Double.class));
        } catch (JsonProcessingException e) {
            logger.error("Error converting string to embedding: {}", e.getMessage());
            return List.of();
        }
    }
}
