package com.textbookassistant.dto;

import java.time.LocalDateTime;
import java.util.List;

public class QueryResponse {
    private String answer;
    private List<String> sources;
    private String learningLevel;
    private String responseType;
    private LocalDateTime timestamp;
    private Double confidence;
    private String query;
    private Long documentId;
    
    public QueryResponse() {}
    
    public QueryResponse(String answer, List<String> sources, String learningLevel, 
                        String responseType, String query, Long documentId) {
        this.answer = answer;
        this.sources = sources;
        this.learningLevel = learningLevel;
        this.responseType = responseType;
        this.query = query;
        this.documentId = documentId;
        this.timestamp = LocalDateTime.now();
    }
    
    // Getters and Setters
    public String getAnswer() {
        return answer;
    }
    
    public void setAnswer(String answer) {
        this.answer = answer;
    }
    
    public List<String> getSources() {
        return sources;
    }
    
    public void setSources(List<String> sources) {
        this.sources = sources;
    }
    
    public String getLearningLevel() {
        return learningLevel;
    }
    
    public void setLearningLevel(String learningLevel) {
        this.learningLevel = learningLevel;
    }
    
    public String getResponseType() {
        return responseType;
    }
    
    public void setResponseType(String responseType) {
        this.responseType = responseType;
    }
    
    public LocalDateTime getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
    
    public Double getConfidence() {
        return confidence;
    }
    
    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }
    
    public String getQuery() {
        return query;
    }
    
    public void setQuery(String query) {
        this.query = query;
    }
    
    public Long getDocumentId() {
        return documentId;
    }
    
    public void setDocumentId(Long documentId) {
        this.documentId = documentId;
    }
}
