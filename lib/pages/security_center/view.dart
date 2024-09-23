import 'dart:typed_data';

import 'package:award_management_system/common/utils/http_request_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index.dart';

class SecurityCenterPage extends GetView<SecurityCenterController> {
  const SecurityCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SecurityCenterController>(
      init: SecurityCenterController(),
      id: "security_center",
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: HttpRequestUtil.imagePost(
                          endpoint: '/user/getAvatar'),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              '加载失败',
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          Uint8List data = snapshot.data!;
                          return IconButton(
                            onPressed: controller.updateAvatar,
                            icon: SizedBox(
                              width: 120,
                              height: 120,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(120),
                                  child: Image.memory(data),
                                ),
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                    const SizedBox(
                      width: 32,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '用户名',
                          style: TextStyle(fontSize: 22),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: controller.userNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          width: 300,
                          child: Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                onPressed: controller.updateUserName,
                                child: const Text(
                                  '保存',
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        const Text(
                          '修改密码',
                          style: TextStyle(fontSize: 22),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text(
                          '当前密码',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: controller.oldPasswordController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text(
                          '新密码',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: controller.newPasswordController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          width: 300,
                          child: Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                onPressed: controller.updatePassword,
                                child: const Text(
                                  '保存',
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
