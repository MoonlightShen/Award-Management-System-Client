import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:award_management_system/common/utils/shared_preferences_util.dart';

class MainController extends GetxController {
  bool maximize = false;

  var userName = ''.obs;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void openEndDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  void closeEndDrawer() {
    scaffoldKey.currentState?.closeEndDrawer();
  }

  void updateUserName() async {
    userName.value = await SharedPreferencesUtil.getString('userName')??'';
  }

  @override
  void onInit() {
    updateUserName();
    super.onInit();
  }

}
