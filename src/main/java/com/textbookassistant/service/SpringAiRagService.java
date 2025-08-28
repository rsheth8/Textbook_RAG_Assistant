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
import jakarta.annotation.PostConstruct;

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
    
               @Value("${RAILWAY_SERVICE_OPEN_WEBUI_URL:}")
           private String openWebUiUrl;

           @Value("${OPEN_WEBUI_API_KEY:}")
           private String openWebUiApiKey;

           @Value("${spring.ai.ollama.chat.options.model:qwen2.5:0.5b}")
           private String ollamaModel;
    
    @PostConstruct
    public void logConfiguration() {
        logger.info("Ollama configuration - Base URL: {}, Model: {}", ollamaBaseUrl, ollamaModel);
    }
    
    public SpringAiRagService(DocumentRepository documentRepository, 
                             DocumentChunkRepository documentChunkRepository) {
        this.documentRepository = documentRepository;
        this.documentChunkRepository = documentChunkRepository;
        this.restTemplate = createRestTemplateWithTimeouts();
    }
    
    private RestTemplate createRestTemplateWithTimeouts() {
        // Use SimpleClientHttpRequestFactory with timeout configuration
        org.springframework.http.client.SimpleClientHttpRequestFactory factory = 
            new org.springframework.http.client.SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(30000); // 30 seconds
        factory.setReadTimeout(60000);    // 60 seconds
        
        return new RestTemplate(factory);
    }
    
    public QueryResponse processQuery(QueryRequest request) {
        try {
            logger.info("Processing query: {}", request.getQuery());
            
            // Handle global search (documentId = 0) by finding the first available document
            Document document;
            if (request.getDocumentId() == null || request.getDocumentId() == 0) {
                logger.info("Global search requested - finding first available document");
                List<Document> documents = documentRepository.findAll();
                if (documents.isEmpty()) {
                    return new QueryResponse(
                        "No documents are available for searching.",
                        List.of(),
                        request.getLearningLevel(),
                        request.getResponseType(),
                        request.getQuery(),
                        null
                    );
                }
                document = documents.get(0);
                logger.info("Using document: {} (ID: {})", document.getFilename(), document.getId());
            } else {
                // Get the specific document
                document = documentRepository.findById(request.getDocumentId())
                    .orElseThrow(() -> new IllegalArgumentException("Document not found"));
            }
            
            if (document.getExtractedText() == null || document.getExtractedText().trim().isEmpty()) {
                return new QueryResponse(
                    "The textbook content is not available for searching.",
                    List.of(),
                    request.getLearningLevel(),
                    request.getResponseType(),
                    request.getQuery(),
                    document.getId()
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
                    document.getId()
                );
            }
            
                               // Generate AI response based on the relevant content
                   logger.info("About to generate AI response for query: {}", request.getQuery());
                   String response = generateResponse(request, relevantContent);
                   logger.info("Successfully generated AI response");
            
            return new QueryResponse(
                response,
                List.of(relevantContent),
                request.getLearningLevel(),
                request.getResponseType(),
                request.getQuery(),
                document.getId()
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
     * Generate an AI response based on the relevant content using Ollama API directly
     */
               private String generateResponse(QueryRequest request, String relevantContent) {
               try {
                   logger.info("Generating AI response for query: {}", request.getQuery());
                   logger.info("Relevant content length: {}", relevantContent.length());
            
            // Extract only the most relevant snippet (first 200 characters max)
            // This prevents sending large chunks of textbook text to the AI
            String focusedContent = relevantContent;
            if (relevantContent.length() > 200) {
                // Find a good breaking point (end of sentence or paragraph)
                int breakPoint = 200;
                for (int i = 200; i > 150; i--) {
                    if (relevantContent.charAt(i) == '.' || relevantContent.charAt(i) == '\n') {
                        breakPoint = i + 1;
                        break;
                    }
                }
                focusedContent = relevantContent.substring(0, breakPoint);
                logger.info("Content focused from {} to {} characters", relevantContent.length(), focusedContent.length());
            }
            
            // Create a focused prompt for textbook-faithful responses
            String prompt = String.format(
                "Based on this brief excerpt from a linear algebra textbook, answer the question. " +
                "If the excerpt doesn't contain enough information, say so clearly.\n\n" +
                "Excerpt: %s\n\n" +
                "Question: %s\n\n" +
                "Answer:",
                focusedContent,
                request.getQuery()
            );
            
                                                                                 // Create the request payload for Open WebUI API
                   Map<String, Object> requestPayload = Map.of(
                       "model", ollamaModel,
                       "messages", List.of(Map.of(
                           "role", "user",
                           "content", prompt
                       )),
                       "stream", false
                   );

                   // Use Open WebUI if available, otherwise fall back to direct Ollama
                   String apiUrl;
                   if (openWebUiUrl != null && !openWebUiUrl.trim().isEmpty()) {
                       apiUrl = "https://" + openWebUiUrl + "/api/v1/chat/completions";
                       logger.info("Using Open WebUI at: {}", apiUrl);
                   } else {
                       apiUrl = ollamaBaseUrl + "/api/generate";
                       logger.info("Falling back to direct Ollama at: {}", apiUrl);
                   }
            
            logger.info("Request payload: {}", requestPayload);
            logger.info("Model being used: '{}'", ollamaModel);
            logger.info("Prompt length: {}", prompt.length());
            
            // Log the exact JSON that would be sent
            try {
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                String jsonPayload = mapper.writeValueAsString(requestPayload);
                logger.info("JSON payload being sent: {}", jsonPayload);
            } catch (Exception e) {
                logger.error("Error serializing payload to JSON: {}", e.getMessage());
            }
            
                               org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
                   headers.setContentType(org.springframework.http.MediaType.APPLICATION_JSON);
                   
                   // Add API key if available for Open WebUI
                   if (openWebUiUrl != null && !openWebUiUrl.trim().isEmpty() && 
                       openWebUiApiKey != null && !openWebUiApiKey.trim().isEmpty()) {
                       headers.set("Authorization", "Bearer " + openWebUiApiKey);
                       logger.info("Added API key to request headers");
                   }
            
            org.springframework.http.HttpEntity<Map<String, Object>> entity = 
                new org.springframework.http.HttpEntity<>(requestPayload, headers);
            
            logger.info("HTTP Headers: {}", headers);
            logger.info("Full URL: {}", apiUrl);
            
            logger.info("About to make HTTP request...");
            org.springframework.http.ResponseEntity<Map> response = 
                restTemplate.postForEntity(apiUrl, entity, Map.class);
            
            logger.info("Received response from Ollama - Status: {}, Headers: {}", 
                response.getStatusCode(), response.getHeaders());
            logger.info("Response body: {}", response.getBody());
            
                               if (response.getBody() != null) {
                       String aiResponse;
                       // Handle Open WebUI response format
                       if (response.getBody().containsKey("choices")) {
                           List<Map<String, Object>> choices = (List<Map<String, Object>>) response.getBody().get("choices");
                           if (!choices.isEmpty()) {
                               Map<String, Object> choice = choices.get(0);
                               Map<String, Object> message = (Map<String, Object>) choice.get("message");
                               aiResponse = (String) message.get("content");
                           } else {
                               throw new RuntimeException("No choices in Open WebUI response");
                           }
                       }
                       // Handle direct Ollama response format
                       else if (response.getBody().containsKey("response")) {
                           aiResponse = (String) response.getBody().get("response");
                       } else {
                           throw new RuntimeException("Unexpected response format");
                       }
                
                logger.info("Successfully generated AI response");
                return aiResponse;
            }
            
            logger.error("Unexpected response format from Ollama: {}", response.getBody());
            throw new RuntimeException("Invalid response from Ollama");
            
        } catch (Exception e) {
            logger.error("Error generating AI response: {}", e.getMessage(), e);
            return String.format(
                "I found relevant information in the textbook, but encountered an error while generating an AI response. " +
                "Here's a brief excerpt:\n\n%s",
                relevantContent.substring(0, Math.min(relevantContent.length(), 150)) + 
                (relevantContent.length() > 150 ? "..." : "")
            );
        }
    }
}
