import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common_button.dart';
import 'copy_detail_logic.dart';

class CopyDetailView extends StatelessWidget {
  const CopyDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(CopyDetailLogic());
    return Scaffold(
      appBar: AppBar(title: const Text('文案详情'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.w).copyWith(
          bottom: MediaQuery.of(context).padding.bottom + 20.w,
        ),
        child: Obx(() {
          final model = logic.state.value.model;
          if (model == null) return const SizedBox.shrink();
          return Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onDoubleTap: () async {
                    final ctl = TextEditingController(text: model.content);
                    await Get.defaultDialog(
                      title: '编辑文案',
                      content: TextField(controller: ctl, maxLines: 5),
                      textConfirm: '保存',
                      textCancel: '取消',
                      onConfirm: () {
                        model.content = ctl.text;
                        logic.state.refresh();
                        Get.back();
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Text(model.content, style: TextStyle(fontSize: 18.sp)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(child: CommonButton(text: '复制', onTap: logic.copyText)),
                  SizedBox(width: 10.w),
                  Expanded(child: CommonButton(text: model.isFavorite ? '取消收藏' : '收藏', onTap: logic.toggleFavorite)),
                ],
              ),
              SizedBox(height: 10.h),
              CommonButton(text: '生成卡片', onTap: logic.goCard),
            ],
          );
        }),
      ),
    );
  }
}
