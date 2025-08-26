package com.textbookassistant.dto;

import com.textbookassistant.model.Document.ProcessingStatus;
import java.time.LocalDateTime;

public class UploadResponse {
    private Long documentId;
    private String filename;
    private String originalFilename;
    private Long fileSize;
    private ProcessingStatus status;
    private LocalDateTime uploadedAt;
    private String message;
    
    public UploadResponse() {}
    
    public UploadResponse(Long documentId, String filename, String originalFilename, 
                         Long fileSize, ProcessingStatus status, LocalDateTime uploadedAt, String message) {
        this.documentId = documentId;
        this.filename = filename;
        this.originalFilename = originalFilename;
        this.fileSize = fileSize;
        this.status = status;
        this.uploadedAt = uploadedAt;
        this.message = message;
    }
    
    // Getters and Setters
    public Long getDocumentId() {
        return documentId;
    }
    
    public void setDocumentId(Long documentId) {
        this.documentId = documentId;
    }
    
    public String getFilename() {
        return filename;
    }
    
    public void setFilename(String filename) {
        this.filename = filename;
    }
    
    public String getOriginalFilename() {
        return originalFilename;
    }
    
    public void setOriginalFilename(String originalFilename) {
        this.originalFilename = originalFilename;
    }
    
    public Long getFileSize() {
        return fileSize;
    }
    
    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }
    
    public ProcessingStatus getStatus() {
        return status;
    }
    
    public void setStatus(ProcessingStatus status) {
        this.status = status;
    }
    
    public LocalDateTime getUploadedAt() {
        return uploadedAt;
    }
    
    public void setUploadedAt(LocalDateTime uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
}
