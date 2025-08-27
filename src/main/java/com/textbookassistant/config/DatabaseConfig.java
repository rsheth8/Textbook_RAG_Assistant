package com.textbookassistant.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import jakarta.annotation.PostConstruct;

@Configuration
public class DatabaseConfig {
    
    private static final Logger logger = LoggerFactory.getLogger(DatabaseConfig.class);
    
    private final Environment environment;
    
    @Value("${spring.datasource.url:}")
    private String databaseUrl;
    
    @Value("${spring.datasource.username:}")
    private String databaseUsername;
    
    @Value("${spring.datasource.password:}")
    private String databasePassword;
    
    public DatabaseConfig(Environment environment) {
        this.environment = environment;
    }
    
    @PostConstruct
    public void logDatabaseConfiguration() {
        logger.info("=== Database Configuration Debug ===");
        logger.info("Active profiles: {}", String.join(", ", environment.getActiveProfiles()));
        logger.info("DATABASE_URL from env: {}", environment.getProperty("DATABASE_URL"));
        logger.info("POSTGRES_USER from env: {}", environment.getProperty("POSTGRES_USER"));
        logger.info("POSTGRES_PASSWORD from env: {}", environment.getProperty("POSTGRES_PASSWORD"));
        logger.info("POSTGRES_HOST from env: {}", environment.getProperty("POSTGRES_HOST"));
        logger.info("POSTGRES_PORT from env: {}", environment.getProperty("POSTGRES_PORT"));
        logger.info("Spring datasource URL: {}", databaseUrl);
        logger.info("Spring datasource username: {}", databaseUsername);
        logger.info("Spring datasource password: {}", databasePassword != null ? "***" : "null");
        logger.info("=====================================");
        
        // Check if DATABASE_URL is properly set
        String rawDatabaseUrl = environment.getProperty("DATABASE_URL");
        if (rawDatabaseUrl == null || rawDatabaseUrl.isEmpty()) {
            logger.error("DATABASE_URL environment variable is not set!");
        } else if (rawDatabaseUrl.contains("${DATABASE_URL}")) {
            logger.error("DATABASE_URL environment variable is not being resolved properly!");
        } else {
            logger.info("DATABASE_URL appears to be properly configured");
        }
    }
}
