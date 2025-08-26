package com.textbookassistant.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;
import com.zaxxer.hikari.HikariDataSource;

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
        
        HikariDataSource dataSource = new HikariDataSource();
        
        // Convert Railway's PostgreSQL URL to JDBC format
        String jdbcUrl = convertToJdbcUrl(databaseUrl);
        logger.info("Using JDBC URL: {}", jdbcUrl.replaceAll(":[^:@]*@", ":***@"));
        
        dataSource.setJdbcUrl(jdbcUrl);
        dataSource.setDriverClassName("org.postgresql.Driver");
        
        // Connection pool settings
        dataSource.setMaximumPoolSize(10);
        dataSource.setMinimumIdle(5);
        dataSource.setConnectionTimeout(30000);
        dataSource.setIdleTimeout(600000);
        dataSource.setMaxLifetime(1800000);
        
        logger.info("Database configuration complete");
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
}
