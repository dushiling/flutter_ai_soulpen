import 'package:get/get.dart';

import '../../pages/card_create/card_create_view.dart';
import '../../pages/copy_detail/copy_detail_view.dart';
import '../../pages/copy_setting/copy_setting_view.dart';
import '../../pages/data_manage/data_manage_view.dart';
import '../../pages/edit_profile/edit_profile_view.dart';
import '../../pages/history/history_view.dart';
import '../../pages/main_tab/main_tab_view.dart';
import '../../pages/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.main, page: () => const MainTabView()),
    GetPage(name: AppRoutes.history, page: () => const HistoryView()),
    GetPage(name: AppRoutes.copyDetail, page: () => const CopyDetailView()),
    GetPage(name: AppRoutes.cardCreate, page: () => const CardCreateView()),
    GetPage(name: AppRoutes.dataManage, page: () => const DataManageView()),
    GetPage(name: AppRoutes.copySetting, page: () => const CopySettingView()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView()),
  ];
}
