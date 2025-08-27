package com.textbookassistant.config;

import com.textbookassistant.model.Document;
import com.textbookassistant.repository.DocumentRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.StreamUtils;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

@Configuration
public class DataInitializationConfig {
    
    private static final Logger logger = LoggerFactory.getLogger(DataInitializationConfig.class);
    
    @Autowired
    private DocumentRepository documentRepository;
    
    @Bean
    @Profile("cloud")
    public CommandLineRunner initializeDatabase() {
        return args -> {
            logger.info("Starting database initialization for cloud deployment...");
            
            // Check if we already have the textbook data
            if (documentRepository.count() == 0) {
                logger.info("No documents found. Initializing with Applied Linear Algebra textbook...");
                
                try {
                    // Create the textbook document
                    Document textbook = new Document();
                    textbook.setFilename("applied_linear_algebra_initialized");
                    textbook.setOriginalFilename("Applied Linear Algebra.pdf");
                    textbook.setFilePath("/initialized/textbook");
                    textbook.setFileSize(9182791L); // ~9.2MB
                    textbook.setContentType("application/pdf");
                    textbook.setStatus(Document.ProcessingStatus.COMPLETED);
                    textbook.setUploadedAt(LocalDateTime.now());
                    textbook.setProcessedAt(LocalDateTime.now());
                    
                    // Load the actual textbook content
                    String textbookContent = loadTextbookContent();
                    textbook.setExtractedText(textbookContent);
                    
                    // Save to database
                    Document savedDocument = documentRepository.save(textbook);
                    logger.info("Successfully initialized database with textbook. Document ID: {}", savedDocument.getId());
                    logger.info("Textbook content loaded: {} characters", textbookContent.length());
                    
                } catch (Exception e) {
                    logger.error("Failed to initialize database with textbook content", e);
                    // Fall back to basic initialization
                    initializeBasicContent();
                }
                
            } else {
                logger.info("Database already contains documents. Skipping initialization.");
            }
        };
    }
    
