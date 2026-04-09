
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common_button.dart';
import 'card_create_logic.dart';
import 'card_create_state.dart';

class CardCreateView extends StatelessWidget {
  const CardCreateView({super.key});

  // 获取背景图片
  ImageProvider _getBackgroundImage(CardCreateState s) {
    if (s.customImage != null) {
      return FileImage(s.customImage!);
    }
    if (s.networkBackgroundImage.isNotEmpty) {
      return NetworkImage(s.networkBackgroundImage);
    }
    return AssetImage(s.backgroundImage.isNotEmpty ? s.backgroundImage : 'assets/images/style_1.png');
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(CardCreateLogic());
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('生成文案卡片'),
            centerTitle: true,
            actions: [
              // AI按钮
              GestureDetector(
                onTap: logic.toggleAIDialog,
                child: Container(
                  margin: EdgeInsets.only(right: 16.w),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDeep,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'AI',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w).copyWith(
              bottom: MediaQuery.of(context).padding.bottom + 20.w,
            ),
            child: Obx(() {
              final s = logic.state.value;
              return Column(
                children: [
                  RepaintBoundary(
                    key: logic.key,
                    child: Container(
                      width: 300.w,
                      height: 470.h,
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2230),
                        borderRadius: BorderRadius.circular(24.r),
                        image: DecorationImage(
                          image: _getBackgroundImage(s),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // 恢复默认按钮 - 左上角（仅在选择过自定义图片或AI生成图片时显示，保存时隐藏）
                          if (!s.hideUIForCapture && (s.customImage != null || s.networkBackgroundImage.isNotEmpty))
                            Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: logic.restoreDefaultBackground,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '恢复默认',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // 编辑按钮 - 右上角（保存时隐藏）
                          if (!s.hideUIForCapture)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: logic.pickImageFromGallery,
                                child: Container(
                                  width: 32.w,
                                  height: 32.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16.w,
                                    color: const Color(0xFF1F2230),
                                  ),
                                ),
                              ),
                            ),
                          // 内容区域 - 支持拖拽、缩放和旋转（仅在本地图片时）
                          if (s.showText && !s.hideUIForCapture)
                            Positioned.fill(
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  // 只有本地图片时才允许拖拽
                                  if (s.customImage == null && s.networkBackgroundImage.isEmpty) {
                                    logic.updateTextPosition(details.delta);
                                  }
                                },
                                child: Center(
                                  child: Transform.translate(
                                    offset: s.textPosition,
                                    child: _TextTransformWidget(
                                      rotation: s.textRotation,
                                      scale: s.textScale,
                                      onTransformUpdate: (rotation, scale) {
                                        logic.updateTextRotation(rotation);
                                        logic.updateTextScale(scale);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(16.w),
                                        child: Text(
                                          s.content,
                                          style: TextStyle(fontSize: 26.sp, color: s.textColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // 保存时的静态文字（不带交互）
                          if (s.showText && s.hideUIForCapture)
                            Center(
                              child: Transform.translate(
                                offset: s.textPosition,
                                child: Transform.rotate(
                                  angle: s.textRotation,
                                  child: Transform.scale(
                                    scale: s.textScale,
                                    child: Container(
                                      padding: EdgeInsets.all(16.w),
                                      child: Text(
                                        s.content,
                                        style: TextStyle(fontSize: 26.sp, color: s.textColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 10.w,
                    children: logic.colors
                        .map(
                          (e) => InkWell(
                            onTap: () => logic.changeColor(e),
                            child: CircleAvatar(
                              radius: 16.r,
                              backgroundColor: e,
                              child: s.textColor == e ? const Icon(Icons.check, size: 16) : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(child: CommonButton(text: '保存', onTap: logic.save, filled: false)),
                      SizedBox(width: 12.w),
                      Expanded(child: CommonButton(text: '分享', onTap: logic.share)),
                    ],
                  )
                ],
              );
            }),
          ),
        ),
        // AI生成图片弹窗
        Obx(() {
          final s = logic.state.value;
          if (s.showAIDialog) {
            return Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                    margin: EdgeInsets.all(20.w),
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 标题
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text('选择文字类型', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.none)),
                              ),
                            ),
                            GestureDetector(
                              onTap: logic.toggleAIDialog,
                              child: Icon(Icons.close, size: 24.w),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        
                        // 内容区域
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 传统书法与国潮风
                              _buildOptionSection(
                                title: '传统书法与国潮风',
                                options: logic.fontOptions['传统书法与国潮风'] ?? [],
                                selectedOptions: s.selectedFonts,
                                onSelect: logic.selectFont,
                                singleSelect: true,
                              ),
                              SizedBox(height: 16.h),
                              
                              // 现代与艺术创意风
                              _buildOptionSection(
                                title: '现代与艺术创意风',
                                options: logic.fontOptions['现代与艺术创意风'] ?? [],
                                selectedOptions: s.selectedFonts,
                                onSelect: logic.selectFont,
                                singleSelect: true,
                              ),
                              SizedBox(height: 16.h),
                              
                              // 材质与特效风格
                              _buildOptionSection(
                                title: '材质与特效风格',
                                options: logic.materialOptions,
                                selectedOptions: [s.selectedMaterial],
                                onSelect: logic.selectMaterial,
                                singleSelect: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        
                        // 确定按钮
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: CommonButton(
                            text: s.isGeneratingImage ? '生成中...' : '确定',
                            onTap: s.isGeneratingImage ? null : logic.generateAIImage,
                            filled: true,
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
    );
  }
  
  // 构建选项组
  Widget _buildOptionSection({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String) onSelect,
    bool singleSelect = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.none)),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          alignment: WrapAlignment.start,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return GestureDetector(
              onTap: () => onSelect(option),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryDeep : AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Colors.white : AppColors.textMain,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// 文字变换组件 - 支持双指缩放和旋转
class _TextTransformWidget extends StatefulWidget {
  final double rotation;
  final double scale;
  final Function(double rotation, double scale) onTransformUpdate;
  final Widget child;

  const _TextTransformWidget({
    required this.rotation,
    required this.scale,
    required this.onTransformUpdate,
    required this.child,
  });

  @override
  State<_TextTransformWidget> createState() => _TextTransformWidgetState();
}

class _TextTransformWidgetState extends State<_TextTransformWidget> {
  double _baseRotation = 0.0;
  double _baseScale = 1.0;
  int _pointerCount = 0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() {
          _pointerCount++;
        });
      },
      onPointerUp: (_) {
        setState(() {
          _pointerCount--;
          if (_pointerCount <= 0) {
            _pointerCount = 0;
            // 重置基准值
            _baseRotation = widget.rotation;
            _baseScale = widget.scale;
          }
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: (details) {
          _baseRotation = widget.rotation;
          _baseScale = widget.scale;
        },
        onScaleUpdate: (details) {
          // 双指操作时更新旋转和缩放
          if (details.pointerCount >= 2) {
            final newRotation = _baseRotation + details.rotation;
            final newScale = (_baseScale * details.scale).clamp(0.5, 3.0);
            widget.onTransformUpdate(newRotation, newScale);
          }
        },
        child: Transform.rotate(
          angle: widget.rotation,
          child: Transform.scale(
            scale: widget.scale,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
