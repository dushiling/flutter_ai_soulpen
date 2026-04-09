import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common_button.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/tag_widget.dart';
import 'home_logic.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 permanent: true 防止 HomeLogic 被重建
    final logic = Get.put(HomeLogic(), permanent: true);
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.translucent,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Obx(() {
                  final s = logic.state.value;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                           Row(
                             children: [
                               Text('SoulPen ',
                                   style: TextStyle(fontWeight: FontWeight.w800, fontSize: 32.sp)),
                               Text('社交文案神器',
                                   style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp)),
                             ],
                           ),
                           InkWell(
                             onTap: logic.goHistory,
                             child: Icon(Icons.history,size: 25,color: Colors.black54,),
                           ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGray,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: s.isInputFocused ? AppColors.primaryDeep : AppColors.primary,
                              width: s.isInputFocused ? 2.w : 1.w,
                            ),
                            boxShadow: s.isInputFocused
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryDeep.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 0),
                                    ),
                                  ]
                                : null,
                          ),
                          child: TextField(
                            focusNode: logic.inputFocusNode,
                            controller: logic.inputController,
                            maxLength: 50,
                            maxLines: 3,
                            onChanged: logic.setInput,
                            decoration: InputDecoration(
                              hintText: '输入场景/心情/事件(如:周末看海)',
                              border: InputBorder.none,
                              suffixIcon: IconButton(onPressed: logic.clearInput, icon: const Icon(Icons.close)),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: logic.scenes
                                .map((e) => Padding(
                                      padding: EdgeInsets.only(right: 8.w),
                                      child: TagWidget(
                                        text: e,
                                        selected: s.selectedScene == e,
                                        onTap: () => logic.changeScene(e),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text('风格', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22.sp)),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: logic.styles
                              .map((e) => TagWidget(
                                    text: e,
                                    selected: s.selectedStyles.contains(e),
                                    onTap: () => logic.toggleStyle(e),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 16.h),
                        CommonButton(text: '生成文案', onTap: s.loading ? null : logic.generate),
                        SizedBox(height: 16.h),
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 180.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGray,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          child: s.loading
                              ? const Center(child: LoadingWidget())
                              : s.result.isEmpty
                                  ? const Center(child: EmptyWidget(text: '输入内容，生成你的专属文案吧'))
                                  : Text(s.result, style: TextStyle(fontSize: 18.sp, color: AppColors.textMain)),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          Obx(() {
            final s = logic.state.value;
            if (s.showResultDialog) {
              return Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(32.w),
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: logic.closeResultDialog,
                              child: Icon(Icons.close, size: 24.w, color: Colors.black54),
                            ),
                          ],
                        ),
                        Icon(Icons.auto_awesome, size: 32.w, color: AppColors.primaryDeep),
                        SizedBox(height: 8.h),
                        // 显示多条文案，每条都有独立的操作按钮
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              children: s.dialogResults.asMap().entries.map((entry) {
                                final index = entry.key;
                                final content = entry.value;
                                final isFavorite = index < s.isFavorites.length ? s.isFavorites[index] : false;
                                
                                return Container(
                                  margin: EdgeInsets.only(bottom: 16.h),
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGray,
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 文案序号
                                      if (s.dialogResults.length > 1)
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 8.h),
                                          child: Text(
                                            '文案 ${index + 1}/${s.dialogResults.length}',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: AppColors.textSub,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      // 文案内容
                                      Text(
                                        content,
                                        style: TextStyle(fontSize: 18.sp, color: AppColors.textMain),
                                      ),
                                      SizedBox(height: 12.h),
                                      // 操作按钮
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            onPressed: () => logic.copyResult(index),
                                            icon: const Icon(Icons.copy_outlined),
                                            iconSize: 24.w,
                                            padding: EdgeInsets.all(8.w),
                                            constraints: const BoxConstraints(),
                                          ),
                                          IconButton(
                                            onPressed: () => logic.favoriteResult(index),
                                            icon: Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: isFavorite ? Colors.red : null,
                                            ),
                                            iconSize: 24.w,
                                            padding: EdgeInsets.all(8.w),
                                            constraints: const BoxConstraints(),
                                          ),
                                          IconButton(
                                            onPressed: () => logic.goCardCreate(index),
                                            icon: const Icon(Icons.image_outlined),
                                            iconSize: 24.w,
                                            padding: EdgeInsets.all(8.w),
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
