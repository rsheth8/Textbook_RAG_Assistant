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
    
    @Value("${PGUSER:}")
    private String pgUser;
    
    @Value("${PGPASSWORD:}")
    private String pgPassword;
    
    @Value("${PGHOST:}")
    private String pgHost;
    
    @Value("${PGPORT:5432}")
    private String pgPort;
    
    @Value("${PGDATABASE:}")
    private String pgDatabase;
    
    @Bean
    @Primary
    public DataSource dataSource() {
        logger.info("Configuring Railway database connection...");
        
        HikariDataSource dataSource = new HikariDataSource();
        
        try {
            String jdbcUrl;
            String username;
            String password;
            
            // Try to parse DATABASE_URL first
            if (databaseUrl != null && !databaseUrl.isEmpty() && !databaseUrl.contains("${{")) {
                // DATABASE_URL is properly resolved
                URI dbUri = new URI(databaseUrl);
                username = dbUri.getUserInfo().split(":")[0];
                password = dbUri.getUserInfo().split(":")[1];
                jdbcUrl = "jdbc:postgresql://" + dbUri.getHost() + ':' + dbUri.getPort() + dbUri.getPath();
                
                logger.info("Using DATABASE_URL configuration - Host: {}, Database: {}", 
                    dbUri.getHost(), dbUri.getPath());
                
            } else {
                // DATABASE_URL is not resolved, use individual variables
                logger.info("DATABASE_URL not resolved, using individual PostgreSQL variables");
                
                if (pgHost == null || pgHost.isEmpty()) {
                    throw new RuntimeException("PGHOST is not set");
                }
                if (pgUser == null || pgUser.isEmpty()) {
                    throw new RuntimeException("PGUSER is not set");
                }
                if (pgPassword == null || pgPassword.isEmpty()) {
                    throw new RuntimeException("PGPASSWORD is not set");
                }
                if (pgDatabase == null || pgDatabase.isEmpty()) {
                    pgDatabase = "railway"; // Default Railway database name
                }
                
                jdbcUrl = "jdbc:postgresql://" + pgHost + ":" + pgPort + "/" + pgDatabase;
                username = pgUser;
                password = pgPassword;
                
                logger.info("Using individual PostgreSQL variables - Host: {}, Database: {}", 
                    pgHost, pgDatabase);
            }
            
            dataSource.setJdbcUrl(jdbcUrl);
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
            throw new RuntimeException("Invalid DATABASE_URL format: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Failed to configure Railway database: {}", e.getMessage());
            throw new RuntimeException("Database configuration failed: " + e.getMessage());
        }
        
        return dataSource;
    }
}
