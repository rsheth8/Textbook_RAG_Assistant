package com.textbookassistant.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;

@Configuration
@Profile("cloud")
public class DatabaseConfig {
    
    private static final Logger logger = LoggerFactory.getLogger(DatabaseConfig.class);
    
    @Value("${spring.datasource.url}")
    private String databaseUrl;
    
    @Value("${spring.datasource.username}")
    private String postgresUser;
    
    @Value("${spring.datasource.password}")
    private String postgresPassword;
    
    @Value("${spring.datasource.host}")
    private String postgresHost;
    
    @Value("${spring.datasource.port}")
    private String postgresPort;
    
    @Value("${spring.datasource.database}")
    private String postgresDb;
    
    @Bean
    public DataSource getDataSource() {
        DataSourceBuilder dataSourceBuilder = DataSourceBuilder.create();
        dataSourceBuilder.driverClassName("org.postgresql.Driver");
        dataSourceBuilder.url(databaseUrl);
        dataSourceBuilder.username(postgresUser);
        dataSourceBuilder.password(postgresPassword);
        return dataSourceBuilder.build();
    }

    // @Bean
    // public DataSource dataSource() {
    //     logger.info("Configuring database connection for Railway...");
        
    //     // Try multiple ways to get the database URL
    //     // String finalDatabaseUrl = getDatabaseUrl();
        
    //     // if (finalDatabaseUrl == null || finalDatabaseUrl.isEmpty()) {
    //     //     logger.error("❌ No valid database URL found, falling back to H2");
    //     //     return createH2DataSource();
    //     // }
        
    //     try {
    //         // Convert and validate the URL
    //         // String jdbcUrl = convertToJdbcUrl(finalDatabaseUrl);
    //         // logger.info("Using JDBC URL: {}", jdbcUrl.replaceAll(":[^:@]*@", ":***@"));
            
    //         // // Validate URL format
    //         // validateJdbcUrl(jdbcUrl);
            
    //         // Try a simple connection test
    //         logger.info("Testing database connection...");
    //         // try (Connection testConn = DriverManager.getConnection(jdbcUrl)) {
    //         //     logger.info("✅ Database connection test successful!");
    //         //     testConn.close();
    //         // } catch (Exception e) {
    //         //     logger.error("❌ Database connection test failed: {}", e.getMessage());
    //         //     logger.warn("⚠️ Falling back to H2 in-memory database");
    //         //     return createH2DataSource();
    //         // }
            
    //         // HikariDataSource dataSource = new HikariDataSource();
    //         DriverManager dataSource = new DriverManager().getConnection(databaseUrl, postgresUser, postgresPassword)
            
    //         dataSource.setJdbcUrl(jdbcUrl);
    //         dataSource.setDriverClassName("org.postgresql.Driver");
            
    //         // Connection pool settings optimized for Railway
    //         dataSource.setMaximumPoolSize(3);
    //         dataSource.setMinimumIdle(1);
    //         dataSource.setConnectionTimeout(60000);
    //         dataSource.setIdleTimeout(300000);
    //         dataSource.setMaxLifetime(900000);
    //         dataSource.setLeakDetectionThreshold(60000);
            
    //         // Connection test settings
    //         dataSource.setConnectionTestQuery("SELECT 1");
    //         dataSource.setValidationTimeout(10000);
            
    //         logger.info("Database configuration complete");
    //         return dataSource;
            
    //     } catch (Exception e) {
    //         logger.error("Failed to configure PostgreSQL connection: {}", e.getMessage());
    //         logger.warn("⚠️ Falling back to H2 in-memory database");
    //         return createH2DataSource();
    //     }
    // }
    
    // private String getDatabaseUrl() {
    //     // Method 1: Try DATABASE_URL directly
    //     if (databaseUrl != null && !databaseUrl.isEmpty() && !databaseUrl.equals("postgresql://:***@:/")) {
    //         logger.info("Using DATABASE_URL from environment: {}", databaseUrl.replaceAll(":[^:@]*@", ":***@"));
    //         return databaseUrl;
    //     }
        
    //     // Method 2: Try to construct from individual components
    //     if (postgresUser != null && !postgresUser.isEmpty() && 
    //         postgresPassword != null && !postgresPassword.isEmpty() &&
    //         postgresHost != null && !postgresHost.isEmpty()) {
            
