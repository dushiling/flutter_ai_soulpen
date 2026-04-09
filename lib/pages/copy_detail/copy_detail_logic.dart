import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/utils/hive_util.dart';
import '../../core/utils/toast_util.dart';
import '../../models/copy_model.dart';
import '../collection/collection_logic.dart';
import '../home/home_logic.dart';
import 'copy_detail_state.dart';

class CopyDetailLogic extends GetxController {
  final state = CopyDetailState().obs;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    final model = CopyModel.fromJson(args);
    // 检查该文案是否已被收藏
    final favorites = HiveUtil.getFavorites();
    final isFavorite = favorites.any((e) => e.content == model.content);
    model.isFavorite = isFavorite;
    state.update((s) => s?.model = model);
  }

  Future<void> copyText() async {
    final text = state.value.model?.content ?? '';
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    ToastUtil.show('文案已复制');
  }

  Future<void> toggleFavorite() async {
    final m = state.value.model;
    if (m == null) return;
    final list = HiveUtil.getFavorites();
    final exist = list.any((e) => e.content == m.content);
    if (exist) {
      list.removeWhere((e) => e.content == m.content);
      m.isFavorite = false;
      ToastUtil.show('已取消收藏');
    } else {
      list.insert(0, m..isFavorite = true);
      ToastUtil.show('收藏成功');
    }
    await HiveUtil.setFavorites(list);
    state.refresh();
    // 同步更新收藏页面
    _notifyCollectionRefresh();
    // 同步更新首页的收藏状态（如果当前文案与首页生成的一致）
    _syncHomeFavoriteState(m.content, !exist);
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

  // 同步首页的收藏状态
  void _syncHomeFavoriteState(String content, bool isFavorite) {
    try {
      final homeLogic = Get.find<HomeLogic>();
      final dialogResults = homeLogic.state.value.dialogResults;
      // 查找当前文案在首页结果列表中的索引
      final index = dialogResults.indexWhere((result) => result == content);
      if (index != -1) {
        homeLogic.state.update((s) {
          if (s != null && index < s.isFavorites.length) {
            s.isFavorites[index] = isFavorite;
          }
        });
      }
    } catch (_) {
      // HomeLogic 可能还未初始化，忽略错误
    }
  }

  void goCard() {
    final text = state.value.model?.content ?? '';
    final style = state.value.model?.styles.isNotEmpty ?? false ? state.value.model!.styles.first : '';
    Get.toNamed(AppRoutes.cardCreate, arguments: {
      'content': text,
      'style': style,
    });
  }
}
