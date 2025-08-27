package com.textbookassistant.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;
import com.zaxxer.hikari.HikariDataSource;

import java.net.URI;
import java.net.URISyntaxException;

@Configuration
@ConditionalOnProperty(name = "spring.profiles.active", havingValue = "cloud")
public class RailwayDatabaseConfig {
    
    private static final Logger logger = LoggerFactory.getLogger(RailwayDatabaseConfig.class);
    
    @Value("${DATABASE_URL:}")
    private String databaseUrl;
    
    @Bean
    @Primary
    public DataSource dataSource() {
        logger.info("Configuring Railway database connection...");
        
        HikariDataSource dataSource = new HikariDataSource();
        
        try {
            // Parse Railway's DATABASE_URL
            URI dbUri = new URI(databaseUrl);
            
            String username = dbUri.getUserInfo().split(":")[0];
            String password = dbUri.getUserInfo().split(":")[1];
            String dbUrl = "jdbc:postgresql://" + dbUri.getHost() + ':' + dbUri.getPort() + dbUri.getPath();
            
            logger.info("Parsed Railway DATABASE_URL:");
            logger.info("Host: {}", dbUri.getHost());
            logger.info("Port: {}", dbUri.getPort());
            logger.info("Database: {}", dbUri.getPath());
            logger.info("Username: {}", username);
            
            dataSource.setJdbcUrl(dbUrl);
            dataSource.setUsername(username);
            dataSource.setPassword(password);
            dataSource.setDriverClassName("org.postgresql.Driver");
            
            // Connection pool settings
            dataSource.setMaximumPoolSize(10);
            dataSource.setMinimumIdle(2);
            dataSource.setConnectionTimeout(30000);
            dataSource.setIdleTimeout(600000);
            dataSource.setMaxLifetime(1800000);
            dataSource.setConnectionTestQuery("SELECT 1");
            
            logger.info("Railway database configuration completed successfully");
            
        } catch (URISyntaxException e) {
            logger.error("Failed to parse DATABASE_URL: {}", databaseUrl, e);
            throw new RuntimeException("Invalid DATABASE_URL format", e);
        } catch (Exception e) {
            logger.error("Failed to configure Railway database", e);
            throw new RuntimeException("Database configuration failed", e);
        }
        
        return dataSource;
    }
}
