import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import 'splash_logic.dart';
import 'splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(SplashLogic());
    final state = logic.state;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body:Image.asset(
          'assets/images/splash.png',
          fit: BoxFit.contain,
        ),
    );
  }
}
