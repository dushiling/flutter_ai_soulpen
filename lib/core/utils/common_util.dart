import 'dart:convert';

import '../../models/copy_model.dart';

class CommonUtil {
  static String shortText(String text, {int max = 15}) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}...';
  }

  static String formatTime(DateTime t) {
    final m = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    final h = t.hour.toString().padLeft(2, '0');
    final min = t.minute.toString().padLeft(2, '0');
    return '$m-$d $h:$min';
  }

  static String exportJson(List<CopyModel> history, List<CopyModel> favorites) {
    return jsonEncode({
      'history': history.map((e) => e.toJson()).toList(),
      'favorites': favorites.map((e) => e.toJson()).toList(),
    });
  }
}
