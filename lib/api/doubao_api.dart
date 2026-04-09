import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/utils/hive_util.dart';


class DoubaoApi {

  static const String _baseUrl = 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';

  static Future<String> generate({
    required String input,
    required String scene,
    required List<String> styles,
  }) async {
    //火山引擎API调用
    String apiKey = "API Key";   // 替换为你的 API Key
    String endpointId = "ep-xxx"; // 替换为你的接入点 ID   Seed-1.6

    if (apiKey.isEmpty) {
      throw Exception('缺少DOUBAO_API_KEY，请用 --dart-define 传入');
    }

    final lengthPreference = HiveUtil.getLengthPreference();
    final autoAddEmoji = HiveUtil.getAutoAddEmoji();
    final autoAddTags = HiveUtil.getAutoAddTags();
    final generateQuality = HiveUtil.getGenerateQuality();
    final generateCount = HiveUtil.getGenerateCount();

    String lengthConstraint = '';
    if (lengthPreference == 'short') {
      lengthConstraint = '字数10-30字';
    } else if (lengthPreference == 'medium') {
      lengthConstraint = '字数30-80字';
    } else {
      lengthConstraint = '字数80字以上';
    }

    String extraRequirements = '';
    if (autoAddEmoji) {
      extraRequirements += '适当添加emoji表情，';
    }
    if (autoAddTags) {
      extraRequirements += '最后添加相关的话题标签(#)，';
    }

    double temperature = 0.7;
    int maxTokens = 50;
    if (generateQuality == 'fast') {
      temperature = 0.5;
      maxTokens = 30;
    } else if (generateQuality == 'high') {
      temperature = 0.9;
      maxTokens = 100;
    }

    // 根据generateCount生成多条文案
    List<String> results = [];
    
    for (int i = 0; i < generateCount; i++) {
      final prompt = '写一段适合$scene的${styles.join("、")}风格文案，场景是$input，$lengthConstraint，$extraRequirements只输出纯文案，不要加括号、说明或语气词。';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
        body: jsonEncode({
          'model': endpointId,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API错误: ${response.statusCode} ${response.body}');
      }
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = map['choices'] as List?;
      if (choices == null || choices.isEmpty) throw Exception('模型返回为空');
      final content = (choices.first['message']['content'] as String?)?.trim() ?? '';
      if (content.isEmpty) throw Exception('模型返回为空');
      
      results.add(content);
    }

    // 将多条文案用换行分隔返回
    return results.join('\n\n');
  }
}
