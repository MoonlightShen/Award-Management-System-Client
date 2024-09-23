import 'dart:io';

import 'package:award_management_system/common/models/award_category.dart';
import 'package:award_management_system/common/utils/file_util.dart';
import 'package:award_management_system/common/utils/http_request_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:get/get.dart';

import 'index.dart';

class AwardCategoryPage extends GetView<AwardCategoryController> {
  const AwardCategoryPage({super.key});

  void addAwardCategory() {
    TextEditingController awardCategoryNameController = TextEditingController();
    var hasAwardLevel = RxBool(false);
    var file = Rxn<PlatformFile>();
    Get.dialog(
      AlertDialog(
        title: const Text('添加奖励种类'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('种类名称'),
                const SizedBox(
                  width: 16,
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: awardCategoryNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('该奖励有等级划分'),
                const SizedBox(
                  width: 16,
                ),
                Obx(() => Checkbox(
                    value: hasAwardLevel.value,
                    onChanged: (value) => hasAwardLevel.value = value ?? false)),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('图标'),
                const SizedBox(
                  width: 16,
                ),
                IconButton(
                    onPressed: () async {
                      file.value = await FileUtil.pickFile();
                    },
                    icon: const Icon(Icons.upload_file)),
                const SizedBox(
                  width: 16,
                ),
                Obx(() => file.value != null
                    ? SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.file(File(file.value!.path!)),
                      )
                    : Container())
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              bool result = await HttpRequestUtil.boolPost(
                  endpoint: '/awardCategory/insert',
                  parameters: {
                    "awardCategoryName": awardCategoryNameController.text,
                    "hasAwardLevel": hasAwardLevel.value?1:0,
                    "icon": await File(file.value!.path!).readAsBytes()
                  });
              if (result) {
                IconSnackBar.show(Get.context!,
                    snackBarType: SnackBarType.success, label: '添加成功');
              } else {
                IconSnackBar.show(Get.context!,
                    snackBarType: SnackBarType.fail, label: '添加失败');
              }
              Get.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AwardCategoryController>(
      init: AwardCategoryController(),
      id: "award_category",
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '成果奖励种类',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: FutureBuilder(
                        future: controller.getAllAwardCategory(),
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
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            List<AwardCategory> awardCategories =
                                snapshot.data!;
                            return ListView.separated(
                              itemBuilder: (context, index) => Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                child: Row(children: [
                                  SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: awardCategories[index].icon != null
                                        ? Image.memory(
                                            awardCategories[index].icon!)
                                        : Container(),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        awardCategories[index]
                                            .awardCategoryName,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                              value: awardCategories[index]
                                                  .hasAwardLevel,
                                              onChanged: null),
                                          Text('奖励分级')
                                        ],
                                      )
                                    ],
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                              color: Color.fromARGB(
                                                  255, 113, 142, 191),
                                              width: 1),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12)))),
                                      child: const Text('编辑')),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                ]),
                              ),
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                  height: 20,
                                );
                              },
                              itemCount: awardCategories.length,
                            );
                          }
                          return Container();
                        }),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: addAwardCategory,
            backgroundColor: Colors.white,
            tooltip: '添加新种类',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