    //         String constructedUrl = String.format("postgresql://%s:%s@%s:%s/%s",
    //             postgresUser, postgresPassword, postgresHost, postgresPort, 
    //             postgresDb != null && !postgresDb.isEmpty() ? postgresDb : "railway");
            
    //         logger.info("Constructed DATABASE_URL from components: {}", constructedUrl.replaceAll(":[^:@]*@", ":***@"));
    //         return constructedUrl;
    //     }
        
    //     // Method 3: Try common Railway patterns
    //     String[] possibleHosts = {"maglev.proxy.rlwy.net", "postgres.railway.internal", "localhost", "127.0.0.1"};
    //     String[] possibleDbs = {"railway", "postgres", "textbook_assistant"};
        
    //     for (String host : possibleHosts) {
    //         for (String db : possibleDbs) {
    //             if (postgresUser != null && !postgresUser.isEmpty() && 
    //                 postgresPassword != null && !postgresPassword.isEmpty()) {
                    
    //                 String testUrl = String.format("postgresql://%s:%s@%s:%s/%s",
    //                     postgresUser, postgresPassword, host, postgresPort, db);
                    
    //                 logger.info("Trying constructed URL: {}", testUrl.replaceAll(":[^:@]*@", ":***@"));
                    
    //                 // Test if this URL works
    //                 try {
    //                     String jdbcUrl = convertToJdbcUrl(testUrl);
    //                     try (Connection testConn = DriverManager.getConnection(jdbcUrl)) {
    //                         logger.info("✅ Found working database URL!");
    //                         testConn.close();
    //                         return testUrl;
    //                     } catch (Exception e) {
    //                         logger.debug("URL {} failed: {}", testUrl.replaceAll(":[^:@]*@", ":***@"), e.getMessage());
    //                     }
    //                 } catch (Exception e) {
    //                     logger.debug("Invalid URL format: {}", testUrl.replaceAll(":[^:@]*@", ":***@"));
    //                 }
    //             }
    //         }
    //     }
        
    //     logger.error("❌ No working database URL found");
    //     return null;
    // }
    
    // private DataSource createH2DataSource() {
    //     logger.info("Creating H2 in-memory database as fallback");
        
    //     HikariDataSource dataSource = new HikariDataSource();
    //     dataSource.setJdbcUrl("jdbc:h2:mem:fallback");
    //     dataSource.setDriverClassName("org.h2.Driver");
    //     dataSource.setUsername("sa");
    //     dataSource.setPassword("");
        
    //     // Simple settings for H2
    //     dataSource.setMaximumPoolSize(5);
    //     dataSource.setMinimumIdle(1);
    //     dataSource.setConnectionTimeout(30000);
        
    //     logger.info("H2 fallback database configured");
    //     return dataSource;
    // }
    
    // private String convertToJdbcUrl(String url) {
    //     if (url == null || url.isEmpty()) {
    //         logger.warn("DATABASE_URL is not set, using default localhost");
    //         return "jdbc:postgresql://localhost:5432/textbook_assistant";
    //     }
        
    //     // If it's already a JDBC URL, return as is
    //     if (url.startsWith("jdbc:")) {
    //         return url;
    //     }
        
    //     // Convert Railway's postgresql:// format to jdbc:postgresql://
    //     if (url.startsWith("postgresql://")) {
    //         return "jdbc:" + url;
    //     }
        
    //     // If it's a postgres:// format, convert to jdbc:postgresql://
    //     if (url.startsWith("postgres://")) {
    //         return url.replace("postgres://", "jdbc:postgresql://");
    //     }
        
    //     logger.warn("Unknown database URL format: {}, using as is", url);
    //     return url;
    // }
    
    // private void validateJdbcUrl(String jdbcUrl) {
    //     try {
    //         // Remove jdbc: prefix for URI parsing
    //         String uriString = jdbcUrl.replace("jdbc:", "");
    //         URI uri = new URI(uriString);
            
    //         logger.info("URL validation - Host: {}, Port: {}, Path: {}", 
    //                    uri.getHost(), uri.getPort(), uri.getPath());
            
    //         if (uri.getHost() == null || uri.getHost().isEmpty()) {
    //             throw new RuntimeException("Invalid database URL: host is null or empty");
    //         }
            
    //     } catch (Exception e) {
    //         logger.error("Invalid JDBC URL format: {}", jdbcUrl);
    //         throw new RuntimeException("Invalid database URL format", e);
    //     }
    // }
}
