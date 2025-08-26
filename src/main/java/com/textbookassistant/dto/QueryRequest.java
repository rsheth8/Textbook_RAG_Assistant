package com.textbookassistant.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class QueryRequest {
    
    @NotBlank(message = "Query cannot be empty")
    private String query;
    
    @NotNull(message = "Document ID is required")
    private Long documentId;
    
    private String learningLevel = "intermediate"; // beginner, intermediate, advanced
    private String responseType = "explanation"; // explanation, summary, step-by-step
    private Integer maxResults = 5;
    
    public QueryRequest() {}
    
    public QueryRequest(String query, Long documentId) {
        this.query = query;
        this.documentId = documentId;
    }
    
    public QueryRequest(String query, Long documentId, String learningLevel, 
                       String responseType, Integer maxResults) {
        this.query = query;
        this.documentId = documentId;
        this.learningLevel = learningLevel;
        this.responseType = responseType;
        this.maxResults = maxResults;
    }
    
    // Getters and Setters
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
    
    public Integer getMaxResults() {
        return maxResults;
    }
    
    public void setMaxResults(Integer maxResults) {
        this.maxResults = maxResults;
    }
}
