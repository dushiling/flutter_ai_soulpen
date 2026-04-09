import 'dart:convert';
import 'package:http/http.dart' as http;

class QwenImageService {
  // 确保这里的 Key 是你在阿里云百炼平台获取的
  final String apiKey = 'sk-xxx';//Qwen-Image-2.0
  final String baseUrl = 'https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation';

  Future<String?> generateImage({
    required String input,
    required List<String> styles,
    required String textStyle,
    required String material,
  }) async {
    final prompt = '文字:$input,字体:$textStyle,材质:$material,氛围:${styles.join('、')}';
    try {
      // 1. 直接调用同步接口获取结果
      // 注意：同步模式下，请求会阻塞直到图片生成或超时
      final url = await _submitSyncTask(prompt);
      return url;
    } catch (e) {
      print('❌ 生成异常: $e');
      return null;
    } 
  }
   /// 提交同步任务
  Future<String?> _submitSyncTask(String prompt) async {
    final Map<String, dynamic> requestBody = {
      "model": "qwen-image-2.0",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [{"text": prompt}]
          }
        ]
      },
      "parameters": {
        "size": "1536*2688",
        "n": 1,
        "prompt_extend": true
      }
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        // ❌ 重点：这里完全移除了 'X-DashScope-Async' 头部
        // 这样服务器就会以同步模式处理，直接返回图片 URL
      },
      body: jsonEncode(requestBody),
    );

    print('📤 状态码: ${response.statusCode}');
    print('📤 响应: ${response.body}');

  if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ 修正解析路径：根据你提供的成功日志
      // 路径: output -> choices -> [0] -> message -> content -> [0] -> image
      try {
        final imageUrl = data['output']['choices'][0]['message']['content'][0]['image'];
        print('✅ 生成成功，图片地址: $imageUrl');
        return imageUrl;
      } catch (e) {
        print('❌ 解析 JSON 失败，未找到图片字段: $e');
        return null;
      }
    } else {
      print('❌ HTTP 错误: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}