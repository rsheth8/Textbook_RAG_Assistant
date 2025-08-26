package com.textbookassistant.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.ArrayList;

@Service
public class EmbeddingService {
    
    private static final Logger logger = LoggerFactory.getLogger(EmbeddingService.class);
    
    private final WebClient webClient;
    private final ObjectMapper objectMapper;
    
    @Value("${ollama.base-url:http://localhost:11434}")
    private String ollamaBaseUrl;
    
    @Value("${ollama.embedding-model:nomic-embed-text}")
    private String embeddingModel;
    
    public EmbeddingService() {
        this.webClient = WebClient.builder()
            .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024)) // 10MB
            .build();
        this.objectMapper = new ObjectMapper();
    }
    
    public List<Double> generateEmbedding(String text) {
        try {
            if (text == null || text.trim().isEmpty()) {
                logger.warn("Empty text provided for embedding generation");
                return new ArrayList<>();
            }
            
            // Truncate text if too long to prevent timeout
            if (text.length() > 4000) {
                logger.warn("Text too long ({} chars), truncating to 4000 chars", text.length());
                text = text.substring(0, 4000);
            }
            
            logger.debug("Generating embedding for text of length: {}", text.length());
            
            String requestBody = String.format("""
                {
                    "model": "%s",
                    "prompt": "%s"
                }
                """, embeddingModel, text.replace("\"", "\\\"").replace("\n", " "));
            
            String response = webClient.post()
                .uri(ollamaBaseUrl + "/api/embeddings")
                .header("Content-Type", "application/json")
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class)
                .timeout(java.time.Duration.ofSeconds(15))  // Increased timeout slightly
                .onErrorMap(throwable -> {
                    logger.error("Embedding generation failed: {}", throwable.getMessage());
                    return new RuntimeException("Embedding generation failed: " + throwable.getMessage(), throwable);
                })
                .block();
            
            if (response != null) {
                JsonNode jsonNode = objectMapper.readTree(response);
                JsonNode embeddingNode = jsonNode.get("embedding");
                
                if (embeddingNode != null && embeddingNode.isArray()) {
                    return objectMapper.convertValue(embeddingNode, 
                        objectMapper.getTypeFactory().constructCollectionType(List.class, Double.class));
                }
            }
            
            logger.error("Failed to generate embedding for text: {}", text);
            return List.of();
            
        } catch (Exception e) {
            logger.error("Error generating embedding: {}", e.getMessage(), e);
            return List.of();
        }
    }
    
    public double calculateCosineSimilarity(List<Double> embedding1, List<Double> embedding2) {
        if (embedding1.size() != embedding2.size() || embedding1.isEmpty()) {
            return 0.0;
        }
        
        double dotProduct = 0.0;
        double norm1 = 0.0;
        double norm2 = 0.0;
        
        for (int i = 0; i < embedding1.size(); i++) {
            double val1 = embedding1.get(i);
            double val2 = embedding2.get(i);
            
            dotProduct += val1 * val2;
            norm1 += val1 * val1;
            norm2 += val2 * val2;
        }
        
        if (norm1 == 0.0 || norm2 == 0.0) {
            return 0.0;
        }
        
        return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
    }
}
