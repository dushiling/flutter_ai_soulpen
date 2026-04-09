import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import 'pressable_scale.dart';

class TagWidget extends StatelessWidget {
  const TagWidget({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDeep : AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: selected ? Colors.white : AppColors.textMain,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
