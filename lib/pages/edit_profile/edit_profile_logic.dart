import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../../core/utils/hive_util.dart';
import '../../core/utils/toast_util.dart';
import '../../models/user_model.dart';
import 'edit_profile_state.dart';

class EditProfileLogic extends GetxController {
  final state = EditProfileState().obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final user = HiveUtil.getUser();
    state.update((s) {
      s?.nickname = user.nickname;
      s?.avatar = user.avatar;
    });
  }

  Future<void> pickImage() async {
    final result = await Get.dialog(
      AlertDialog(
        title: const Text('选择图片'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final XFile? image = await _picker.pickImage(source: result);
      if (image != null) {
        state.update((s) => s?.avatar = image.path);
      }
    }
  }

  Future<void> save() async {
    final name = state.value.nickname.trim();
    if (name.isEmpty) {
      ToastUtil.show('请输入昵称');
      return;
    }
    await HiveUtil.setUser(UserModel(
      nickname: name,
      avatar: state.value.avatar,
    ));
    ToastUtil.show('保存成功');
    Get.back();
  }
}
