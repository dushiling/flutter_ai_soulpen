import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/utils/hive_util.dart';
import '../../core/utils/toast_util.dart';
import '../../models/copy_model.dart';
import 'collection_state.dart';

class CollectionLogic extends GetxController {
  final state = CollectionState().obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  void refreshData() => state.update((s) => s?.list = HiveUtil.getFavorites());

  Future<void> clearAll() async {
    await HiveUtil.setFavorites([]);
    refreshData();
    ToastUtil.show('已清空收藏');
  }

  Future<void> deleteAt(int index) async {
    final list = HiveUtil.getFavorites();
    list.removeAt(index);
    await HiveUtil.setFavorites(list);
    refreshData();
    ToastUtil.show('已删除');
  }

  void openDetail(CopyModel model) => Get.toNamed(AppRoutes.copyDetail, arguments: model.toJson());
}
