import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CardCreateState {
  String content = '';
  Color bg = const Color(0xFFE9E0F8);
  Color textColor = AppColors.textMain; // 文字颜色
  String style = ''; // 风格标签
  String backgroundImage = ''; // 背景图片路径（本地资源）
  String networkBackgroundImage = ''; // 网络背景图片路径
  String initialBackgroundImage = ''; // 初始背景图片路径
  File? customImage; // 用户选择的自定义图片
  
  // AI生成图片相关
  bool showAIDialog = false; // 是否显示AI弹窗
  List<String> selectedFonts = []; // 选中的字体风格
  String selectedMaterial = ''; // 选中的材质风格
  bool isGeneratingImage = false; // 是否正在生成图片
  bool showText = true; // 是否显示文字
  
  // 文字位置、旋转和缩放
  Offset textPosition = const Offset(0, 0); // 文字位置偏移
  double textRotation = 0.0; // 文字旋转角度（弧度）
  double textScale = 1.0; // 文字缩放比例
  
  // 保存时隐藏UI元素
  bool hideUIForCapture = false; // 保存时是否隐藏UI元素
}
