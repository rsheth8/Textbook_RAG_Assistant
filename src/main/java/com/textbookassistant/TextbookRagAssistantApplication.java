package com.textbookassistant;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories
public class TextbookRagAssistantApplication {

    public static void main(String[] args) {
        SpringApplication.run(TextbookRagAssistantApplication.class, args);
    }
}
