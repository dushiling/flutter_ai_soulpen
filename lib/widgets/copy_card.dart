import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/common_util.dart';
import '../models/copy_model.dart';

class CopyCard extends StatelessWidget {
  const CopyCard({
    super.key,
    required this.model,
    this.showTime = false,
    this.onTap,
  });

  final CopyModel model;
  final bool showTime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(CommonUtil.shortText(model.content, max: 28), style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            Text('${model.scene} · ${model.styles.join("/")}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSub)),
            if (showTime)
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Text(
                  CommonUtil.formatTime(model.createdAt),
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSub),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
