import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import 'pressable_scale.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.text,
    required this.onTap,
    this.filled = true,
  });

  final String text;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26.r),
          color: filled ? AppColors.primary : AppColors.backgroundWhite,
          border: Border.all(color: AppColors.primaryDeep),
        ),
        child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: filled ? AppColors.textMain : AppColors.primaryDeep,
                    decoration: TextDecoration.none,
                  ),
                ),
      ),
    );
  }
}
