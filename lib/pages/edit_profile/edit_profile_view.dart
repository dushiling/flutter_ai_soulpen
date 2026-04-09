import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common_button.dart';
import 'edit_profile_logic.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(EditProfileLogic());
    return Scaffold(
      appBar: AppBar(title: const Text('编辑个人信息'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Obx(() {
          final s = logic.state.value;
          return Column(
            children: [
              GestureDetector(
                onTap: logic.pickImage,
                child: s.avatar.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                        child: CircleAvatar(
                          radius: 56.r,
                          backgroundColor: AppColors.primary,
                          backgroundImage: FileImage(File(s.avatar)),
                        ),
                      )
                    : CircleAvatar(
                        radius: 56.r,
                        backgroundColor: AppColors.primaryDeep,
                        child: Icon(Icons.person, size: 52, color: Colors.white),
                      ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: logic.pickImage,
                child: Text(
                  '更换头像',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primaryDeep,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: TextEditingController(text: s.nickname)
                  ..selection = TextSelection.collapsed(offset: s.nickname.length),
                onChanged: (v) => logic.state.update((st) => st?.nickname = v),
                decoration: InputDecoration(
                  labelText: '昵称',
                  hintText: '请输入昵称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: CommonButton(text: '保存', onTap: logic.save),
              ),
            ],
          );
        }),
      ),
    );
  }
}
