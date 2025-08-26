package com.textbookassistant.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.concurrent.CompletableFuture;

@Service
public class CloudOllamaService {
    
    private static final Logger logger = LoggerFactory.getLogger(CloudOllamaService.class);
    
    private final WebClient webClient;
    private final ObjectMapper objectMapper;
    
    @Value("${ollama.base-url:https://api.ollama.ai}")
    private String ollamaBaseUrl;
    
    @Value("${ollama.model:llama2}")
    private String model;
    
    @Value("${ollama.temperature:0.7}")
    private Double temperature;
    
    @Value("${ollama.max-tokens:2048}")
    private Integer maxTokens;
    
    @Value("${ollama.api-key:}")
    private String apiKey;
    
    public CloudOllamaService() {
        this.webClient = WebClient.builder().build();
        this.objectMapper = new ObjectMapper();
    }
    
    public String generateResponse(String prompt) {
        try {
            // Clean and truncate prompt to prevent issues
            if (prompt == null || prompt.trim().isEmpty()) {
                logger.warn("Empty prompt provided");
                return "Sorry, I couldn't generate a response at this time.";
            }
            
            // Truncate prompt if too long (API limits)
            if (prompt.length() > 4000) {
                logger.warn("Prompt too long ({} chars), truncating to 4000 chars", prompt.length());
                prompt = prompt.substring(0, 4000);
            }
            
            // Clean up the prompt
            prompt = prompt.replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
            
            logger.debug("Generating response for prompt ({} chars): {}", prompt.length(), prompt.substring(0, Math.min(200, prompt.length())));
            
            // Build request with API key if available
            String requestBody = String.format("""
                {
                    "model": "%s",
                    "prompt": "%s",
                    "stream": false,
                    "options": {
                        "temperature": %f,
                        "num_predict": %d
                    }
                }
                """, model, prompt, temperature, maxTokens);
            
            WebClient.RequestHeadersSpec<?> request = webClient.post()
                .uri(ollamaBaseUrl + "/api/generate")
                .header("Content-Type", "application/json");
            
            // Add API key if provided
            if (apiKey != null && !apiKey.trim().isEmpty()) {
                request = request.header("Authorization", "Bearer " + apiKey);
            }
            
            String response = ((WebClient.RequestBodySpec) request)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class)
                .timeout(java.time.Duration.ofSeconds(30))
                .block();
            
            if (response != null) {
                JsonNode jsonNode = objectMapper.readTree(response);
                return jsonNode.get("response").asText();
            }
            
            return "Sorry, I couldn't generate a response at this time.";
            
        } catch (Exception e) {
            logger.error("Error generating response: {}", e.getMessage(), e);
            return "Sorry, I encountered an error while processing your request.";
        }
    }
    
    public CompletableFuture<String> generateResponseAsync(String prompt) {
        return CompletableFuture.supplyAsync(() -> generateResponse(prompt));
    }
    
    public boolean isAvailable() {
        try {
            String testResponse = generateResponse("Hello");
            return testResponse != null && !testResponse.contains("error");
        } catch (Exception e) {
            logger.warn("Ollama service not available: {}", e.getMessage());
            return false;
        }
    }
}