    private String loadTextbookContent() throws IOException {
        try {
            // Try to load from the extracted content file
            ClassPathResource resource = new ClassPathResource("textbook_content.txt");
            String content = StreamUtils.copyToString(resource.getInputStream(), StandardCharsets.UTF_8);
            
            // Extract the content between the triple quotes
            int startIndex = content.indexOf("\"\"\"");
            int endIndex = content.lastIndexOf("\"\"\"");
            
            if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
                return content.substring(startIndex + 3, endIndex).trim();
            } else {
                // If the format is not as expected, return the whole content
                return content;
            }
            
        } catch (IOException e) {
            logger.warn("Could not load textbook content from file, using fallback content", e);
            return getFallbackTextbookContent();
        }
    }
    
    private void initializeBasicContent() {
        try {
            Document textbook = new Document();
            textbook.setFilename("applied_linear_algebra_basic");
            textbook.setOriginalFilename("Applied Linear Algebra.pdf");
            textbook.setFilePath("/initialized/textbook");
            textbook.setFileSize(9182791L);
            textbook.setContentType("application/pdf");
            textbook.setStatus(Document.ProcessingStatus.COMPLETED);
            textbook.setUploadedAt(LocalDateTime.now());
            textbook.setProcessedAt(LocalDateTime.now());
            textbook.setExtractedText(getFallbackTextbookContent());
            
            Document savedDocument = documentRepository.save(textbook);
            logger.info("Initialized with basic content. Document ID: {}", savedDocument.getId());
            
        } catch (Exception e) {
            logger.error("Failed to initialize even basic content", e);
        }
    }
    
    private String getFallbackTextbookContent() {
        return """
        APPLIED LINEAR ALGEBRA
        
        Chapter 1: Introduction to Linear Algebra
        
        Linear algebra is a fundamental branch of mathematics that deals with vector spaces, linear transformations, and systems of linear equations. It provides the mathematical foundation for many areas of science and engineering.
        
        Key concepts in linear algebra include:
        - Vectors and vector spaces
        - Matrices and matrix operations
        - Linear transformations
        - Eigenvalues and eigenvectors
        - Systems of linear equations
        
        Chapter 2: Vector Spaces and Bases
        
        A vector space is a set of objects called vectors, which may be added together and multiplied by numbers, called scalars. Vector spaces are central to linear algebra and have applications throughout mathematics and science.
        
        Definition 2.1. A vector space V over a field F is a set together with two operations:
        1. Vector addition: V × V → V, denoted (u, v) → u + v
        2. Scalar multiplication: F × V → V, denoted (a, v) → av
        
        These operations must satisfy the following axioms:
        - Associativity of addition: (u + v) + w = u + (v + w)
        - Commutativity of addition: u + v = v + u
        - Identity element of addition: There exists an element 0 ∈ V such that v + 0 = v for all v ∈ V
        - Inverse elements of addition: For every v ∈ V, there exists an element -v ∈ V such that v + (-v) = 0
        - Distributivity of scalar multiplication with respect to vector addition: a(u + v) = au + av
        - Distributivity of scalar multiplication with respect to field addition: (a + b)v = av + bv
        - Compatibility of scalar multiplication with field multiplication: a(bv) = (ab)v
        - Identity element of scalar multiplication: 1v = v, where 1 denotes the multiplicative identity in F
        
        Examples of vector spaces include:
        - R^n: The set of all n-tuples of real numbers
        - P(n): The set of all polynomials of degree at most n
        - M(m,n): The set of all m × n matrices
        - C[a,b]: The set of all continuous functions on the interval [a,b]
        
        Chapter 3: Linear Transformations
        
        A linear transformation is a function between vector spaces that preserves the operations of vector addition and scalar multiplication.
        
        Definition 3.1. Let V and W be vector spaces over the same field F. A function T: V → W is called a linear transformation if:
        1. T(u + v) = T(u) + T(v) for all u, v ∈ V
        2. T(av) = aT(v) for all a ∈ F and v ∈ V
        
        Linear transformations have many important properties:
        - They preserve the zero vector: T(0) = 0
        - They preserve linear combinations: T(a₁v₁ + a₂v₂ + ... + aₙvₙ) = a₁T(v₁) + a₂T(v₂) + ... + aₙT(vₙ)
        - The composition of linear transformations is linear
        - The inverse of a linear transformation (if it exists) is linear
        
        Chapter 4: Matrices and Matrix Operations
        
        Matrices are rectangular arrays of numbers that provide a convenient way to represent linear transformations and systems of linear equations.
        
        Definition 4.1. An m × n matrix is a rectangular array of numbers with m rows and n columns.
        
        Basic matrix operations include:
        - Matrix addition: (A + B)ᵢⱼ = Aᵢⱼ + Bᵢⱼ
        - Scalar multiplication: (cA)ᵢⱼ = cAᵢⱼ
        - Matrix multiplication: (AB)ᵢⱼ = Σₖ AᵢₖBₖⱼ
        
        Special types of matrices:
        - Identity matrix: Iᵢⱼ = 1 if i = j, 0 otherwise
        - Zero matrix: All entries are zero
        - Diagonal matrix: Non-zero entries only on the main diagonal
        - Triangular matrix: All entries above or below the main diagonal are zero
        
        Chapter 5: Systems of Linear Equations
        
        A system of linear equations is a collection of equations of the form:
        a₁₁x₁ + a₁₂x₂ + ... + a₁ₙxₙ = b₁
        a₂₁x₁ + a₂₂x₂ + ... + a₂ₙxₙ = b₂
        ...
        aₘ₁x₁ + aₘ₂x₂ + ... + aₘₙxₙ = bₘ
        
        Such systems can be solved using various methods:
        - Gaussian elimination
        - Matrix methods
        - Cramer's rule
        
        The solution set of a system of linear equations can be:
        - Empty (no solution)
        - A single point (unique solution)
        - Infinite (infinitely many solutions)
        
        Chapter 6: Eigenvalues and Eigenvectors
        
        Eigenvalues and eigenvectors are fundamental concepts in linear algebra with applications in many areas of mathematics and science.
        
        Definition 6.1. Let A be an n × n matrix. A scalar λ is called an eigenvalue of A if there exists a non-zero vector v such that Av = λv. The vector v is called an eigenvector corresponding to the eigenvalue λ.
        
        Properties of eigenvalues and eigenvectors:
        - The eigenvalues of A are the roots of the characteristic polynomial det(A - λI) = 0
        - The eigenvectors corresponding to distinct eigenvalues are linearly independent
        - If A is symmetric, its eigenvalues are real and its eigenvectors can be chosen to be orthogonal
        - The trace of A equals the sum of its eigenvalues
        - The determinant of A equals the product of its eigenvalues
        
        Chapter 7: Applications
        
        Linear algebra has numerous applications in:
        - Computer graphics and animation
        - Machine learning and artificial intelligence
        - Signal processing
        - Quantum mechanics
        - Economics and finance
        - Engineering and physics
        
        In computer graphics, matrices are used to represent transformations such as rotation, scaling, and translation. In machine learning, linear algebra is essential for understanding algorithms like principal component analysis, linear regression, and neural networks.
        
        Conclusion
        
        Linear algebra provides powerful tools for understanding and solving problems in mathematics, science, and engineering. The concepts of vector spaces, linear transformations, matrices, and eigenvalues form the foundation for many advanced mathematical topics and practical applications.
        
        The study of linear algebra develops important skills in abstract thinking, problem-solving, and mathematical reasoning that are valuable in many fields beyond mathematics itself.
        """;
    }
}
