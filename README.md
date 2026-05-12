# Ocai App - Quick Start

## Project Structure
```
ocai_app/
├── android_native/                 # Native Android Studio project
│   └── app/src/main/
│       ├── java/com/ocai/app/
│       │   ├── Config.java         # Configuration file (edit this)
│       │   ├── MainActivity.java
│       │   ├── WebViewActivity.java
│       │   └── DeepSeekService.java
│       └── res/layout/
│           ├── activity_main.xml
│           └── activity_webview.xml
└── server/                         # Node.js backend proxy
    ├── server.js
    ├── .env                        # Configuration file (edit this)
    ├── .env.example
    └── public/
        └── index.html              # H5 search page
```

---

## Step 1: Get an API Key

### Option A: ChatAnywhere (recommended — no VPN needed, free tier available)

> Project: https://github.com/chatanywhere/GPT_API_free
>
> Supports DeepSeek, GPT, Claude, Gemini, Grok and more via a unified OpenAI-compatible API.

1. [Claim a free API Key](https://api.chatanywhere.tech/v1/oauth/free/render) (GitHub account required)
2. Free quota: deepseek-v3 **30 requests/day**, gpt-4o-mini **200 requests/day**
3. Endpoint (China): `https://api.chatanywhere.tech/v1`
4. Endpoint (overseas): `https://api.chatanywhere.org/v1`

`.env` example:
```env
DEEPSEEK_API_KEY=sk-your-chatanywhere-key
DEEPSEEK_MODEL=deepseek-chat
DEEPSEEK_BASE_URL=https://api.chatanywhere.tech/v1
```

### Option B: DeepSeek Official (pay-as-you-go, cheapest)

1. Get a key at https://platform.deepseek.com/api_keys
2. deepseek-chat costs ~¥0.001 per request

`.env` example:
```env
DEEPSEEK_API_KEY=sk-your-deepseek-key
DEEPSEEK_MODEL=deepseek-chat
DEEPSEEK_BASE_URL=https://api.deepseek.com/v1
```

---

## Step 2: Configure and Start the Backend

```bash
cd server
cp .env.example .env      # copy config template
# edit .env and fill in your API Key (see above)
npm install
npm start                 # starts on http://localhost:3000 by default
```

Open `http://localhost:3000` to see the H5 search page.

---

## Step 3: Configure the Android App

Edit `android_native/app/src/main/java/com/ocai/app/Config.java`:

**Development** (call API directly, easy to debug):
```java
public static final String  DEEPSEEK_API_KEY  = "sk-your-key";
public static final String  DEEPSEEK_URL      = "https://api.chatanywhere.tech/v1/chat/completions";
public static final boolean USE_BACKEND_PROXY = false;
```

**Production** (call backend proxy, API Key never exposed to client):
```java
public static final boolean USE_BACKEND_PROXY = true;
public static final String  BACKEND_URL       = "http://your-server-ip:3000";
```

---

## How It Works

```
User input (Russian) → DeepSeek extracts keywords → ocai.ru search results page
```

Example:
- Input: `хочу купить удобные кроссовки для бега`
- Model output: `кроссовки для бега`
- Redirects to: `https://ocai.ru/search?keyword=кроссовки%20для%20бега`

---

## Deploy to a Server (Production)

```bash
# Install PM2 process manager
npm install -g pm2

cd server
pm2 start server.js --name ocai-server
pm2 save
pm2 startup               # enable auto-start on reboot
```

Nginx reverse proxy (optional, for custom domain):
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Security

```
Android App ──┐
              ├──→ Backend server (.env holds the Key, never sent to client) ──→ DeepSeek / ChatAnywhere API
H5 page     ──┘
```

The API Key lives only in the server-side `.env` file and is never exposed to users.
