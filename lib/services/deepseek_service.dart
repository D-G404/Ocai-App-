import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class DeepseekService {
  // 调用 DeepSeek 提取商品搜索关键词
  static Future<String> extractKeywords(String userInput) async {
    const systemPrompt = '''Ты помощник по покупкам на сайте ocai.ru (покупка товаров из Китая).
Пользователь описывает товар, который хочет купить.
Твоя задача: извлечь ключевые слова для поиска товара.

Правила:
- Верни ТОЛЬКО поисковые ключевые слова на русском языке
- Максимум 5 слов, самые важные
- Никаких пояснений, только слова
- Если пользователь уже написал конкретный товар — верни как есть

Примеры:
Ввод: "хочу купить удобные кроссовки для бега"
Вывод: кроссовки для бега

Ввод: "нужна детская куртка на зиму размер 110"
Вывод: детская куртка зимняя 110''';

    try {
      final response = await http.post(
        Uri.parse('$deepseekBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $deepseekApiKey',
        },
        body: jsonEncode({
          'model': deepseekModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userInput},
          ],
          'max_tokens': 50,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final keywords = data['choices'][0]['message']['content'].toString().trim();
        return keywords;
      } else {
        // API 失败时直接用原始输入
        return userInput;
      }
    } catch (e) {
      // 网络异常时直接用原始输入
      return userInput;
    }
  }
}
