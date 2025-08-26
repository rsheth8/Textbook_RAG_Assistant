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
    
    @GetMapping("/health")
    public ResponseEntity<String> basicHealthCheck() {
        logger.info("Basic health check requested");
        return ResponseEntity.ok("RAG Assistant is running!");
    }
    
    @GetMapping("/api/v1/health")
    public ResponseEntity<String> apiHealthCheck() {
        logger.info("API health check requested");
        return ResponseEntity.ok("RAG Assistant is running!");
    }
    
    @GetMapping("/api/health")
    public ResponseEntity<String> apiHealthCheckAlt() {
        logger.info("API health check (alt) requested");
        return ResponseEntity.ok("RAG Assistant is running!");
    }
    
    @GetMapping("/ping")
    public ResponseEntity<String> pingHealthCheck() {
        logger.info("Ping health check requested");
        return ResponseEntity.ok("RAG Assistant is running!");
    }
    
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> detailedStatus() {
        logger.info("Detailed status check requested");
        
        Map<String, Object> status = new HashMap<>();
        status.put("status", "running");
        status.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        status.put("service", "Textbook RAG Assistant");
        status.put("version", "1.0.0");
        
        return ResponseEntity.ok(status);
    }
}
