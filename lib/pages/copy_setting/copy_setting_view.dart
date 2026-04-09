import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common_button.dart';
import 'copy_setting_logic.dart';
import 'copy_setting_state.dart';

class CopySettingView extends StatelessWidget {
  const CopySettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(CopySettingLogic());
    return Scaffold(
      appBar: AppBar(title: const Text('文案设置'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.w).copyWith(
          bottom: MediaQuery.of(context).padding.bottom + 20.w,
        ),
        child: Obx(() {
          final s = logic.state.value;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('默认发布场景'),
                _buildSceneSelector(logic, s),
                SizedBox(height: 24.h),
                _buildSectionTitle('默认文案风格（多选）'),
                _buildStyleSelector(logic, s),
                SizedBox(height: 24.h),
                _buildSectionTitle('文案长度偏好'),
                _buildLengthSelector(logic, s),
                SizedBox(height: 24.h),
                _buildSectionTitle('风格增强'),
                _buildEnhancementOptions(logic, s),
                SizedBox(height: 24.h),
                _buildSectionTitle('历史记录设置'),
                _buildHistoryOptions(logic, s),
                SizedBox(height: 24.h),
                _buildSectionTitle('AI生成设置'),
                _buildGenerateOptions(logic, s),
                SizedBox(height: 40.h),
                CommonButton(text: '保存设置', onTap: logic.save),
                SizedBox(height: 20.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
      ),
    );
  }

  Widget _buildSceneSelector(CopySettingLogic logic, CopySettingState s) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: logic.scenes.map((scene) {
        final isSelected = s.scene == scene;
        return _buildOptionChip(
          label: scene,
          isSelected: isSelected,
          onTap: () => logic.state.update((st) => st?.scene = scene),
        );
      }).toList(),
    );
  }

  Widget _buildStyleSelector(CopySettingLogic logic, CopySettingState s) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: logic.styles.map((style) {
        final isSelected = s.styles.contains(style);
        return _buildOptionChip(
          label: style,
          isSelected: isSelected,
          onTap: () => logic.toggleStyle(style),
        );
      }).toList(),
    );
  }

  Widget _buildLengthSelector(CopySettingLogic logic, CopySettingState s) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: logic.lengthOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        // 如果没有选择任何选项，默认选中第一个
        final isSelected = s.lengthPreference == option['key'] || 
                          (s.lengthPreference.isEmpty && index == 0);
        return _buildOptionChip(
          label: option['label']!,
          isSelected: isSelected,
          onTap: () => logic.state.update((st) => st?.lengthPreference = option['key']!),
        );
      }).toList(),
    );
  }

  Widget _buildEnhancementOptions(CopySettingLogic logic, CopySettingState s) {
    return Column(
      children: [
        _buildSwitchTile(
          title: '自动添加Emoji',
          subtitle: '让文案更生动有趣',
          value: s.autoAddEmoji,
          onChanged: (v) => logic.state.update((st) => st?.autoAddEmoji = v),
        ),
        _buildSwitchTile(
          title: '自动添加话题标签',
          subtitle: '添加 #话题 提高曝光',
          value: s.autoAddTags,
          onChanged: (v) => logic.state.update((st) => st?.autoAddTags = v),
        ),
      ],
    );
  }

  Widget _buildHistoryOptions(CopySettingLogic logic, CopySettingState s) {
    return Column(
      children: [
        _buildSwitchTile(
          title: '自动保存历史记录',
          subtitle: '保存每次生成的文案',
          value: s.autoSaveHistory,
          onChanged: (v) => logic.state.update((st) => st?.autoSaveHistory = v),
        ),
        SizedBox(height: 12.h),
        if (s.autoSaveHistory)
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Text('保留时长：', style: TextStyle(fontSize: 14.sp, color: AppColors.textMain)),
                const Spacer(),
                DropdownButton<String>(
                  value: s.historyRetention,
                  underline: const SizedBox(),
                  items: logic.historyOptions.map((option) {
                    return DropdownMenuItem(
                      value: option['key'],
                      child: Text(option['label']!),
                    );
                  }).toList(),
                  onChanged: (v) => logic.state.update((st) => st?.historyRetention = v!),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGenerateOptions(CopySettingLogic logic, CopySettingState s) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text('生成质量：', style: TextStyle(fontSize: 14.sp, color: AppColors.textMain)),
                  const Spacer(),
                  DropdownButton<String>(
                    value: s.generateQuality,
                    underline: const SizedBox(),
                    items: logic.qualityOptions.map((option) {
                      return DropdownMenuItem(
                        value: option['key'],
                        child: Text(option['label']!),
                      );
                    }).toList(),
                    onChanged: (v) => logic.state.update((st) => st?.generateQuality = v!),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text('生成条数：', style: TextStyle(fontSize: 14.sp, color: AppColors.textMain)),
                  const Spacer(),
                  Row(
                    children: [1, 2, 3].map((count) {
                      final isSelected = s.generateCount == count;
                      return GestureDetector(
                        onTap: () => logic.state.update((st) => st?.generateCount = count),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryDeep : AppColors.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '$count条',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textMain,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDeep : AppColors.primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected ? Border.all(color: AppColors.primaryDeep, width: 1.w) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMain,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                Text(subtitle, style: TextStyle(fontSize: 13.sp, color: AppColors.textSub)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryDeep,
          ),
        ],
      ),
    );
  }
}
