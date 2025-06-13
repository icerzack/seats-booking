package vasilkov.tgbot;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/health")
@RequiredArgsConstructor
public class HealthController {

//    @Value("${spring.datasource.url}")
//    private String dbUrl;
//
//    @Value("${spring.datasource.username}")
//    private String dbUsername;

    @Value("${telegram.bot-token}")
    private String botToken;

    @Value("${telegram.bot-name}")
    private String botName;

    @Value("${telegram.webhook-path}")
    private String webhookPath;

    @Value("${telegram.api-url}")
    private String apiUrl;

    @GetMapping("/env")
    public Map<String, Object> getEnvironmentVariables() {
        Map<String, Object> envVars = new HashMap<>();
        
//        // Database configuration
//        envVars.put("DB_URL", dbUrl);
//        envVars.put("DB_USERNAME", dbUsername);
//        envVars.put("DB_PASSWORD", "***HIDDEN***"); // Never expose passwords
//
        // Telegram configuration
        envVars.put("TELEGRAM_BOT_TOKEN", botToken != null && !botToken.isEmpty() ? "***SET***" : "***NOT_SET***");
        envVars.put("TELEGRAM_BOT_NAME", botName);
        envVars.put("TELEGRAM_WEBHOOK_PATH", webhookPath);
        envVars.put("TELEGRAM_API_URL", apiUrl);
        
        // System environment variables (selected)
        envVars.put("JAVA_VERSION", System.getProperty("java.version"));
        envVars.put("OS_NAME", System.getProperty("os.name"));
        
        return envVars;
    }

    @GetMapping("/status")
    public Map<String, String> getStatus() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "UP");
        status.put("service", "telegram-bot");
        status.put("timestamp", java.time.Instant.now().toString());
        return status;
    }

    @GetMapping("/telegram-config")
    public Map<String, Object> getTelegramConfig() {
        Map<String, Object> config = new HashMap<>();
        config.put("bot-name", botName);
        config.put("webhook-path", webhookPath);
        config.put("api-url", apiUrl);
        config.put("bot-token-configured", botToken != null && !botToken.isEmpty());
        return config;
    }
} 