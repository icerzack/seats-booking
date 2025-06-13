package vasilkov.tgbot;

import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;

import java.util.HashMap;
import java.util.Map;


@RestController
@AllArgsConstructor
public class BasedController {
    private final Bot bot;
    private final ChatRegistry chatRegistry;

    @PostMapping("/broadcast")
    public ResponseEntity<?> broadcast(@RequestBody Map<String, Object> bookingData) {
        String message = String.format(
                "✅ *Новая бронь!*\n\n" +
                        "👤 *Пользователь:* %s\n" +
                        "🚪 *Комната:* %s\n" +
                        "⏳ *Начало:* %s\n" +
                        "⏱ *Окончание:* %s\n" +
                        "📝 *Комментарий:* %s",
                bookingData.get("Пользователь"),
                bookingData.get("Комната"),
                bookingData.get("Начало"),
                bookingData.get("Окончание"),
                bookingData.get("Комментарий")
        );
        String botToken = "7625632403:AAFvrsoVakW0cBfPVibfPBZOtwIOq9R-zL4";
        String chatId = "804881648";
        String url = "https://api.telegram.org/bot" + botToken + "/sendMessage";
        RestTemplate restTemplate = new RestTemplate();
        Map<String, String> request = new HashMap<>();
        request.put("chat_id", chatId);
        request.put("text", message);
        restTemplate.postForEntity(url, request, String.class);
        return ResponseEntity.ok("Done");
    }

    @PostMapping
    public void onUpdate(@RequestBody Update update) throws TelegramApiException {
        bot.onWebhookUpdateReceived(update);
    }
}
