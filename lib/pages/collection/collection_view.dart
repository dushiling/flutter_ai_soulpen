import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/copy_card.dart';
import '../../widgets/empty_widget.dart';
import 'collection_logic.dart';

class CollectionView extends StatelessWidget {
  const CollectionView({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 tag 注册，确保全局唯一
    final logic = Get.put(CollectionLogic(), tag: 'collection', permanent: true);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Obx(() {
            final list = logic.state.value.list;
            return Column(
              children: [
                Row(
                  children: [
                    Text('我的收藏', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40.sp)),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => Get.defaultDialog(
                        title: '清空收藏',
                        middleText: '确认清空全部收藏吗？',
                        textConfirm: '确认',
                        textCancel: '取消',
                        onConfirm: () {
                          Get.back();
                          logic.clearAll();
                        },
                      ),
                      child: const Text('清空收藏'),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: EmptyWidget(text: '还没有收藏的文案，快去生成收藏吧'))
                      : GridView.builder(
                          itemCount: list.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            childAspectRatio: 0.95,
                          ),
                          itemBuilder: (_, i) {
                            final item = list[i];
                            return Dismissible(
                              key: Key(item.id),
                              background: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => logic.deleteAt(i),
                              child: CopyCard(model: item, onTap: () => logic.openDetail(item)),
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
