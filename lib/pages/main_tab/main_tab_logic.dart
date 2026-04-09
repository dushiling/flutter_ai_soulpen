import 'package:get/get.dart';

import 'main_tab_state.dart';

class MainTabLogic extends GetxController {
  final state = MainTabState().obs;

  void changeTab(int index) {
    state.update((s) {
      s?.index = index;
    });
  }
}
