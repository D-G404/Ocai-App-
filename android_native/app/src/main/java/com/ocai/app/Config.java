package com.ocai.app;

/**
 * App configuration - edit this file only
 */
public class Config {

    // ========== DeepSeek settings ==========
    // Direct mode (for development/testing): fill in your API Key
    // For production, use backend proxy by setting USE_BACKEND_PROXY = true
    public static final String DEEPSEEK_API_KEY = "sk-UQigHYEfCA4vsJukqcodUDxPy515E9BIpSRfgrhmbt65GNSj";
    public static final String DEEPSEEK_MODEL   = "deepseek-chat";
    public static final String DEEPSEEK_URL     = "https://api.chatanywhere.tech/v1/chat/completions";

    // ========== Backend proxy settings ==========
    // true  = call backend proxy (API Key is safe, recommended for production)
    // false = call DeepSeek directly (convenient for development)
    public static final boolean USE_BACKEND_PROXY = false;
    public static final String  BACKEND_URL       = "http://YOUR_SERVER_IP:3000";

    // ========== ocai.ru ==========
    public static final String OCAI_HOME   = "https://ocai.ru";
    public static final String OCAI_SEARCH = "https://ocai.ru/search?keyword=";
}
