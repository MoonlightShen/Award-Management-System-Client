import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:get/get.dart';
import 'package:award_management_system/common/index.dart';
import 'package:award_management_system/common/utils/shared_preferences_util.dart';

enum LoginResultStatus {
  unknown(code: '', description: ''),
  accountError(code: '2002', description: '用户不存在'),
  passwordError(code: '2003', description: '密码错误');

  final String code;
  final String description;

  const LoginResultStatus({required this.code, required this.description});

  static LoginResultStatus get(String code) {
    for (LoginResultStatus value in LoginResultStatus.values) {
      if (value.code == code) return value;
    }
    return LoginResultStatus.unknown;
  }
}

class LoginResult {
  final String token;
  final String userName;

  LoginResult({required this.token, required this.userName});

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
        token: json['token'] ?? '',
        userName: json['userName'] ?? '',
      );
}

class LoginController extends GetxController {
  bool maximize = false;
  late TextEditingController passwordController = TextEditingController();
  var hidePassword = true.obs;
  final FocusNode focusNode = FocusNode();
  var focusPassword = false.obs;

  String get password => passwordController.text;

  void login() async {
    LoginResult? loginResult = await HttpRequestUtil.post<LoginResult>(
        endpoint: '/auth/login',
        parameters: {'password': password},
        fromJson: (Map<String, dynamic> jsonData) =>
            LoginResult.fromJson(jsonData),
        optionFailCallback: (String failCode) {});
    if (loginResult != null) {
      Get.offAllNamed(RouteNames.main);
      SharedPreferencesUtil.saveString('userName', loginResult.userName);
      SharedPreferencesUtil.saveString('token', loginResult.token);
      SharedPreferencesUtil.saveString('password', password);
      IconSnackBar.show(Get.context!,
          snackBarType: SnackBarType.success, label: '登陆成功');
    }else{
      IconSnackBar.show(Get.context!,
          snackBarType: SnackBarType.fail, label: '登陆失败');
    }
  }

  @override
  void onInit() async {
    focusNode.addListener(() {
      focusPassword.value = focusNode.hasFocus;
    });
    passwordController.text =
        await SharedPreferencesUtil.getString('password') ?? '';
    super.onInit();
  }

  @override
  void onClose() {
    focusNode.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
