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
            logger.error("❌ DATABASE_URL is not set! This is required for cloud profile.");
            logger.error("Please ensure the PostgreSQL service is properly connected to your Railway application.");
            throw new RuntimeException("DATABASE_URL environment variable is required for cloud profile");
        }
        
        try {
            // Test the connection first
            String jdbcUrl = convertToJdbcUrl(databaseUrl);
            logger.info("Testing connection with JDBC URL: {}", jdbcUrl.replaceAll(":[^:@]*@", ":***@"));
            
            // Try a simple connection test
            try (Connection testConn = DriverManager.getConnection(jdbcUrl)) {
                logger.info("✅ Database connection test successful!");
                testConn.close();
            } catch (Exception e) {
                logger.error("❌ Database connection test failed: {}", e.getMessage());
                logger.error("This might be due to:");
                logger.error("1. PostgreSQL service not being properly connected");
                logger.error("2. Network connectivity issues");
                logger.error("3. Incorrect database credentials");
                throw e;
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
            logger.error("Failed to configure database connection: {}", e.getMessage(), e);
            throw new RuntimeException("Database configuration failed", e);
        }
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
}
