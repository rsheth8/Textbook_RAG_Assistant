package com.textbookassistant.config;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("cloud")
@EnableAutoConfiguration(exclude = {
    org.springframework.boot.actuate.autoconfigure.metrics.SystemMetricsAutoConfiguration.class
})
public class MetricsConfig {
    
    // This configuration explicitly excludes the SystemMetricsAutoConfiguration
    // that causes the cgroup/ProcessorMetrics error in containerized environments
}
