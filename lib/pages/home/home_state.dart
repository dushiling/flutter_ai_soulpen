class HomeState {
  String input = '';
  String selectedScene = '朋友圈';
  List<String> selectedStyles = ['温柔治愈'];
  bool loading = false;
  String result = '';
  List<String> dialogResults = []; // 弹窗显示的文案列表
  int currentResultIndex = 0; // 当前选中的文案索引
  List<bool> isFavorites = []; // 每条文案是否已收藏
  bool showResultDialog = false; // 是否显示结果弹窗
  bool isInputFocused = false; // 输入框是否获得焦点
}
