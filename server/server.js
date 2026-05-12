require('dotenv').config();
const express = require('express');
const cors    = require('cors');
const fetch   = require('node-fetch');
const path    = require('path');

const app = express();

// Enable CORS
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json());

// Serve H5 static files
app.use(express.static(path.join(__dirname, 'public')));

// Core endpoint: extract search keywords from user input
app.post('/api/keywords', async (req, res) => {
    const { input } = req.body;
    if (!input || !input.trim()) {
        return res.status(400).json({ error: 'input is required' });
    }

    const systemPrompt = `Ты помощник по покупкам. Извлеки ключевые слова для поиска товара из сообщения пользователя.
Верни ТОЛЬКО ключевые слова на русском языке, максимум 5 слов, без пояснений.
Пример: ввод "хочу купить зимние кроссовки" → вывод "зимние кроссовки"`;

    try {
        const response = await fetch(`${process.env.DEEPSEEK_BASE_URL}/chat/completions`, {
            method: 'POST',
            headers: {
                'Content-Type':  'application/json',
                'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`,
            },
            body: JSON.stringify({
                model: process.env.DEEPSEEK_MODEL || 'deepseek-chat',
                messages: [
                    { role: 'system', content: systemPrompt },
                    { role: 'user',   content: input.trim() },
                ],
                max_tokens:  50,
                temperature: 0.3,
            }),
        });

        if (!response.ok) {
            // DeepSeek error - fall back to raw input
            return res.json({ keywords: input.trim(), source: 'fallback' });
        }

        const data     = await response.json();
        const keywords = data.choices[0].message.content.trim();
        res.json({ keywords, source: 'deepseek' });

    } catch (err) {
        console.error('[DeepSeek Error]', err.message);
        res.json({ keywords: input.trim(), source: 'fallback' });
    }
});

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// All other routes return the H5 index page
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`✅ Ocai server running on http://localhost:${PORT}`);
    console.log(`   DeepSeek model: ${process.env.DEEPSEEK_MODEL || 'deepseek-chat'}`);
});
