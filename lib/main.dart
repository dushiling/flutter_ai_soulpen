import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/constants/app_colors.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/utils/hive_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveUtil.init();

  // 设置状态栏样式 - 背景透明
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景透明
      statusBarIconBrightness: Brightness.dark, // 状态栏图标颜色
      statusBarBrightness: Brightness.light, // 状态栏亮度
      systemNavigationBarColor: AppColors.backgroundWhite, // 导航栏背景色
      systemNavigationBarIconBrightness: Brightness.dark, // 导航栏图标颜色
    ),
  );

  runApp(const SoulPenApp());
}

class SoulPenApp extends StatelessWidget {
  const SoulPenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return GetMaterialApp(
          title: 'SoulPen AI社交文案神器',
          debugShowCheckedModeBanner: false,
          getPages: AppPages.pages,
          initialRoute: AppRoutes.splash,
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 220),
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.backgroundWhite,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
          ),
        );
      },
    );
  }
}
