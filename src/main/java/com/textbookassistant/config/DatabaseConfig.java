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
        logger.info("Configuring PostgreSQL database connection...");
        
        DataSourceBuilder dataSourceBuilder = DataSourceBuilder.create();
        dataSourceBuilder.driverClassName("org.postgresql.Driver");
        dataSourceBuilder.url(databaseUrl);
        dataSourceBuilder.username(postgresUser);
        dataSourceBuilder.password(postgresPassword);
        
        logger.info("PostgreSQL database configuration complete");
        return dataSourceBuilder.build();
    }
}
