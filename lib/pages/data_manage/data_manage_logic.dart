import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/hive_util.dart';
import '../../core/utils/toast_util.dart';
import '../collection/collection_logic.dart';
import '../history/history_logic.dart';
import '../home/home_logic.dart';
import '../mine/mine_logic.dart';
import 'data_manage_state.dart';

class DataManageLogic extends GetxController {
  final state = DataManageState().obs;

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  Future<void> loadFiles() async {
    List<String> files = [];
    
    try {
      // 尝试加载下载目录中的备份文件
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          final downloadFiles = downloadDir.listSync().whereType<File>().where((e) => e.path.endsWith('.json') && e.path.contains('soulpen_backup')).map((e) => e.path).toList();
          files.addAll(downloadFiles);
        }
      }
      
      // 加载应用文档目录中的备份文件
      final appDir = await getApplicationDocumentsDirectory();
      final appFiles = appDir.listSync().whereType<File>().where((e) => e.path.endsWith('.json') && e.path.contains('soulpen_backup')).map((e) => e.path).toList();
      files.addAll(appFiles);
      
      // 去重并按时间排序（文件名包含时间戳）
      files = files.toSet().toList()..sort((a, b) => b.compareTo(a));
    } catch (e) {
      // 如果出错，只加载应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      files = appDir.listSync().whereType<File>().where((e) => e.path.endsWith('.json')).map((e) => e.path).toList();
    }
    
    state.update((s) => s?.backups = files);
  }

  Future<void> backup() async {
    state.update((s) => s?.loading = true);
    final path = await HiveUtil.backupToJsonFile();
    state.update((s) => s?.loading = false);
    ToastUtil.show('备份成功，已保存至$path');
    await loadFiles();
  }

  Future<void> restoreByPath(String path) async {
    try {
      state.update((s) => s?.loading = true);
      await HiveUtil.restoreByPath(path);
      state.update((s) => s?.loading = false);
      ToastUtil.show('恢复成功');
      // 通知相关页面刷新数据
      _notifyRefresh();
    } catch (_) {
      state.update((s) => s?.loading = false);
      ToastUtil.show('恢复失败，请检查备份文件');
    }
  }

  // 通知相关页面刷新数据
  void _notifyRefresh() {
    try {
      // 通知收藏页面刷新
      final collectionController = Get.find<CollectionLogic>(tag: 'collection');
      collectionController.refreshData();
    } catch (_) {
      // CollectionLogic 可能还未初始化，忽略错误
    }

    try {
      // 通知历史记录页面刷新
      final historyController = Get.find<HistoryLogic>();
      historyController.load();
    } catch (_) {
      // HistoryLogic 可能还未初始化，忽略错误
    }

    try {
      // 通知个人中心页面刷新
      final mineController = Get.find<MineLogic>();
      mineController.loadUser();
    } catch (_) {
      // MineLogic 可能还未初始化，忽略错误
    }

    try {
      // 通知首页刷新
      final homeController = Get.find<HomeLogic>();
      // 首页可能需要重新加载用户设置等
    } catch (_) {
      // HomeLogic 可能还未初始化，忽略错误
    }
  }
}
