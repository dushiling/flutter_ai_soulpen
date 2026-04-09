import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../collection/collection_view.dart';
import '../home/home_view.dart';
import '../mine/mine_view.dart';
import 'main_tab_logic.dart';

class MainTabView extends StatelessWidget {
  const MainTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(MainTabLogic());
    final pages = const [HomeView(), CollectionView(), MineView()];
    return Obx(() {
      final idx = logic.state.value.index;
      return Scaffold(
        body: IndexedStack(index: idx, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: idx,
          selectedItemColor: AppColors.primaryDeep,
          unselectedItemColor: AppColors.textSub,
          onTap: logic.changeTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '文案生成'),
            BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark_outlined), label: '我的收藏'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '我的'),
          ],
        ),
      );
    });
  }
}
