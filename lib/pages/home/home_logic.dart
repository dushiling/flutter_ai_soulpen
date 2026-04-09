import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../api/doubao_api.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/hive_util.dart';
import '../../core/utils/toast_util.dart';
import '../../models/copy_model.dart';
import '../collection/collection_logic.dart';
import 'home_state.dart';

class HomeLogic extends GetxController {
  final state = HomeState().obs;

  // 控制器和焦点节点放在Logic中管理，避免被重建
  late final TextEditingController inputController;
  late final FocusNode inputFocusNode;
  bool _isListenerAdded = false;

  final scenes = ['朋友圈', '小红书', '微博', '头像签名'];
  final styles = ['高冷拽酷', '温柔治愈', '搞笑沙雕', '极简短句', '文艺清新', '元气可爱','伤感 emo','励志上进','颜文字'];

  @override
  void onInit() {
    super.onInit();
    // 初始化控制器和焦点节点
    inputController = TextEditingController();
    inputFocusNode = FocusNode();

    _loadSettings();

    // 添加焦点监听器
    inputFocusNode.addListener(_onFocusChange);
    _isListenerAdded = true;
  }

  void _loadSettings() {
    final defaultScene = HiveUtil.getDefaultScene();
    final defaultStyles = HiveUtil.getDefaultStyles();

    state.update((s) {
      if (s == null) return;
      s.selectedScene = defaultScene;
      s.selectedStyles = defaultStyles.isEmpty ? ['温柔治愈'] : List<String>.from(defaultStyles);
    });
  }

  void _onFocusChange() {
    final hasFocus = inputFocusNode.hasFocus;
    if (hasFocus != state.value.isInputFocused) {
      state.update((s) {
        if (s != null) {
          s.isInputFocused = hasFocus;
        }
      });
    }
  }

  @override
  void onClose() {
    // 移除监听器
    if (_isListenerAdded) {
      inputFocusNode.removeListener(_onFocusChange);
      _isListenerAdded = false;
    }
    // 释放资源
    inputController.dispose();
    inputFocusNode.dispose();
    super.onClose();
  }

  void setInput(String text) => state.update((s) => s?.input = text);

  void clearInput() {
    state.update((s) {
      s?.input = '';
    });
    inputController.clear();
  }

  void changeScene(String v) => state.update((s) => s?.selectedScene = v);

  void toggleStyle(String v) {
    state.update((s) {
      if (s == null) return;
      if (s.selectedStyles.contains(v)) {
        if (s.selectedStyles.length > 1) s.selectedStyles.remove(v);
      } else {
        s.selectedStyles.add(v);
      }
    });
  }

  Future<void> generate() async {
    if (state.value.input.trim().isEmpty) {
      ToastUtil.show('请输入场景/心情/事件');
      return;
    }
    state.update((s) => s?.loading = true);
    try {
      final text = await DoubaoApi.generate(
        input: state.value.input.trim(),
        scene: state.value.selectedScene,
        styles: state.value.selectedStyles,
      );

      // 分割多条文案
      final results = text.split('\n\n').where((s) => s.trim().isNotEmpty).toList();

      state.update((s) {
        if (s == null) return;
        s.result = text;
        s.dialogResults = results;
        s.currentResultIndex = 0;
        s.loading = false;
        s.showResultDialog = true;
        // 检查每条文案是否已收藏
        s.isFavorites = results.map((content) => _checkIsFavorite(content)).toList();
      });

      // 重置首页状态
      clearInput();
      inputFocusNode.unfocus();
      // 立即清空result，灰色卡片恢复默认状态
      state.update((s) => s?.result = '');

      // 根据设置决定是否保存历史记录
      if (HiveUtil.getAutoSaveHistory()) {
        for (int i = 0; i < results.length; i++) {
          final model = CopyModel(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            content: results[i],
            scene: state.value.selectedScene,
            styles: List<String>.from(state.value.selectedStyles),
            createdAt: DateTime.now(),
          );
          final history = HiveUtil.getHistory()..insert(0, model);

          // 根据保留时长清理旧记录
          final retention = HiveUtil.getHistoryRetention();
          if (retention == '7') {
            if (history.length > 7) {
              history.removeRange(7, history.length);
            }
          } else if (retention == '30') {
            if (history.length > 30) {
              history.removeRange(30, history.length);
            }
          }
          // 'forever' 不限制数量

          await HiveUtil.setHistory(history);
        }
      }

      await HiveUtil.setRecentStyles(state.value.selectedStyles.take(3).toList());
    } catch (_) {
      state.update((s) => s?.loading = false);
      ToastUtil.show(AppStrings.aiError);
    }
  }

  // 检查文案是否已收藏
  bool _checkIsFavorite(String content) {
    final fav = HiveUtil.getFavorites();
    return fav.any((e) => e.content == content);
  }

  Future<void> copyResult(int index) async {
    final results = state.value.dialogResults;
    if (index < 0 || index >= results.length) return;
    await Clipboard.setData(ClipboardData(text: results[index]));
    ToastUtil.show('文案已复制');
  }

  Future<void> favoriteResult(int index) async {
    final results = state.value.dialogResults;
    if (index < 0 || index >= results.length) return;

    final content = results[index];
    final fav = HiveUtil.getFavorites();
    final exist = fav.any((e) => e.content == content);

    if (exist) {
      // 取消收藏
      fav.removeWhere((e) => e.content == content);
      await HiveUtil.setFavorites(fav);
      state.update((s) {
        if (s != null && index < s.isFavorites.length) {
          s.isFavorites[index] = false;
        }
      });
      ToastUtil.show('已取消收藏');
    } else {
      // 添加收藏
      fav.insert(
        0,
        CopyModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          content: content,
          scene: state.value.selectedScene,
          styles: List<String>.from(state.value.selectedStyles),
          createdAt: DateTime.now(),
          isFavorite: true,
        ),
      );
      await HiveUtil.setFavorites(fav);
      state.update((s) {
        if (s != null && index < s.isFavorites.length) {
          s.isFavorites[index] = true;
        }
      });
      ToastUtil.show('收藏成功');
    }
    // 通知收藏页面刷新
    _notifyCollectionRefresh();
  }

  // 通知收藏页面刷新数据
  void _notifyCollectionRefresh() {
    try {
      final collectionController = Get.find<CollectionLogic>(tag: 'collection');
      collectionController.refreshData();
    } catch (_) {
      // CollectionLogic 可能还未初始化，忽略错误
    }
  }

  void goHistory() => Get.toNamed(AppRoutes.history);

  void closeResultDialog() => state.update((s) => s?.showResultDialog = false);

  void goCardCreate(int index) {
    final results = state.value.dialogResults;
    if (index < 0 || index >= results.length) return;

    // 获取第一个选中的风格作为卡片背景风格
    final style = state.value.selectedStyles.isNotEmpty ? state.value.selectedStyles.first : '';
    state.update((s) => s?.showResultDialog = false);
    Get.toNamed(AppRoutes.cardCreate, arguments: {
      'content': results[index],
      'style': style,
    });
  }
}
