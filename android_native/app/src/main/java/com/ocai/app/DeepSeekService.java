package com.ocai.app;

import org.json.JSONArray;
import org.json.JSONObject;
import java.io.IOException;
import okhttp3.*;

public class DeepSeekService {

    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");
    private static final OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(15, java.util.concurrent.TimeUnit.SECONDS)
            .readTimeout(20, java.util.concurrent.TimeUnit.SECONDS)
            .build();

    public interface Callback {
        void onSuccess(String keywords);
        void onError(String fallback);  // fall back to raw input on failure
    }

    /**
     * Extract product search keywords from user input (async)
     */
    public static void extractKeywords(String userInput, Callback callback) {
        new Thread(() -> {
            try {
                String keywords = Config.USE_BACKEND_PROXY
                        ? callBackendProxy(userInput)
                        : callDeepSeekDirect(userInput);
                callback.onSuccess(keywords);
            } catch (Exception e) {
                callback.onError(userInput);  // fall back to raw input on any error
            }
        }).start();
    }

    // Direct DeepSeek call (development mode)
    private static String callDeepSeekDirect(String userInput) throws Exception {
        String system = "Ты помощник по покупкам. Извлеки ключевые слова для поиска товара из сообщения пользователя.\n"
                + "Верни ТОЛЬКО ключевые слова на русском языке, максимум 5 слов, без пояснений.\n"
                + "Пример: ввод \"хочу купить зимние кроссовки\" → вывод \"зимние кроссовки\"";

        JSONObject body = new JSONObject();
        body.put("model", Config.DEEPSEEK_MODEL);
        JSONArray messages = new JSONArray();
        messages.put(new JSONObject().put("role", "system").put("content", system));
        messages.put(new JSONObject().put("role", "user").put("content", userInput));
        body.put("messages", messages);
        body.put("max_tokens", 50);
        body.put("temperature", 0.3);

        Request request = new Request.Builder()
                .url(Config.DEEPSEEK_URL)
                .addHeader("Authorization", "Bearer " + Config.DEEPSEEK_API_KEY)
                .post(RequestBody.create(body.toString(), JSON))
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) throw new IOException("HTTP " + response.code());
            JSONObject result = new JSONObject(response.body().string());
            return result.getJSONArray("choices")
                    .getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content")
                    .trim();
        }
    }

    // Backend proxy call (production mode)
    private static String callBackendProxy(String userInput) throws Exception {
        JSONObject body = new JSONObject();
        body.put("input", userInput);

        Request request = new Request.Builder()
                .url(Config.BACKEND_URL + "/api/keywords")
                .post(RequestBody.create(body.toString(), JSON))
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) throw new IOException("HTTP " + response.code());
            JSONObject result = new JSONObject(response.body().string());
            return result.getString("keywords");
        }
    }
}
