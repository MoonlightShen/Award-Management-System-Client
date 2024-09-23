import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'index.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
      id: "login",
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 236, 240, 243),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: MoveWindow(),
                      ),
                      Wrap(
                        spacing: 20,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () => appWindow.minimize(),
                                  icon: const Icon(Icons.remove)),
                              IconButton(
                                  onPressed: () {
                                    if (!controller.maximize) {
                                      appWindow.maximize();
                                      controller.maximize = true;
                                    } else {
                                      appWindow.restore();
                                      controller.maximize = false;
                                    }
                                  },
                                  icon: const Icon(Icons.fit_screen_outlined)),
                              IconButton(
                                  onPressed: () => appWindow.close(),
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 800,
                      height: 500,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 236, 240, 243),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.white,
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              '登录',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: SizedBox(
                              width: 300,
                              child: Obx(() => TextField(
                                    controller: controller.passwordController,
                                    obscureText: controller.hidePassword.value,
                                    focusNode: controller.focusNode,
                                    decoration: InputDecoration(
                                        hintText: '请输入密码',
                                        border: const OutlineInputBorder(),
                                        prefixIcon: const Icon(Icons.password),
                                        suffixIcon: controller
                                                .focusPassword.value&&controller.password.isNotEmpty
                                            ? Padding(
                                              padding: const EdgeInsets.only(right: 4),
                                              child: IconButton(
                                                  onPressed: () {
                                                    controller.hidePassword.value = !controller.hidePassword.value;
                                                  },
                                                  icon: controller
                                                          .hidePassword.value
                                                      ? const Icon(Icons
                                                          .visibility_off_outlined)
                                                      : const Icon(Icons
                                                          .visibility_outlined)),
                                            )
                                            : null),
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: SizedBox(
                              width: 300,
                              child: ElevatedButton(
                                onPressed: () async {
                                  controller.login();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 75, 112, 226),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text(
                                    '登录',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
