import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/utils/hive_util.dart';
import '../../core/utils/toast_util.dart';
import '../../models/copy_model.dart';
import 'history_state.dart';

class HistoryLogic extends GetxController {
  final state = HistoryState().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() => state.update((s) => s?.list = HiveUtil.getHistory());

  Future<void> clear() async {
    await HiveUtil.setHistory([]);
    load();
  }

  Future<void> deleteAt(int i) async {
    final list = HiveUtil.getHistory();
    list.removeAt(i);
    await HiveUtil.setHistory(list);
    load();
    ToastUtil.show('已删除');
  }

  Future<void> favorite(CopyModel model) async {
    final list = HiveUtil.getFavorites();
    if (list.every((e) => e.content != model.content)) {
      list.insert(0, model..isFavorite = true);
      await HiveUtil.setFavorites(list);
      ToastUtil.show('收藏成功');
    }
  }

  void openDetail(CopyModel m) => Get.toNamed(AppRoutes.copyDetail, arguments: m.toJson());
}
