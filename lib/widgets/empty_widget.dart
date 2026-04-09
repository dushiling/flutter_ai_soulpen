import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome, size: 54.w, color: AppColors.primaryDeep),
        SizedBox(height: 12.h),
        Text(text, style: TextStyle(fontSize: 14.sp, color: AppColors.textSub)),
      ],
    );
  }
}
