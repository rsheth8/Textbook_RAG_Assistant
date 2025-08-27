package com.textbookassistant.service;

import com.textbookassistant.model.Document;
import com.textbookassistant.repository.DocumentRepository;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class PdfProcessingService {
    
    private static final Logger logger = LoggerFactory.getLogger(PdfProcessingService.class);
    
    private final DocumentRepository documentRepository;
    
    @Value("${app.upload-dir:data/uploads}")
    private String uploadDir;
    
    @Value("${app.processed-dir:data/processed}")
    private String processedDir;
    
    public PdfProcessingService(DocumentRepository documentRepository) {
        this.documentRepository = documentRepository;
    }
    
    public Document processPdfUpload(MultipartFile file) throws IOException {
        logger.info("Processing PDF upload: {}", file.getOriginalFilename());
        
        // Validate file
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }
        
        if (!file.getContentType().equals("application/pdf")) {
            throw new IllegalArgumentException("File must be a PDF");
        }
        
        // Create directories if they don't exist
        createDirectoriesIfNotExist();
        
        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String uniqueFilename = generateUniqueFilename(originalFilename);
        String filePath = Paths.get(uploadDir, uniqueFilename).toString();
        
        // Save file to disk
        File savedFile = new File(filePath);
        file.transferTo(savedFile);
        
        // Create document record
        Document document = new Document();
        document.setFilename(uniqueFilename);
        document.setOriginalFilename(originalFilename);
        document.setFilePath(filePath);
        document.setFileSize(file.getSize());
        document.setContentType(file.getContentType());
        document.setStatus(Document.ProcessingStatus.UPLOADED);
        document.setUploadedAt(LocalDateTime.now());
        
        document = documentRepository.save(document);
        
        try {
            // Extract text from PDF
            String extractedText = extractTextFromPdf(savedFile);
            
            // Update document with extracted text
            document.setExtractedText(extractedText);
            document.setStatus(Document.ProcessingStatus.COMPLETED);
            document.setProcessedAt(LocalDateTime.now());
            
            document = documentRepository.save(document);
            
            logger.info("Successfully processed PDF: {} ({} characters extracted)", 
                       originalFilename, extractedText.length());
            
            return document;
            
        } catch (Exception e) {
            logger.error("Error processing PDF: {}", e.getMessage(), e);
            
            // Update document with error status
            document.setStatus(Document.ProcessingStatus.FAILED);
            document.setErrorMessage(e.getMessage());
            documentRepository.save(document);
            
            throw new RuntimeException("Failed to process PDF", e);
        }
    }
    
    private void createDirectoriesIfNotExist() throws IOException {
        Files.createDirectories(Paths.get(uploadDir));
        Files.createDirectories(Paths.get(processedDir));
    }
    
    private String generateUniqueFilename(String originalFilename) {
        String timestamp = String.valueOf(System.currentTimeMillis());
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        return timestamp + extension;
    }
    
    private String extractTextFromPdf(File pdfFile) throws IOException {
        try (PDDocument document = PDDocument.load(pdfFile)) {
            PDFTextStripper stripper = new PDFTextStripper();
            stripper.setSortByPosition(true);
            return stripper.getText(document);
        }
    }
    
    public List<Document> getAllDocuments() {
        return documentRepository.findAll();
    }
    
    public Document getDocumentById(Long id) {
        return documentRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Document not found with id: " + id));
    }
    
    public void deleteDocument(Long id) {
        Document document = getDocumentById(id);
        
        // Delete file from disk
        try {
            Path filePath = Paths.get(document.getFilePath());
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            logger.warn("Could not delete file: {}", document.getFilePath(), e);
        }
        
        // Delete from database
        documentRepository.deleteById(id);
    }
}
