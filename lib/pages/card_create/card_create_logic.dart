import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../api/qwen_image_api.dart';
import '../../core/utils/toast_util.dart';
import 'card_create_state.dart';

class CardCreateLogic extends GetxController {
  final state = CardCreateState().obs;
  final key = GlobalKey();

  final colors = const [Color(0xFFE9E0F8), Color(0xFFFFE4F1), Color(0xFFE6F2FF), Color(0xFFFFFFFF),Color(0xFF333333)];

  // 风格与背景图片的映射关系
  final Map<String, String> styleImageMap = {
    '高冷拽酷': 'assets/images/style_1.png',
    '温柔治愈': 'assets/images/style_2.png',
    '搞笑沙雕': 'assets/images/style_3.png',
    '极简短句': 'assets/images/style_4.png',
    '文艺清新': 'assets/images/style_5.png',
    '元气可爱': 'assets/images/style_6.png',
    '伤感 emo': 'assets/images/style_7.png',
    '励志上进': 'assets/images/style_8.png',
    '颜文字': 'assets/images/style_9.png',
  };

  // AI生成图片的选项数据
  final Map<String, List<String>> fontOptions = {
    '传统书法与国潮风': ['瘦金体', '小楷/行楷', '狂草/行书', '隶书/篆书', '毛笔书法'],
    '现代与艺术创意风': ['黑体', '宋体', '哥特体', '未来感/科幻字体', '泡泡字/卡通体'],
  };

  final List<String> materialOptions = [
    '3D立体/充气感', '金属质感', '毛绒/羊毛毡', '木纹', '水墨/宣纸',
    '玉石/水晶/玻璃', '霓虹灯', '浮雕/压印'
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    state.update((s) {
      s?.content = args['content'] as String? ?? '年轻化清新感卡片设计';
      s?.style = args['style'] as String? ?? '';
      // 根据风格设置对应的背景图片
      s?.backgroundImage = _getBackgroundImageByStyle(s.style ?? '');
      // 保存初始背景图片
      s?.initialBackgroundImage = s.backgroundImage ?? '';
    });
  }

  // 根据风格获取对应的背景图片
  String _getBackgroundImageByStyle(String style) {
    return styleImageMap[style] ?? 'assets/images/style_1.png';
  }

  void changeColor(Color c) => state.update((s) => s?.textColor = c);

  // 更新文字位置
  void updateTextPosition(Offset delta) {
    state.update((s) {
      s?.textPosition = Offset(
        s.textPosition.dx + delta.dx,
        s.textPosition.dy + delta.dy,
      );
    });
  }

  // 更新文字旋转角度
  void updateTextRotation(double rotation) {
    state.update((s) => s?.textRotation = rotation);
  }

  // 更新文字缩放比例
  void updateTextScale(double scale) {
    state.update((s) => s?.textScale = scale);
  }

  // 恢复默认背景图
  void restoreDefaultBackground() {
    state.update((s) {
      s?.customImage = null;
      s?.networkBackgroundImage = '';
      s?.backgroundImage = s.initialBackgroundImage ?? '';
      s?.showText = true;
      s?.textPosition = const Offset(0, 0);
      s?.textRotation = 0.0;
      s?.textScale = 1.0;
    });
  }

  // 显示/隐藏AI弹窗
  void toggleAIDialog() => state.update((s) => s?.showAIDialog = !s.showAIDialog);

  // 字体冲突检测
  bool _hasFontConflict(String newFont, List<String> currentFonts) {
    // 传统书法与国潮风字体列表
    final traditionalFonts = fontOptions['传统书法与国潮风'] ?? [];
    // 现代与艺术创意风字体列表
    final modernFonts = fontOptions['现代与艺术创意风'] ?? [];
    
    // 检查是否与已选字体存在冲突
    for (final font in currentFonts) {
      // 传统与现代字体冲突 - 风格差异过大，不建议同时使用
      if ((traditionalFonts.contains(newFont) && modernFonts.contains(font)) ||
          (modernFonts.contains(newFont) && traditionalFonts.contains(font))) {
        return true;
      }
    }
    return false;
  }

