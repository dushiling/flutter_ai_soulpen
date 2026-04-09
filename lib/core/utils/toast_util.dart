import 'package:fluttertoast/fluttertoast.dart';

import '../constants/app_colors.dart';

class ToastUtil {
  static void show(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.textMain.withValues(alpha: 0.85),
      textColor: AppColors.backgroundWhite,
      fontSize: 14,
    );
  }
}
