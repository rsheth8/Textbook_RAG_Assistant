package com.textbookassistant.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;
import com.zaxxer.hikari.HikariDataSource;
import java.sql.Connection;
import java.sql.DriverManager;
import java.net.URI;

@Configuration
@Profile("cloud")
public class DatabaseConfig {
    
    private static final Logger logger = LoggerFactory.getLogger(DatabaseConfig.class);
    
    @Value("${DATABASE_URL:}")
    private String databaseUrl;
    
    @Value("${POSTGRES_USER:}")
    private String postgresUser;
    
    @Value("${POSTGRES_PASSWORD:}")
    private String postgresPassword;
    
    @Bean
    public DataSource dataSource() {
        logger.info("Configuring database connection for Railway...");
        logger.info("DATABASE_URL: {}", databaseUrl != null ? databaseUrl.replaceAll(":[^:@]*@", ":***@") : "NOT SET");
        logger.info("POSTGRES_USER: {}", postgresUser != null ? postgresUser : "NOT SET");
        logger.info("POSTGRES_PASSWORD: {}", postgresPassword != null ? "***" : "NOT SET");
        
        // Check if we have the required environment variables
        if (databaseUrl == null || databaseUrl.isEmpty()) {
            logger.warn("⚠️ DATABASE_URL is not set, falling back to H2 in-memory database");
            return createH2DataSource();
        }
        
        try {
            // Convert and validate the URL
            String jdbcUrl = convertToJdbcUrl(databaseUrl);
            logger.info("Using JDBC URL: {}", jdbcUrl.replaceAll(":[^:@]*@", ":***@"));
            
            // Validate URL format
            validateJdbcUrl(jdbcUrl);
            
            // Try a simple connection test
            logger.info("Testing database connection...");
            try (Connection testConn = DriverManager.getConnection(jdbcUrl)) {
                logger.info("✅ Database connection test successful!");
                testConn.close();
            } catch (Exception e) {
                logger.error("❌ Database connection test failed: {}", e.getMessage());
                logger.warn("⚠️ Falling back to H2 in-memory database");
                return createH2DataSource();
            }
            
            HikariDataSource dataSource = new HikariDataSource();
            
            dataSource.setJdbcUrl(jdbcUrl);
            dataSource.setDriverClassName("org.postgresql.Driver");
            
            // Connection pool settings optimized for Railway
            dataSource.setMaximumPoolSize(3);
            dataSource.setMinimumIdle(1);
            dataSource.setConnectionTimeout(60000);
            dataSource.setIdleTimeout(300000);
            dataSource.setMaxLifetime(900000);
            dataSource.setLeakDetectionThreshold(60000);
            
            // Connection test settings
            dataSource.setConnectionTestQuery("SELECT 1");
            dataSource.setValidationTimeout(10000);
            
            logger.info("Database configuration complete");
            return dataSource;
            
        } catch (Exception e) {
            logger.error("Failed to configure PostgreSQL connection: {}", e.getMessage());
            logger.warn("⚠️ Falling back to H2 in-memory database");
            return createH2DataSource();
        }
    }
    
    private DataSource createH2DataSource() {
        logger.info("Creating H2 in-memory database as fallback");
        
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setJdbcUrl("jdbc:h2:mem:fallback");
        dataSource.setDriverClassName("org.h2.Driver");
        dataSource.setUsername("sa");
        dataSource.setPassword("");
        
        // Simple settings for H2
        dataSource.setMaximumPoolSize(5);
        dataSource.setMinimumIdle(1);
        dataSource.setConnectionTimeout(30000);
        
        logger.info("H2 fallback database configured");
        return dataSource;
    }
    
    private String convertToJdbcUrl(String url) {
        if (url == null || url.isEmpty()) {
            logger.warn("DATABASE_URL is not set, using default localhost");
            return "jdbc:postgresql://localhost:5432/textbook_assistant";
        }
        
        // If it's already a JDBC URL, return as is
        if (url.startsWith("jdbc:")) {
            return url;
        }
        
        // Convert Railway's postgresql:// format to jdbc:postgresql://
        if (url.startsWith("postgresql://")) {
            return "jdbc:" + url;
        }
        
        // If it's a postgres:// format, convert to jdbc:postgresql://
        if (url.startsWith("postgres://")) {
            return url.replace("postgres://", "jdbc:postgresql://");
        }
        
        logger.warn("Unknown database URL format: {}, using as is", url);
        return url;
    }
    
    private void validateJdbcUrl(String jdbcUrl) {
        try {
            // Remove jdbc: prefix for URI parsing
            String uriString = jdbcUrl.replace("jdbc:", "");
            URI uri = new URI(uriString);
            
            logger.info("URL validation - Host: {}, Port: {}, Path: {}", 
                       uri.getHost(), uri.getPort(), uri.getPath());
            
            if (uri.getHost() == null || uri.getHost().isEmpty()) {
                throw new RuntimeException("Invalid database URL: host is null or empty");
            }
            
        } catch (Exception e) {
            logger.error("Invalid JDBC URL format: {}", jdbcUrl);
            throw new RuntimeException("Invalid database URL format", e);
        }
    }
}
