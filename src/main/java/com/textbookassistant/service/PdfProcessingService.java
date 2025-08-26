package com.textbookassistant.service;

import com.textbookassistant.model.Document;
import com.textbookassistant.model.Document.ProcessingStatus;
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
import java.util.UUID;

@Service
public class PdfProcessingService {
    
    private static final Logger logger = LoggerFactory.getLogger(PdfProcessingService.class);
    
    private final DocumentRepository documentRepository;
    private final RagService ragService;
    
    @Value("${app.upload.dir}")
    private String uploadDir;
    
    @Value("${app.chunk.size}")
    private int chunkSize;
    
    @Value("${app.chunk.overlap}")
    private int chunkOverlap;
    
    public PdfProcessingService(DocumentRepository documentRepository, RagService ragService) {
        this.documentRepository = documentRepository;
        this.ragService = ragService;
    }
    
    public Document processPdfUpload(MultipartFile file) throws IOException {
        // Validate file
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }
        
        String contentType = file.getContentType();
        if (contentType == null || (!contentType.equals("application/pdf") && !contentType.startsWith("text/"))) {
            throw new IllegalArgumentException("File must be a PDF or text file");
        }
        
        // Create upload directory if it doesn't exist
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String uniqueFilename = UUID.randomUUID().toString() + fileExtension;
        Path filePath = uploadPath.resolve(uniqueFilename);
        
        // Save file
        Files.copy(file.getInputStream(), filePath);
        
        // Create document record
        Document document = new Document(
            uniqueFilename,
            originalFilename,
            filePath.toString(),
            file.getSize(),
            file.getContentType()
        );
        
        document = documentRepository.save(document);
        
        // Process PDF asynchronously
        processPdfAsync(document);
        
        return document;
    }
    
    private void processPdfAsync(Document document) {
        // In a real application, you would use @Async or a message queue
        // For simplicity, we'll process synchronously here
        try {
            processPdfContent(document);
        } catch (Exception e) {
            logger.error("Error processing PDF: {}", e.getMessage(), e);
            document.setStatus(ProcessingStatus.FAILED);
            document.setErrorMessage(e.getMessage());
            documentRepository.save(document);
        }
    }
    
    private void processPdfContent(Document document) throws IOException {
        logger.info("Processing file: {}", document.getOriginalFilename());
        
        document.setStatus(ProcessingStatus.PROCESSING);
        documentRepository.save(document);
        
        // Check if it's a text file or PDF
        String contentType = document.getContentType();
        if (contentType != null && contentType.startsWith("text/")) {
            // Handle text files
            processTextFile(document);
        } else {
            // Handle PDF files
            processPdfPageByPage(document);
        }
        
        document.setStatus(ProcessingStatus.COMPLETED);
        document.setProcessedAt(LocalDateTime.now());
        documentRepository.save(document);
        
        logger.info("File processing completed");
    }
    
    private void processTextFile(Document document) throws IOException {
        logger.info("Processing text file: {}", document.getOriginalFilename());
        
        // Read the text file directly
        String content = new String(java.nio.file.Files.readAllBytes(java.nio.file.Path.of(document.getFilePath())));
        
        // Store the extracted text
        document.setExtractedText(content);
        documentRepository.save(document);
        
        // Process for RAG with error handling
        try {
            logger.info("Starting RAG processing for text file: {}", document.getOriginalFilename());
            ragService.processTextChunks(document.getId(), content);
            logger.info("Text file RAG processing completed successfully");
        } catch (Exception e) {
            logger.error("RAG processing failed for text file: {}", e.getMessage(), e);
            // Don't fail the entire process, just log the error and continue
        }
        
        logger.info("Text file processing completed");
    }
    
    private void processPdfPageByPage(Document document) throws IOException {
        try (PDDocument pdfDocument = PDDocument.load(new File(document.getFilePath()))) {
            PDFTextStripper stripper = new PDFTextStripper();
            stripper.setSortByPosition(true);
            
            int totalPages = pdfDocument.getNumberOfPages();
            StringBuilder fullText = new StringBuilder();
            
            // Process pages in batches to manage memory
            int batchSize = 10; // Process 10 pages at a time
            for (int startPage = 1; startPage <= totalPages; startPage += batchSize) {
                int endPage = Math.min(startPage + batchSize - 1, totalPages);
                
                stripper.setStartPage(startPage);
                stripper.setEndPage(endPage);
                String pageText = stripper.getText(pdfDocument);
                
                fullText.append(pageText).append("\n\n");
                
                            // Skip RAG processing for now to test basic functionality
            // if (fullText.length() > 50000) { // Process when we have ~50KB of text
            //     ragService.processTextChunks(document.getId(), fullText.toString());
            //     fullText.setLength(0); // Clear the buffer
            //     System.gc(); // Force garbage collection
            // }
                
                logger.info("Processed pages {}-{} of {}", startPage, endPage, totalPages);
            }
            
            // Store the extracted text
            document.setExtractedText(fullText.toString());
            documentRepository.save(document);
            
            // Skip RAG processing for now - focus on testing queries
            // try {
            //     if (fullText.length() > 0) {
            //         logger.info("Starting RAG processing for PDF: {}", document.getOriginalFilename());
            //         ragService.processTextChunks(document.getId(), fullText.toString());
            //         logger.info("PDF RAG processing completed successfully");
            //     }
            // } catch (Exception e) {
            //     logger.error("RAG processing failed for PDF: {}", e.getMessage(), e);
            //     // Don't fail the entire process, just log the error and continue
            // }
        }
    }
    
    private String extractTextFromPdf(String filePath) throws IOException {
        try (PDDocument document = PDDocument.load(new File(filePath))) {
            PDFTextStripper stripper = new PDFTextStripper();
            stripper.setSortByPosition(true);
            return stripper.getText(document);
        }
    }
    
    public Document getDocumentById(Long id) {
        return documentRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Document not found with id: " + id));
    }
    
    public Document getDocumentByFilename(String filename) {
        return documentRepository.findByFilename(filename)
            .orElseThrow(() -> new IllegalArgumentException("Document not found with filename: " + filename));
    }
    
    public List<Document> getAllDocuments() {
        return documentRepository.findAllByOrderByUploadedAtDesc();
    }
    
    public void deleteDocument(Long id) {
        Document document = getDocumentById(id);
        
        // Delete file from filesystem
        try {
            Path filePath = Paths.get(document.getFilePath());
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            logger.warn("Could not delete file: {}", document.getFilePath(), e);
        }
        
        // Delete from database
        documentRepository.delete(document);
    }
}
