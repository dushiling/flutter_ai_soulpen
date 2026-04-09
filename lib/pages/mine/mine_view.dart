import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import 'mine_logic.dart';

class MineView extends StatelessWidget {
  const MineView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(MineLogic());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final user = logic.state.value.user;
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFD4C4E8),
                      Color(0xFFE8E0F0),
                      Colors.white,
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        child: GestureDetector(
                          onTap: logic.goEditProfile,
                          child: Row(
                            children: [
                              user.avatar.isNotEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.w),
                                      ),
                                      child: CircleAvatar(
                                        radius: 30.r,
                                        backgroundColor: AppColors.primary,
                                        backgroundImage: user.avatar.startsWith('http')
                                            ? NetworkImage(user.avatar)
                                            : FileImage(File(user.avatar)) as ImageProvider,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 30.r,
                                      backgroundColor: AppColors.primaryDeep,
                                      child: Icon(Icons.person, size: 24, color: Colors.white),
                                    ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.nickname,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 60.h),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '功能列表',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildFeatureItem(
                                  icon: Icons.folder_rounded,
                                  label: '数据管理',
                                  onTap: logic.goDataManage,
                                ),
                                _buildFeatureItem(
                                  icon: Icons.settings_rounded,
                                  label: '文案设置',
                                  onTap: logic.goSetting,
                                ),
                                _buildFeatureItem(
                                  icon: Icons.cleaning_services_rounded,
                                  label: '清理缓存',
                                  onTap: logic.clearCache,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                child: Center(
                  child: Text(
                    '版本信息：V2.3.1',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSub,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.primaryDeep,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textMain,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
