import 'package:award_management_system/common/index.dart';
import 'package:award_management_system/common/utils/file_util.dart';
import 'package:award_management_system/common/utils/shared_preferences_util.dart';
import 'package:award_management_system/pages/index.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:get/get.dart';

class SecurityCenterController extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  void updateUserName() async {
    if (userNameController.text.isEmpty) {
      IconSnackBar.show(Get.context!,
          snackBarType: SnackBarType.alert, label: '用户名不能为空');
    } else {
      if (await HttpRequestUtil.boolPost(
              endpoint: '/user/updateUserName',
              parameters: {'userName': userNameController.text},
              optionFailCallback: (String failCode) {})) {
        SharedPreferencesUtil.saveString('userName', userNameController.text);
        Get.find<MainController>().updateUserName();
        IconSnackBar.show(Get.context!,
            snackBarType: SnackBarType.success, label: '修改成功');
      } else {
        IconSnackBar.show(Get.context!,
            snackBarType: SnackBarType.fail, label: '修改失败');
      }
    }
  }

  void updatePassword() async {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty) {
      IconSnackBar.show(Get.context!,
          snackBarType: SnackBarType.alert, label: '密码不能为空');
    } else {
      if (await HttpRequestUtil.boolPost(
              endpoint: '/user/updatePassword',
              parameters: {
                'oldPassword': oldPasswordController.text,
                'newPassword': newPasswordController.text
              },
              optionFailCallback: (String failCode) {})) {
        IconSnackBar.show(Get.context!,
            snackBarType: SnackBarType.success, label: '修改成功');
      } else {
        IconSnackBar.show(Get.context!,
            snackBarType: SnackBarType.fail, label: '修改失败');
      }
    }
  }

  void updateAvatar() async {
    PlatformFile? file =
        await FileUtil.pickFile(allowedExtensions: ['jpg', 'png', 'jpeg']);
    if (file != null) {
      if (await HttpRequestUtil.boolPostFile(
          endpoint: '/user/uploadAvatar',
          parameters: {},
          optionFailCallback: (String failCode) {},
          filePath: file.path!)) {
        IconSnackBar.show(Get.context!,
            snackBarType: SnackBarType.success, label: '上传成功，下次登录时生效');
      } else {
        IconSnackBar.show(Get.context!,
            snackBarType: SnackBarType.fail, label: '上传失败，下次登录时生效');
      }
    }
  }
}
