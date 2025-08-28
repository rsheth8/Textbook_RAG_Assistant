package com.textbookassistant.service;

import com.textbookassistant.dto.QueryRequest;
import com.textbookassistant.dto.QueryResponse;
import com.textbookassistant.model.Document;
import com.textbookassistant.model.DocumentChunk;
import com.textbookassistant.repository.DocumentChunkRepository;
import com.textbookassistant.repository.DocumentRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class SpringAiRagService {
    
    private static final Logger logger = LoggerFactory.getLogger(SpringAiRagService.class);
    
    private final DocumentRepository documentRepository;
    private final DocumentChunkRepository documentChunkRepository;
    private final RestTemplate restTemplate;
    
    @Value("${app.max-retrieval-results:3}")
    private int maxRetrievalResults;
    
    @Value("${spring.ai.ollama.base-url:http://localhost:11434}")
    private String ollamaBaseUrl;
    
    @Value("${spring.ai.ollama.chat.options.model:phi3}")
    private String ollamaModel;
    
    public SpringAiRagService(DocumentRepository documentRepository, 
                            DocumentChunkRepository documentChunkRepository) {
        this.documentRepository = documentRepository;
        this.documentChunkRepository = documentChunkRepository;
        this.restTemplate = new RestTemplate();
    }
    
    public QueryResponse processQuery(QueryRequest request) {
        try {
            logger.info("Processing query: {}", request.getQuery());
            
            // Get the document
            Document document = documentRepository.findById(request.getDocumentId())
                .orElseThrow(() -> new IllegalArgumentException("Document not found"));
            
            if (document.getExtractedText() == null || document.getExtractedText().trim().isEmpty()) {
                return new QueryResponse(
                    "The textbook content is not available for searching.",
                    List.of(),
                    request.getLearningLevel(),
                    request.getResponseType(),
                    request.getQuery(),
                    request.getDocumentId()
                );
            }
            
            // Use full-text search on the entire textbook content
            String relevantContent = findRelevantContent(request.getQuery(), document.getExtractedText());
            
            if (relevantContent == null || relevantContent.trim().isEmpty()) {
                return new QueryResponse(
                    "I couldn't find relevant information in the textbook to answer your question.",
                    List.of(),
                    request.getLearningLevel(),
                    request.getResponseType(),
                    request.getQuery(),
                    request.getDocumentId()
                );
            }
            
            // Generate AI response based on the relevant content
            String response = generateResponse(request, relevantContent);
            
            return new QueryResponse(
                response,
                List.of(relevantContent),
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
    
    /**
     * Find relevant content in the textbook using intelligent text search
     */
    private String findRelevantContent(String query, String textbookContent) {
        if (textbookContent == null || textbookContent.trim().isEmpty()) {
            return null;
        }
        
        String queryLower = query.toLowerCase().trim();
        String contentLower = textbookContent.toLowerCase();
        
        // Split query into meaningful words
        String[] queryWords = queryLower.split("\\s+");
        
        // Find the most relevant section by looking for sections with the most query word matches
        String[] paragraphs = textbookContent.split("\\n\\s*\\n");
        
        int bestScore = 0;
        String bestSection = null;
        
        for (String paragraph : paragraphs) {
            if (paragraph.trim().length() < 50) continue; // Skip very short paragraphs
            
            String paragraphLower = paragraph.toLowerCase();
            int score = 0;
            
            // Score based on word matches
            for (String word : queryWords) {
                if (word.length() > 2 && paragraphLower.contains(word)) {
                    score++;
                }
            }
            
            // Bonus for consecutive word matches (phrases)
            if (queryWords.length > 1) {
                for (int i = 0; i < queryWords.length - 1; i++) {
                    String phrase = queryWords[i] + " " + queryWords[i + 1];
                    if (paragraphLower.contains(phrase)) {
                        score += 2; // Bonus for phrase matches
                    }
                }
            }
            
            // Bonus for exact query match
            if (paragraphLower.contains(queryLower)) {
                score += 5;
            }
            
            if (score > bestScore) {
                bestScore = score;
                bestSection = paragraph;
            }
        }
        
        // If we found a good match, return it with some context
        if (bestScore > 0 && bestSection != null) {
            // Try to include surrounding context for better understanding
            int startIndex = textbookContent.indexOf(bestSection);
            if (startIndex > 0) {
                int contextStart = Math.max(0, startIndex - 200);
                int contextEnd = Math.min(textbookContent.length(), startIndex + bestSection.length() + 200);
                return textbookContent.substring(contextStart, contextEnd);
            }
            return bestSection;
        }
        
        return null;
    }
    
    /**
     * Generate an AI response based on the relevant content using Ollama API
     */
    private String generateResponse(QueryRequest request, String relevantContent) {
        try {
            logger.info("Generating AI response for query: {}", request.getQuery());
            
            // Create the prompt for textbook-faithful responses
            String prompt = String.format(
                "You are a helpful AI assistant that answers questions based on a specific textbook. " +
                "Use ONLY the information provided in the textbook excerpt below to answer the question. " +
                "If the textbook excerpt doesn't contain enough information to answer the question, " +
                "say so clearly. Be accurate and faithful to the textbook content.\n\n" +
                "Textbook Excerpt:\n%s\n\n" +
                "Question: %s\n\n" +
                "Please provide a clear, educational response based on the textbook content:",
                relevantContent,
                request.getQuery()
            );
            
            // Create the request payload for Ollama
            Map<String, Object> requestPayload = Map.of(
                "model", ollamaModel,
                "prompt", prompt,
                "stream", false,
                "options", Map.of(
                    "temperature", 0.7,
                    "num_predict", 2048
                )
            );
            
            // Call Ollama API directly
            String ollamaUrl = ollamaBaseUrl + "/api/generate";
            logger.info("Calling Ollama at: {}", ollamaUrl);
            
            Map<String, Object> response = restTemplate.postForObject(ollamaUrl, requestPayload, Map.class);
            
            if (response != null && response.containsKey("response")) {
                String aiResponse = (String) response.get("response");
                logger.info("Successfully generated AI response");
                return aiResponse;
            } else {
                logger.error("Unexpected response format from Ollama: {}", response);
                throw new RuntimeException("Invalid response from Ollama");
            }
            
        } catch (Exception e) {
            logger.error("Error generating AI response: {}", e.getMessage(), e);
            return String.format(
                "I found relevant information in the textbook, but encountered an error while generating an AI response. " +
                "Here's the relevant content:\n\n%s",
                relevantContent.substring(0, Math.min(relevantContent.length(), 500)) + 
                (relevantContent.length() > 500 ? "..." : "")
            );
        }
    }
}
