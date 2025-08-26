package com.textbookassistant.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
    
    // Super simple health check - just returns OK if the app is running
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> simpleHealthCheck() {
        logger.info("Simple health check requested");
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        response.put("service", "Textbook RAG Assistant");
        
        return ResponseEntity.ok(response);
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
