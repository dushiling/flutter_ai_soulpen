import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import 'splash_state.dart';

class SplashLogic extends GetxController {
  final state = SplashState();

  @override
  void onInit() {
    super.onInit();
    // 设置全屏，隐藏状态栏和导航栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void onReady() {
    super.onReady();
    // 延迟2秒后跳转到主页
    Future.delayed(const Duration(seconds: 2), () {
      // 恢复系统UI
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Get.offAllNamed(AppRoutes.main);
    });
  }

  @override
  void onClose() {
    super.onClose();
    // 确保离开页面时恢复系统UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
