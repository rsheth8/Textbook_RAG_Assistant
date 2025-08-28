package com.textbookassistant.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;
import com.zaxxer.hikari.HikariDataSource;

import java.net.URI;
import java.net.URISyntaxException;

@Configuration
@ConditionalOnProperty(name = "spring.profiles.active", havingValue = "cloud")
public class RailwayDatabaseConfig {
    
    private static final Logger logger = LoggerFactory.getLogger(RailwayDatabaseConfig.class);
    
    @Autowired
    private Environment environment;
    
    @Bean
    @Primary
    public DataSource dataSource() {
        logger.info("Configuring Railway database connection...");
        
        HikariDataSource dataSource = new HikariDataSource();
        
        try {
            String jdbcUrl;
            String username;
            String password;
            
            // Read environment variables directly
            String databaseUrl = environment.getProperty("DATABASE_URL");
            String pgUser = environment.getProperty("PGUSER");
            String pgPassword = environment.getProperty("PGPASSWORD");
            String pgHost = environment.getProperty("PGHOST");
            String pgPort = environment.getProperty("PGPORT", "5432");
            String pgDatabase = environment.getProperty("PGDATABASE");
            
            logger.info("DATABASE_URL: {}", databaseUrl);
            logger.info("PGHOST: {}", pgHost);
            logger.info("PGUSER: {}", pgUser);
            
            // Check if variables are resolved or still in Railway substitution format
            boolean hasUnresolvedVariables = (databaseUrl != null && databaseUrl.contains("${{")) ||
                                           (pgHost != null && pgHost.contains("${{")) ||
                                           (pgUser != null && pgUser.contains("${{"));
            
            if (hasUnresolvedVariables) {
                logger.error("Railway variable substitution is not working properly.");
                logger.error("DATABASE_URL: {}", databaseUrl);
                logger.error("PGHOST: {}", pgHost);
                logger.error("PGUSER: {}", pgUser);
                throw new RuntimeException("Railway environment variables are not being resolved. Variables still contain ${{}} format. This usually means the PostgreSQL service is not properly connected or Railway's variable substitution is not working.");
            }
            
            // Try to parse DATABASE_URL first (preferred method)
            if (databaseUrl != null && !databaseUrl.isEmpty()) {
                // DATABASE_URL is properly resolved
                URI dbUri = new URI(databaseUrl);
                username = dbUri.getUserInfo().split(":")[0];
                password = dbUri.getUserInfo().split(":")[1];
                jdbcUrl = "jdbc:postgresql://" + dbUri.getHost() + ':' + dbUri.getPort() + dbUri.getPath();
                
                logger.info("Using DATABASE_URL configuration - Host: {}, Database: {}", 
                    dbUri.getHost(), dbUri.getPath());
                
            } else if (pgHost != null && !pgHost.isEmpty() && pgUser != null && !pgUser.isEmpty()) {
                // Individual PostgreSQL variables are available
                logger.info("Using individual PostgreSQL variables");
                
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
                    
            } else {
                // Neither DATABASE_URL nor individual variables are available
                logger.error("DATABASE_URL: {}", databaseUrl);
                logger.error("PGHOST: {}", pgHost);
                logger.error("PGUSER: {}", pgUser);
                throw new RuntimeException("Neither DATABASE_URL nor individual PostgreSQL variables (PGHOST, PGUSER) are properly configured. Please ensure the PostgreSQL service is connected to your main application service.");
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
            logger.error("Failed to parse DATABASE_URL: {}", environment.getProperty("DATABASE_URL"), e);
            throw new RuntimeException("Invalid DATABASE_URL format: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Failed to configure Railway database: {}", e.getMessage());
            throw new RuntimeException("Database configuration failed: " + e.getMessage());
        }
        
        return dataSource;
    }
}
