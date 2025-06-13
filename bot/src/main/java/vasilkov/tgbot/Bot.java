package vasilkov.tgbot;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;
import org.telegram.telegrambots.meta.api.methods.BotApiMethod;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.methods.updates.SetWebhook;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import org.telegram.telegrambots.starter.SpringWebhookBot;

@Getter
@Setter
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Bot extends SpringWebhookBot {
    final ChatRegistry chatRegistry;

    String botPath;
    String botUsername;
    String botToken;

    public Bot(SetWebhook setWebhook, ChatRegistry chatRegistry) {
        super(setWebhook);
        this.chatRegistry = chatRegistry;
    }

    @Override
    public BotApiMethod<?> onWebhookUpdateReceived(Update update) {
        try {
            return handleUpdate(update);
        } catch (Exception e) {
            return new SendMessage(update.getMessage().getChatId().toString(), "Sorry");
        }
    }

    private BotApiMethod<?> handleUpdate(Update update) throws TelegramApiException {
        System.out.println(update.toString());
        if (update.hasMessage()) {
            String chatId = update.getMessage().getChatId().toString();
            chatRegistry.addChatId(chatId);
            execute(new SendMessage(chatId, "Привет! Я Вас услышал."));
        }
        return null;
    }
}