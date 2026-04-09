import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/common_button.dart';
import '../../widgets/loading_widget.dart';
import 'data_manage_logic.dart';

class DataManageView extends StatelessWidget {
  const DataManageView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(DataManageLogic());
    return Scaffold(
      appBar: AppBar(title: const Text('数据管理'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.w).copyWith(
          bottom: MediaQuery.of(context).padding.bottom + 20.w,
        ),
        child: Obx(() {
          final s = logic.state.value;
          return Column(
            children: [
              CommonButton(text: '数据备份', onTap: s.loading ? null : logic.backup),
              SizedBox(height: 10.h),
              Text('备份后文案将导出为JSON文件，保存至手机本地', style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 16.h),
              if (s.loading) const LoadingWidget(text: '处理中...'),
              Expanded(
                child: ListView.builder(
                  itemCount: s.backups.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(s.backups[i].split('/').last),
                    subtitle: Text(s.backups[i], maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: TextButton(
                      onPressed: () => logic.restoreByPath(s.backups[i]),
                      child: const Text('恢复'),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
