package com.textbookassistant.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authz -> authz
                // Allow health and info endpoints for monitoring
                .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                // Allow static resources
                .requestMatchers("/css/**", "/js/**", "/images/**").permitAll()
                // Allow main application pages
                .requestMatchers("/", "/chat", "/upload").permitAll()
                // Allow API endpoints
                .requestMatchers("/api/**").permitAll()
                // Secure everything else
                .anyRequest().authenticated()
            )
            .csrf(csrf -> csrf.disable()) // Disable CSRF for API endpoints
            .headers(headers -> headers.frameOptions().disable()); // Allow iframes if needed
        
        return http.build();
    }
}
