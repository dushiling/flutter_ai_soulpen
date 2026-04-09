import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.text = 'AI正在创作中✨'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.primaryDeep),
        SizedBox(height: 10.h),
        Text(text, style: TextStyle(fontSize: 14.sp, color: AppColors.textSub)),
      ],
    );
  }
}
