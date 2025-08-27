package com.textbookassistant.repository;

import com.textbookassistant.model.DocumentChunk;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DocumentChunkRepository extends JpaRepository<DocumentChunk, Long> {
    
    List<DocumentChunk> findByDocumentIdOrderByChunkIndex(Long documentId);
    
    @Query("SELECT dc FROM DocumentChunk dc WHERE dc.documentId = :documentId")
    List<DocumentChunk> findAllByDocumentId(@Param("documentId") Long documentId);
    
    @Query("SELECT COUNT(dc) FROM DocumentChunk dc WHERE dc.documentId = :documentId")
    long countByDocumentId(@Param("documentId") Long documentId);
    
    void deleteByDocumentId(Long documentId);
}
