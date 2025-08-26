package com.textbookassistant.controller;

import com.textbookassistant.dto.QueryRequest;
import com.textbookassistant.dto.QueryResponse;
import com.textbookassistant.dto.UploadResponse;
import com.textbookassistant.model.Document;
import com.textbookassistant.service.PdfProcessingService;
import com.textbookassistant.service.RagService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import jakarta.validation.Valid;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/v1")
@CrossOrigin(origins = "*")
public class RagController {
    
    private static final Logger logger = LoggerFactory.getLogger(RagController.class);
    
    private final PdfProcessingService pdfProcessingService;
    private final RagService ragService;
    
    public RagController(PdfProcessingService pdfProcessingService, RagService ragService) {
        this.pdfProcessingService = pdfProcessingService;
        this.ragService = ragService;
    }
    
    @PostMapping("/upload")
    public ResponseEntity<UploadResponse> uploadPdf(@RequestParam("file") MultipartFile file) {
        try {
            logger.info("Received PDF upload request: {}", file.getOriginalFilename());
            
            Document document = pdfProcessingService.processPdfUpload(file);
            
            UploadResponse response = new UploadResponse(
                document.getId(),
                document.getFilename(),
                document.getOriginalFilename(),
                document.getFileSize(),
                document.getStatus(),
                document.getUploadedAt(),
                "PDF uploaded successfully and processing started"
            );
            
            return ResponseEntity.ok(response);
            
        } catch (IllegalArgumentException e) {
            logger.error("Invalid file upload: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (IOException e) {
            logger.error("Error processing PDF upload: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @PostMapping("/query")
    public ResponseEntity<QueryResponse> processQuery(@Valid @RequestBody QueryRequest request) {
        try {
            logger.info("Processing query: {}", request.getQuery());
            
            // If documentId is 0, search across entire textbook
            if (request.getDocumentId() != null && request.getDocumentId() == 0) {
                logger.info("Global textbook search requested - searching across all chunks");
                request.setDocumentId(0L); // Ensure it's set to 0 for global search
            }
            
            QueryResponse response = ragService.processQuery(request);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error processing query: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/documents")
    public ResponseEntity<List<Document>> getAllDocuments() {
        try {
            List<Document> documents = pdfProcessingService.getAllDocuments();
            return ResponseEntity.ok(documents);
        } catch (Exception e) {
            logger.error("Error retrieving documents: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/documents/{id}")
    public ResponseEntity<Document> getDocument(@PathVariable Long id) {
        try {
            Document document = pdfProcessingService.getDocumentById(id);
            return ResponseEntity.ok(document);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            logger.error("Error retrieving document: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @DeleteMapping("/documents/{id}")
    public ResponseEntity<Void> deleteDocument(@PathVariable Long id) {
        try {
            pdfProcessingService.deleteDocument(id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            logger.error("Error deleting document: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    

}