  // 选择字体风格
  void selectFont(String font) {
    state.update((s) {
      if (s == null) return;
      
      // 检查是否已选中
      if (s.selectedFonts.contains(font)) {
        // 取消选中
        s.selectedFonts.remove(font);
        return;
      }
      
      // 检查选中数量限制
      if (s.selectedFonts.length >= 2) {
        ToastUtil.show('最多只能选择2个字体风格');
        return;
      }
      
      // 检查字体冲突
      if (_hasFontConflict(font, s.selectedFonts)) {
        ToastUtil.show('所选字体风格存在冲突，请重新选择');
        return;
      }
      
      // 检查是否同一分类下已经有选择
      final traditionalFonts = fontOptions['传统书法与国潮风'] ?? [];
      final modernFonts = fontOptions['现代与艺术创意风'] ?? [];
      
      if (traditionalFonts.contains(font)) {
        // 如果选择的是传统书法与国潮风，移除该分类下的其他选择
        s.selectedFonts.removeWhere((f) => traditionalFonts.contains(f));
      } else if (modernFonts.contains(font)) {
        // 如果选择的是现代与艺术创意风，移除该分类下的其他选择
        s.selectedFonts.removeWhere((f) => modernFonts.contains(f));
      }
      
      s.selectedFonts.add(font);
    });
  }

  // 选择材质风格
  void selectMaterial(String material) {
    state.update((s) => s?.selectedMaterial = material);
  }

  // AI生成图片
  Future<void> generateAIImage() async {
    final s = state.value;
    
    // 验证选择
    if (s.selectedFonts.isEmpty) {
      ToastUtil.show('请至少选择一个字体风格');
      return;
    }
    if (s.selectedFonts.length > 2) {
      ToastUtil.show('最多只能选择2个字体风格');
      return;
    }
    if (s.selectedMaterial.isEmpty) {
      ToastUtil.show('请选择一个材质风格');
      return;
    }

    state.update((s) => s?.isGeneratingImage = true);
    
    try {
      final qwenService = QwenImageService();
      
      // 拼接字体风格
      final textStyle = s.selectedFonts.join('、');
      
      // 准备风格参数
      final styles = s.style.isNotEmpty ? [s.style] : ['现代风格'];
      
      // 调用API生成图片
      final imageUrl = await qwenService.generateImage(
        input: s.content,
        styles: styles,
        textStyle: textStyle,
        material: s.selectedMaterial,
      );
      
      if (imageUrl != null) {
        // 替换背景图并隐藏文字
        state.update((s) {
          s?.customImage = null;
          s?.networkBackgroundImage = imageUrl;
          s?.showAIDialog = false;
          s?.showText = false;
        });
        ToastUtil.show('图片生成成功');
      } else {
        ToastUtil.show('图片生成失败，请重试');
      }
    } catch (e) {
      print('生成图片失败: $e');
      ToastUtil.show('生成图片失败，请重试');
    } finally {
      state.update((s) => s?.isGeneratingImage = false);
    }
  }

  // 从相册选择图片
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1800,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        state.update((s) => s?.customImage = File(pickedFile.path));
      }
    } catch (e) {
      ToastUtil.show('选择图片失败');
    }
  }

  Future<Uint8List?> _capture() async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> save() async {
    // 请求存储权限
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        ToastUtil.show('需要存储权限才能保存图片');
        return;
      }
    }

    // 隐藏UI元素
    state.update((s) => s?.hideUIForCapture = true);
    
    // 等待UI更新
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _capture();
    
    // 恢复UI元素
    state.update((s) => s?.hideUIForCapture = false);
    
    if (bytes == null) {
      ToastUtil.show('保存失败');
      return;
    }
    final saver = ImageGallerySaver();
    await saver.saveImage(bytes);
    ToastUtil.show('保存成功');
  }

  Future<void> share() async {
    final bytes = await _capture();
    if (bytes == null) {
      ToastUtil.show('分享失败');
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/soulpen_share.png');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }
}
