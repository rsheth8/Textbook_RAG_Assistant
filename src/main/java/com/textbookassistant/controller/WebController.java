package com.textbookassistant.controller;

import com.textbookassistant.model.Document;
import com.textbookassistant.service.PdfProcessingService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@Controller
public class WebController {
    
    private final PdfProcessingService pdfProcessingService;
    
    public WebController(PdfProcessingService pdfProcessingService) {
        this.pdfProcessingService = pdfProcessingService;
    }
    
    @GetMapping("/")
    public String index(Model model) {
        try {
            List<Document> documents = pdfProcessingService.getAllDocuments();
            model.addAttribute("documents", documents);
        } catch (Exception e) {
            model.addAttribute("error", "Failed to load documents: " + e.getMessage());
        }
        return "index";
    }
    
    @GetMapping("/document/{id}")
    public String documentDetail(@PathVariable Long id, Model model) {
        try {
            Document document = pdfProcessingService.getDocumentById(id);
            model.addAttribute("document", document);
        } catch (Exception e) {
            model.addAttribute("error", "Document not found: " + e.getMessage());
        }
        return "document";
    }
    
    @GetMapping("/chat/{documentId}")
    public String chat(@PathVariable Long documentId, Model model) {
        try {
            Document document = pdfProcessingService.getDocumentById(documentId);
            model.addAttribute("document", document);
        } catch (Exception e) {
            model.addAttribute("error", "Document not found: " + e.getMessage());
        }
        return "chat";
    }
}
