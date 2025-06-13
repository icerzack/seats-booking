package vasilkov.tgbot;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
public class ChatRegistry {
    private final List<String> chatIds = new CopyOnWriteArrayList<>();

    public void addChatId(String chatId) {
        if (!chatIds.contains(chatId)) {
            chatIds.add(chatId);
        }
    }

    public List<String> getChatIds() {
        return chatIds;
    }
}
