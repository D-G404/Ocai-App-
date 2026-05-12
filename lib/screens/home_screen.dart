import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/deepseek_service.dart';
import '../config.dart';
import 'webview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _statusText = '';

  Future<void> _search() async {
    final input = _searchController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusText = 'Анализирую запрос...'; // 正在分析请求
    });

    // 调用 DeepSeek 提取关键词
    final keywords = await DeepseekService.extractKeywords(input);

    setState(() => _statusText = 'Ищу товары...');

    final searchUrl = '$ocaiSearchUrl${Uri.encodeComponent(keywords)}';

    setState(() => _isLoading = false);

    if (!mounted) return;

    // Flutter Web 直接打开浏览器
    if (kIsWeb) {
      await launchUrl(Uri.parse(searchUrl), mode: LaunchMode.externalApplication);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebViewScreen(url: searchUrl, title: keywords),
        ),
      );
    }
  }

  void _openHome() {
    if (kIsWeb) {
      launchUrl(Uri.parse(ocaiBaseUrl), mode: LaunchMode.externalApplication);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WebViewScreen(url: ocaiBaseUrl, title: 'Ocai.ru'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Logo + 标题
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shopping_bag, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ocai',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Товары из Китая', // 中国商品
                        style: TextStyle(color: Color(0xFF8888AA), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // 搜索提示文字
              const Text(
                'Что вы ищете?', // 你在找什么？
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Опишите товар на русском языке', // 用俄语描述商品
                style: TextStyle(color: Color(0xFF8888AA), fontSize: 14),
              ),

              const SizedBox(height: 32),

              // 搜索输入框
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6C63FF), width: 1.5),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: 3,
                  minLines: 2,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    hintText: 'Например: хочу купить зимнюю куртку для ребёнка...',
                    hintStyle: TextStyle(color: Color(0xFF555577), fontSize: 14),
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 搜索按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    disabledBackgroundColor: const Color(0xFF3D3860),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _statusText,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Найти товар', // 搜索商品
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // 快捷入口
              const Text(
                'Быстрый переход', // 快速导航
                style: TextStyle(color: Color(0xFF8888AA), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _quickLink(Icons.home, 'Главная', () => _openHome()),
                  const SizedBox(width: 12),
                  _quickLink(Icons.category, 'Категории', () {
                    final url = '$ocaiBaseUrl/category';
                    if (kIsWeb) {
                      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => WebViewScreen(url: url, title: 'Категории'),
                      ));
                    }
                  }),
                  const SizedBox(width: 12),
                  _quickLink(Icons.local_offer, 'Акции', () {
                    final url = '$ocaiBaseUrl/user/coupons';
                    if (kIsWeb) {
                      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => WebViewScreen(url: url, title: 'Акции'),
                      ));
                    }
                  }),
                ],
              ),

              const Spacer(),

              // 底部说明
              Center(
                child: Text(
                  'AI поиск на базе DeepSeek',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickLink(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF6C63FF), size: 22),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
