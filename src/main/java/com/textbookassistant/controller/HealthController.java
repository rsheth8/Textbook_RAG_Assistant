package com.textbookassistant.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HealthController {
    
    private static final Logger logger = LoggerFactory.getLogger(HealthController.class);
    private boolean applicationReady = false;
    
    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady() {
        logger.info("Application is ready to serve requests");
        applicationReady = true;
    }
    
    // Super simple health check - just returns OK if the app is running
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> simpleHealthCheck() {
        logger.info("Simple health check requested - Application ready: {}", applicationReady);
        
        Map<String, Object> response = new HashMap<>();
        
        if (applicationReady) {
            response.put("status", "UP");
            response.put("ready", true);
        } else {
            response.put("status", "STARTING");
            response.put("ready", false);
        }
        
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        response.put("service", "Textbook RAG Assistant");
        
        return ResponseEntity.ok(response);
    }
    
    // Environment variable debug endpoint
    @GetMapping("/debug/env")
    public ResponseEntity<Map<String, Object>> debugEnvironment() {
        Map<String, Object> envInfo = new HashMap<>();
        
        // Check key environment variables
        envInfo.put("DATABASE_URL_SET", System.getenv("DATABASE_URL") != null);
        envInfo.put("OLLAMA_BASE_URL_SET", System.getenv("OLLAMA_BASE_URL") != null);
        envInfo.put("OLLAMA_MODEL_SET", System.getenv("OLLAMA_MODEL") != null);
        envInfo.put("OLLAMA_EMBEDDING_MODEL_SET", System.getenv("OLLAMA_EMBEDDING_MODEL") != null);
        envInfo.put("POSTGRES_USER_SET", System.getenv("POSTGRES_USER") != null);
        envInfo.put("POSTGRES_PASSWORD_SET", System.getenv("POSTGRES_PASSWORD") != null);
        
        // Show partial values for debugging (without exposing sensitive data)
        String dbUrl = System.getenv("DATABASE_URL");
        if (dbUrl != null) {
            envInfo.put("DATABASE_URL_PARTIAL", dbUrl.replaceAll(":[^:@]*@", ":***@"));
        }
        
        envInfo.put("OLLAMA_BASE_URL", System.getenv("OLLAMA_BASE_URL"));
        envInfo.put("OLLAMA_MODEL", System.getenv("OLLAMA_MODEL"));
        envInfo.put("OLLAMA_EMBEDDING_MODEL", System.getenv("OLLAMA_EMBEDDING_MODEL"));
        
        return ResponseEntity.ok(envInfo);
    }
    
    // Keep other endpoints for compatibility
    @GetMapping("/api/v1/health")
    public ResponseEntity<String> apiHealthCheck() {
        logger.info("API health check requested");
        return ResponseEntity.ok("RAG Assistant is running!");
    }
    
    @GetMapping("/ping")
    public ResponseEntity<String> pingHealthCheck() {
        logger.info("Ping health check requested");
        return ResponseEntity.ok("RAG Assistant is running!");
    }
}
