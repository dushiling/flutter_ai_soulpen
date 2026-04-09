import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/copy_model.dart';
import '../../models/user_model.dart';

class HiveUtil {
  static const _boxMain = 'soulpen_main';

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.openBox(_boxMain);
  }

  static Box get _box => Hive.box(_boxMain);

  static List<CopyModel> getHistory() {
    final list = (_box.get('history', defaultValue: <dynamic>[]) as List).cast<Map>();
    return list.map(CopyModel.fromJson).toList();
  }

  static Future<void> setHistory(List<CopyModel> list) async {
    await _box.put('history', list.map((e) => e.toJson()).toList());
  }

  static List<CopyModel> getFavorites() {
    final list = (_box.get('favorites', defaultValue: <dynamic>[]) as List).cast<Map>();
    return list.map(CopyModel.fromJson).toList();
  }

  static Future<void> setFavorites(List<CopyModel> list) async {
    await _box.put('favorites', list.map((e) => e.toJson()).toList());
  }

  static UserModel getUser() {
    final map = (_box.get('user', defaultValue: {'nickname': '文案达人', 'avatar': ''}) as Map);
    return UserModel.fromJson(map);
  }

  static Future<void> setUser(UserModel user) async {
    await _box.put('user', user.toJson());
  }

  static String getDefaultScene() => _box.get('defaultScene', defaultValue: '朋友圈') as String;
  static Future<void> setDefaultScene(String v) async => _box.put('defaultScene', v);

  static List<String> getDefaultStyles() =>
      ((_box.get('defaultStyles', defaultValue: <dynamic>['温柔治愈']) as List).cast<String>());
  static Future<void> setDefaultStyles(List<String> v) async => _box.put('defaultStyles', v);

  static List<String> getRecentStyles() =>
      ((_box.get('recentStyles', defaultValue: <dynamic>[]) as List).cast<String>());
  static Future<void> setRecentStyles(List<String> v) async => _box.put('recentStyles', v);

  static Future<String> backupToJsonFile() async {
    late Directory dir;
    try {
      // 尝试获取公共下载目录
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          // 如果下载目录不存在，回退到应用文档目录
          dir = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        // iOS 使用应用文档目录
        dir = await getApplicationDocumentsDirectory();
      } else {
        // 其他平台使用应用文档目录
        dir = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      // 如果获取公共目录失败，回退到应用文档目录
      dir = await getApplicationDocumentsDirectory();
    }
    
    final history = getHistory();
    final favorites = getFavorites();
    final text = jsonEncode({
      'history': history.map((e) => e.toJson()).toList(),
      'favorites': favorites.map((e) => e.toJson()).toList(),
      'user': getUser().toJson(),
      'defaultScene': getDefaultScene(),
      'defaultStyles': getDefaultStyles(),
      'recentStyles': getRecentStyles(),
      'lengthPreference': getLengthPreference(),
      'autoAddEmoji': getAutoAddEmoji(),
      'autoAddTags': getAutoAddTags(),
      'autoSaveHistory': getAutoSaveHistory(),
      'historyRetention': getHistoryRetention(),
      'generateQuality': getGenerateQuality(),
      'generateCount': getGenerateCount(),
    });
    final file = File('${dir.path}/soulpen_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(text);
    return file.path;
  }

  static Future<void> restoreByPath(String path) async {
    final file = File(path);
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final history = ((data['history'] as List?) ?? []).map((e) => CopyModel.fromJson(e as Map)).toList();
    final favorites =
        ((data['favorites'] as List?) ?? []).map((e) => CopyModel.fromJson(e as Map)).toList();
    await setHistory(history);
    await setFavorites(favorites);
    await _box.put('user', (data['user'] as Map?) ?? {'nickname': '文案达人', 'avatar': ''});
    await _box.put('defaultScene', data['defaultScene'] ?? '朋友圈');
    await _box.put('defaultStyles', (data['defaultStyles'] as List?) ?? <String>['温柔治愈']);
    await _box.put('lengthPreference', data['lengthPreference'] ?? 'medium');
    await _box.put('autoAddEmoji', data['autoAddEmoji'] ?? true);
    await _box.put('autoAddTags', data['autoAddTags'] ?? false);
    await _box.put('autoSaveHistory', data['autoSaveHistory'] ?? true);
    await _box.put('historyRetention', data['historyRetention'] ?? '30');
    await _box.put('generateQuality', data['generateQuality'] ?? 'standard');
    await _box.put('generateCount', data['generateCount'] ?? 1);
    await _box.put('recentStyles', (data['recentStyles'] as List?) ?? <String>[]);
  }

  static Future<void> clearAllCache() async {
    await _box.delete('temp_images');
  }

  static String getLengthPreference() {
    final value = _box.get('lengthPreference', defaultValue: 'medium');
    return value?.toString() ?? 'medium';
  }
  static Future<void> setLengthPreference(String v) async => await _box.put('lengthPreference', v);

  static bool getAutoAddEmoji() {
    final value = _box.get('autoAddEmoji', defaultValue: true);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return true;
  }
  static Future<void> setAutoAddEmoji(bool v) async => await _box.put('autoAddEmoji', v);

  static bool getAutoAddTags() {
    final value = _box.get('autoAddTags', defaultValue: false);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
  static Future<void> setAutoAddTags(bool v) async => await _box.put('autoAddTags', v);

  static bool getAutoSaveHistory() {
    final value = _box.get('autoSaveHistory', defaultValue: true);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return true;
  }
  static Future<void> setAutoSaveHistory(bool v) async => await _box.put('autoSaveHistory', v);

  static String getHistoryRetention() {
    final value = _box.get('historyRetention', defaultValue: '30');
    return value?.toString() ?? '30';
  }
  static Future<void> setHistoryRetention(String v) async => await _box.put('historyRetention', v);

  static String getGenerateQuality() {
    final value = _box.get('generateQuality', defaultValue: 'standard');
    return value?.toString() ?? 'standard';
  }
  static Future<void> setGenerateQuality(String v) async => await _box.put('generateQuality', v);

  static int getGenerateCount() {
    final value = _box.get('generateCount', defaultValue: 1);
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    if (value is double) return value.toInt();
    return 1;
  }
  static Future<void> setGenerateCount(int v) async => await _box.put('generateCount', v);
}
