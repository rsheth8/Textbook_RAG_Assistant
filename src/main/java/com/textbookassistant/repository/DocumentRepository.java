package com.textbookassistant.repository;

import com.textbookassistant.model.Document;
import com.textbookassistant.model.Document.ProcessingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Long> {
    
    List<Document> findByStatus(ProcessingStatus status);
    
    List<Document> findByOriginalFilenameContainingIgnoreCase(String filename);
    
    @Query("SELECT d FROM Document d WHERE d.uploadedAt >= :since")
    List<Document> findDocumentsUploadedSince(@Param("since") java.time.LocalDateTime since);
    
    Optional<Document> findByFilename(String filename);
    
    @Query("SELECT COUNT(d) FROM Document d WHERE d.status = :status")
    long countByStatus(@Param("status") ProcessingStatus status);
    
    List<Document> findAllByOrderByUploadedAtDesc();
}
