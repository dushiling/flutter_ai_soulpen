import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/copy_card.dart';
import '../../widgets/empty_widget.dart';
import 'history_logic.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(HistoryLogic());
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Get.defaultDialog(
              title: '清空历史',
              middleText: '确认清空历史记录吗？',
              onConfirm: () {
                Get.back();
                logic.clear();
              },
              textConfirm: '确认',
              textCancel: '取消',
            ),
            child: const Text('清空历史'),
          )
        ],
      ),
      body: Obx(() {
        final list = logic.state.value.list;
        if (list.isEmpty) return const Center(child: EmptyWidget(text: '暂无历史记录'));
        return ListView.separated(
          padding: EdgeInsets.all(16.w).copyWith(
            bottom: MediaQuery.of(context).padding.bottom + 20.w,
          ),
          itemCount: list.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (_, i) {
            final item = list[i];
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => logic.deleteAt(i),
              background: Container(color: Colors.redAccent),
              child: CopyCard(model: item, showTime: true, onTap: () => logic.openDetail(item)),
            );
          },
        );
      }),
    );
  }
}
