import 'package:get/get.dart';

import '../../core/utils/hive_util.dart';
import '../../core/utils/toast_util.dart';
import 'copy_setting_state.dart';

class CopySettingLogic extends GetxController {
  final state = CopySettingState().obs;
  
  final scenes = ['朋友圈', '小红书', '微博', '头像签名'];
  final styles = ['高冷拽酷', '温柔治愈', '搞笑沙雕', '极简短句', '文艺清新', '元气可爱'];
  final lengthOptions = [
    {'key': 'short', 'label': '短句（10-30字）'},
    {'key': 'medium', 'label': '中等（30-80字）'},
    {'key': 'long', 'label': '长文（80字以上）'},
  ];
  final qualityOptions = [
    {'key': 'fast', 'label': '快速'},
    {'key': 'standard', 'label': '标准'},
    {'key': 'high', 'label': '高质量'},
  ];
  final historyOptions = [
    {'key': '7', 'label': '7天'},
    {'key': '30', 'label': '30天'},
    {'key': 'forever', 'label': '永久'},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final savedStyles = HiveUtil.getDefaultStyles();
    state.update((s) {
      s?.scene = HiveUtil.getDefaultScene();
      s?.styles = savedStyles.isEmpty ? ['温柔治愈'] : savedStyles;
      s?.lengthPreference = HiveUtil.getLengthPreference();
      s?.autoAddEmoji = HiveUtil.getAutoAddEmoji();
      s?.autoAddTags = HiveUtil.getAutoAddTags();
      s?.autoSaveHistory = HiveUtil.getAutoSaveHistory();
      s?.historyRetention = HiveUtil.getHistoryRetention();
      s?.generateQuality = HiveUtil.getGenerateQuality();
      s?.generateCount = HiveUtil.getGenerateCount();
    });
  }

  void toggleStyle(String style) {
    state.update((s) {
      if (s!.styles.contains(style)) {
        s.styles.remove(style);
      } else {
        s.styles.add(style);
      }
    });
  }

  Future<void> save() async {
    if (state.value.styles.isEmpty) {
      ToastUtil.show('请至少选择一种风格');
      return;
    }
    
    await HiveUtil.setDefaultScene(state.value.scene);
    await HiveUtil.setDefaultStyles(state.value.styles);
    await HiveUtil.setLengthPreference(state.value.lengthPreference);
    await HiveUtil.setAutoAddEmoji(state.value.autoAddEmoji);
    await HiveUtil.setAutoAddTags(state.value.autoAddTags);
    await HiveUtil.setAutoSaveHistory(state.value.autoSaveHistory);
    await HiveUtil.setHistoryRetention(state.value.historyRetention);
    await HiveUtil.setGenerateQuality(state.value.generateQuality);
    await HiveUtil.setGenerateCount(state.value.generateCount);
    
    ToastUtil.show('保存成功');
    Get.back();
  }
}
