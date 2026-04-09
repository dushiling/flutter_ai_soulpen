import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/utils/hive_util.dart';
import '../../core/utils/toast_util.dart';
import 'mine_state.dart';

class MineLogic extends GetxController {
  final state = MineState().obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() => state.update((s) => s?.user = HiveUtil.getUser());

  void goDataManage() => Get.toNamed(AppRoutes.dataManage)?.then((_) => loadUser());
  void goSetting() => Get.toNamed(AppRoutes.copySetting);
  void goEditProfile() => Get.toNamed(AppRoutes.editProfile)?.then((_) => loadUser());

  Future<void> clearCache() async {
    await HiveUtil.clearAllCache();
    ToastUtil.show('缓存清理成功');
  }
}
