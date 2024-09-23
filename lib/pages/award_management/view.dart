import 'package:award_management_system/common/components/custom_paginated_table.dart';
import 'package:award_management_system/common/models/award.dart';
import 'package:award_management_system/common/models/award_category.dart';
import 'package:award_management_system/common/models/enumeration/award_level.dart';
import 'package:award_management_system/common/models/enumeration/race_level.dart';
import 'package:award_management_system/common/utils/file_util.dart';
import 'package:award_management_system/common/utils/http_request_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'index.dart';

class AwardManagementPage extends GetView<AwardManagementController> {
  const AwardManagementPage({super.key});

  void addAward(Set<AwardCategory> awardCategories) {
    Award award = Award(awardId: -1);
    TextEditingController awardCategoryController = TextEditingController();
    TextEditingController raceLevelController = TextEditingController();
    TextEditingController awardLevelController = TextEditingController();
    TextEditingController rankingController = TextEditingController();
    var hasRanking = RxBool(false);
    TextEditingController awardNameController = TextEditingController();
    var acquisitionTime = RxInt(DateTime.now().millisecondsSinceEpoch);
    var file = Rxn<PlatformFile>();
    Get.dialog(
      AlertDialog(
        title: const Text('添加奖项'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('成果种类'),
                const SizedBox(
                  width: 30,
                ),
                DropdownMenu<AwardCategory>(
                    width: 200,
                    menuHeight: 150,
                    controller: awardCategoryController,
                    onSelected: (value) => award.awardCategory = value,
                    dropdownMenuEntries: awardCategories
                        .map<DropdownMenuEntry<AwardCategory>>(
                            (AwardCategory awardCategory) =>
                                DropdownMenuEntry<AwardCategory>(
                                    value: awardCategory,
                                    label: awardCategory.awardCategoryName))
                        .toList()),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('赛事等级'),
                const SizedBox(
                  width: 30,
                ),
                DropdownMenu<RaceLevel>(
                    width: 200,
                    menuHeight: 150,
                    controller: raceLevelController,
                    onSelected: (value) =>
                        award.raceLevel = value ?? RaceLevel.unknown,
                    dropdownMenuEntries: List.generate(
                        RaceLevel.values.length - 1,
                        (index) => DropdownMenuEntry<RaceLevel>(
                            value: RaceLevel.get(index + 1),
                            label: RaceLevel.get(index + 1).name))),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('成果名称'),
                const SizedBox(
                  width: 30,
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: awardNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('奖项等级'),
                const SizedBox(
                  width: 30,
                ),
                DropdownMenu<AwardLevel>(
                    width: 200,
                    menuHeight: 150,
                    controller: awardLevelController,
                    onSelected: (value) =>
                        award.awardLevel = value ?? AwardLevel.unknown,
                    dropdownMenuEntries: List.generate(
                        AwardLevel.values.length - 1,
                        (index) => DropdownMenuEntry<AwardLevel>(
                            value: AwardLevel.get(index + 1),
                            label: AwardLevel.get(index + 1).name))),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('团队排名'),
                const SizedBox(
                  width: 25,
                ),
                Obx(() => Checkbox(
                    value: hasRanking.value,
                    onChanged: (value) => hasRanking.value = value ?? false)),
                const SizedBox(
                  width: 16,
                ),
                SizedBox(
                  width: 200,
                  child: Obx(() => TextField(
                        controller: rankingController,
                        enabled: hasRanking.value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      )),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('获奖时间'),
                const SizedBox(
                  width: 30,
                ),
                TextButton(
                    onPressed: () async {
                      var result = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.fromMillisecondsSinceEpoch(
                            acquisitionTime.value),
                        firstDate: DateTime(1970),
                        lastDate: DateTime.now(),
                        locale: const Locale('zh'), // 设置语言环境为中文
                      );
                      if (result != null) {
                        acquisitionTime.value = result.millisecondsSinceEpoch;
                      }
                    },
                    child: Obx(() => Text(
                          DateFormat('yyyy年MM月dd日').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  acquisitionTime.value)),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ))),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('附属文件'),
                const SizedBox(
                  width: 30,
                ),
                IconButton(
                    onPressed: () async {
                      file.value = await FileUtil.pickFile();
                    },
                    icon: const Icon(Icons.upload)),
                const SizedBox(
                  width: 8,
                ),
                Obx(() =>
                    file.value == null ? Container() : Text(file.value!.name))
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              bool result = await HttpRequestUtil.boolPostFile(
                  endpoint: '/award/insert',
                  parameters: {
                    "awardCategoryId": award.awardCategory!.awardCategoryId,
                    "raceLevel": award.raceLevel.index,
                    "awardName": awardNameController.text,
                    "awardLevel": award.awardLevel.index,
                    "ranking": !hasRanking.value
                        ? 0
                        : int.parse(rankingController.text),
                    "acquisitionTime": acquisitionTime.value,
                  },
                  filePath: file.value!.path!);
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

  void editAward(Award award, Set<AwardCategory> awardCategories) {
    TextEditingController awardCategoryController = TextEditingController(
        text: award.awardCategory?.awardCategoryName ?? '');
    TextEditingController raceLevelController = TextEditingController();
    TextEditingController awardLevelController = TextEditingController();
    TextEditingController rankingController =
        TextEditingController(text: award.ranking?.toString());
    var hasRanking = RxBool(award.ranking != null);
    TextEditingController awardNameController =
        TextEditingController(text: award.awardName);
    var acquisitionTime = RxInt(award.acquisitionTime);
    var file = Rxn<PlatformFile>();
    Get.dialog(
      AlertDialog(
        title: const Text('编辑奖项'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('成果种类'),
                const SizedBox(
                  width: 30,
                ),
                DropdownMenu<AwardCategory>(
                    width: 150,
                    menuHeight: 150,
                    controller: awardCategoryController,
                    initialSelection: award.awardCategory!,
                    onSelected: (value) => award.awardCategory = value,
                    dropdownMenuEntries: awardCategories
                        .map<DropdownMenuEntry<AwardCategory>>(
                            (AwardCategory awardCategory) =>
                                DropdownMenuEntry<AwardCategory>(
                                    value: awardCategory,
                                    label: awardCategory.awardCategoryName))
                        .toList()),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('赛事等级'),
                const SizedBox(
                  width: 30,
                ),
                DropdownMenu<RaceLevel>(
                    width: 150,
                    menuHeight: 150,
                    controller: raceLevelController,
                    initialSelection: award.raceLevel,
                    onSelected: (value) =>
                        award.raceLevel = value ?? RaceLevel.unknown,
                    dropdownMenuEntries: List.generate(
                        RaceLevel.values.length - 1,
                        (index) => DropdownMenuEntry<RaceLevel>(
                            value: RaceLevel.get(index + 1),
                            label: RaceLevel.get(index + 1).name))),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('成果名称'),
                const SizedBox(
                  width: 30,
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: awardNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('奖项等级'),
                const SizedBox(
                  width: 30,
                ),
                DropdownMenu<AwardLevel>(
                    width: 150,
                    menuHeight: 150,
                    controller: awardLevelController,
                    initialSelection: award.awardLevel,
                    onSelected: (value) =>
                        award.awardLevel = value ?? AwardLevel.unknown,
                    dropdownMenuEntries: List.generate(
                        AwardLevel.values.length - 1,
                        (index) => DropdownMenuEntry<AwardLevel>(
                            value: AwardLevel.get(index + 1),
                            label: AwardLevel.get(index + 1).name))),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('团队排名'),
                const SizedBox(
                  width: 25,
                ),
                Obx(() => Checkbox(
                    value: hasRanking.value,
                    onChanged: (value) => hasRanking.value = value ?? false)),
                const SizedBox(
                  width: 16,
                ),
                SizedBox(
                  width: 200,
                  child: Obx(() => TextField(
                        controller: rankingController,
                        enabled: hasRanking.value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      )),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('获奖时间'),
                const SizedBox(
                  width: 30,
                ),
                TextButton(
                    onPressed: () async {
                      var result = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.fromMillisecondsSinceEpoch(
                            acquisitionTime.value),
                        firstDate: DateTime(1970),
                        lastDate: DateTime.now(),
                        locale: const Locale('zh'), // 设置语言环境为中文
                      );
                      if (result != null) {
                        acquisitionTime.value = result.millisecondsSinceEpoch;
                      }
                    },
                    child: Obx(() => Text(
                          DateFormat('yyyy年MM月dd日').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  acquisitionTime.value)),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ))),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('附属文件'),
                const SizedBox(
                  width: 30,
                ),
                IconButton(
                    onPressed: () async {
                      file.value = await FileUtil.pickFile();
                    },
                    icon: const Icon(Icons.upload)),
                const SizedBox(
                  width: 8,
                ),
                Obx(() =>
                    file.value == null ? Container() : Text(file.value!.name))
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              bool result = await HttpRequestUtil.boolPost(
                  endpoint: '/award/updateById',
                  parameters: {
                    "awardId": award.awardId,
                    "awardCategoryId": award.awardCategory!.awardCategoryId,
                    "raceLevel": award.raceLevel.index,
                    "awardName": awardNameController.text,
                    "awardLevel": award.awardLevel.index,
                    "ranking": !hasRanking.value
                        ? 0
                        : int.parse(rankingController.text),
                    "acquisitionTime": acquisitionTime.value
                  });
              if (result) {
                IconSnackBar.show(Get.context!,
                    snackBarType: SnackBarType.success, label: '更新成功');
              } else {
                IconSnackBar.show(Get.context!,
                    snackBarType: SnackBarType.fail, label: '更新失败');
              }
              Get.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void removeAward(Set<int> selectedIndexList) {
    Get.dialog(
      AlertDialog(
        title: Text('正在删除${selectedIndexList.length}个奖项'),
        content: const Text('此操作不可恢复，请谨慎操作'),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              int count = 0;
              for (int index in selectedIndexList) {
                bool result = await HttpRequestUtil.boolPost(
                    endpoint: '/award/deleteById',
                    parameters: {"awardId": controller.awards[index]!.awardId});
                if (result) {
                  count++;
                }
              }
              IconSnackBar.show(Get.context!,
                  snackBarType:
                      count > 0 ? SnackBarType.success : SnackBarType.fail,
                  label: '$count个目标操作成功');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void exportAwards(Set<int> selectedIndexList) {
    List<Award> awards = [];
    for (int index in selectedIndexList) {
      if (controller.awards[index] != null) {
        awards.add(controller.awards[index]!);
      }
    }
    StringBuffer buffer = StringBuffer();
    for (Award award in awards) {
      buffer.write(
          '${award.awardCategory?.awardCategoryName ?? ''}-${award.raceLevel.name}-${award.awardName}-${award.awardCategory?.hasAwardLevel ?? false ? '${award.awardLevel.name}${award.ranking != null ? '(排名${award.ranking})' : ''}-' : ''}${DateFormat('yyyy年MM月dd日').format(DateTime.fromMillisecondsSinceEpoch(award.acquisitionTime))}\n');
    }
    TextEditingController contentController =
        TextEditingController(text: buffer.toString());
    Get.dialog(
      AlertDialog(
        title: const Text('导出奖项'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 600,
                  child: TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: contentController.text));
                    IconSnackBar.show(Get.context!,
                        snackBarType: SnackBarType.success, label: '复制成功');
                  },
                  icon: const Icon(Icons.content_copy),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      String? downloadDir = await FileUtil.pickDirectory();
                      if (downloadDir != null) {
                        List<int> ids = [];
                        for (int selectedIndex in selectedIndexList) {
                          ids.add(controller.awards[selectedIndex]!.awardId);
                        }
                        bool result = await HttpRequestUtil.postForFile(
                            endpoint: '/award/exportExcel',
                            savePath: '$downloadDir/导出结果.xlsx',
                            parameters: {"selectedIds": ids});
                        if (result) {
                          IconSnackBar.show(Get.context!,
                              snackBarType: SnackBarType.success,
                              label: '导出成功：$downloadDir/导出结果.xlsx');
                        } else {
                          IconSnackBar.show(Get.context!,
                              snackBarType: SnackBarType.fail, label: '导出失败');
                        }
                      }
                      Get.back();
                    },
                    child: const Text('导出信息为Excel')),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(onPressed: () async {
                      String? downloadDir = await FileUtil.pickDirectory();
                      if (downloadDir != null) {
                        List<int> ids = [];
                        for (int selectedIndex in selectedIndexList) {
                          ids.add(controller.awards[selectedIndex]!.awardId);
                        }
                        bool result = await HttpRequestUtil.postForFile(
                            endpoint: '/award/exportZip',
                            savePath: '$downloadDir/导出结果.zip',
                            parameters: {"selectedIds": ids});
                        if (result) {
                          IconSnackBar.show(Get.context!,
                              snackBarType: SnackBarType.success,
                              label: '导出成功：$downloadDir/导出结果.zip');
                        } else {
                          IconSnackBar.show(Get.context!,
                              snackBarType: SnackBarType.fail, label: '导出失败');
                        }
                      }
                      Get.back();
                    }, child: const Text('重命名并导出文件'))
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AwardManagementController>(
        init: AwardManagementController(),
        id: "award_management",
        builder: (_) {
          return Scaffold(
              backgroundColor: const Color.fromARGB(0, 0, 0, 0),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FutureBuilder(
                      future: controller.getAwardCategoryDetails(),
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
                          List<AwardCategoryDetail> details = snapshot.data!;
                          return Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: 120,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) => Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12))),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: details[index]
                                                              .awardCategory
                                                              .icon !=
                                                          null
                                                      ? Image.memory(
                                                          details[index]
                                                              .awardCategory
                                                              .icon!)
                                                      : Container(),
                                                ),
                                                const SizedBox(
                                                  width: 16,
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      details[index]
                                                          .awardCategory
                                                          .awardCategoryName,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          color: Color.fromARGB(
                                                              255,
                                                              80,
                                                              88,
                                                              135)),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      details[index]
                                                          .total
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 24,
                                                          color: Color.fromARGB(
                                                              255,
                                                              80,
                                                              88,
                                                              135)),
                                                    ),
                                                  ],
                                                )
                                              ]),
                                        ),
                                      ),
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          width: 40,
                                        );
                                      },
                                      itemCount: details.length,
                                    )),
                                const SizedBox(
                                  height: 16,
                                ),
                                const Text(
                                  '成果列表',
                                  style: TextStyle(fontSize: 24),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Expanded(
                                    child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(24))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: FutureBuilder(
                                      future: controller.getTotalNum(),
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
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          Set<AwardCategory> awardCategories =
                                              {};
                                          for (var detail in details) {
                                            awardCategories
                                                .add(detail.awardCategory);
                                          }
                                          return CustomPaginatedTable<Award>(
                                            dataNum: snapshot.data!,
                                            tableTitle: '',
                                            columns: [
                                              ColumnItem(
                                                  content: '附属文件',
                                                  minWidth: 50),
                                              ColumnItem(
                                                  content: '成果种类',
                                                  minWidth: 100),
                                              ColumnItem(
                                                  content: '赛事等级',
                                                  minWidth: 80),
                                              ColumnItem(
                                                  content: '成果名称',
                                                  minWidth: 300),
                                              ColumnItem(
                                                  content: '奖项等级',
                                                  minWidth: 100),
                                              ColumnItem(
                                                  content: '获奖时间',
                                                  minWidth: 100),
                                            ],
                                            rowBuilder: (item) => [
                                              IconButton(
                                                  onPressed: () async {
                                                    String? downloadDir =
                                                        await FileUtil
                                                            .pickDirectory();
                                                    if (downloadDir != null) {
                                                      bool result =
                                                          await HttpRequestUtil
                                                              .postForFile(
                                                                  endpoint:
                                                                      '/award/downloadFile',
                                                                  savePath: '$downloadDir/${item.awardName}.png',
                                                                  parameters: {
                                                            'awardId':
                                                                item.awardId
                                                          });
                                                      if (result) {
                                                        IconSnackBar.show(
                                                            Get.context!,
                                                            snackBarType:
                                                                SnackBarType
                                                                    .success,
                                                            label: '下载成功');
                                                      } else {
                                                        IconSnackBar.show(
                                                            Get.context!,
                                                            snackBarType:
                                                                SnackBarType
                                                                    .fail,
                                                            label: '下载失败');
                                                      }
                                                    }
                                                  },
                                                  icon: const Icon(
                                                      Icons.download)),
                                              Text(
                                                item.awardCategory
                                                        ?.awardCategoryName ??
                                                    '',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                item.raceLevel.name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                item.awardName,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                item.awardCategory != null
                                                    ? '${item.awardLevel.name}${item.awardCategory!.hasAwardLevel ? '排名${item.ranking ?? ''}' : ''}'
                                                    : '',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                DateFormat('yyyy年MM月dd日')
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            item.acquisitionTime)),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                            editButton: true,
                                            editCallback: (award) {
                                              editAward(award, awardCategories);
                                            },
                                            deleteCallback: (Set<int>
                                                    selectedIndexList) =>
                                                removeAward(selectedIndexList),
                                            refreshCallback: () {},
                                            addCallback: () =>
                                                addAward(awardCategories),
                                            exportCallback: (Set<int>
                                                    selectedIndexList) =>
                                                exportAwards(selectedIndexList),
                                            getData:
                                                (int page, int pageSize) async {
                                              List<Award> data = [];
                                              for (int i = 0;
                                                  i < pageSize;
                                                  i++) {
                                                if (controller.awards[
                                                        (page - 1) * pageSize +
                                                            i] !=
                                                    null) {
                                                  data.add(controller.awards[
                                                      (page - 1) * pageSize]!);
                                                } else {
                                                  break;
                                                }
                                              }
                                              if (data.length < pageSize) {
                                                data = await controller
                                                    .getAwards(page, pageSize);
                                              }
                                              return data;
                                            },
                                            searchable: true,
                                            searchColumnIndex: 3,
                                            searchCheck:
                                                (data, searchContent) => data
                                                    .awardName
                                                    .contains(searchContent),
                                            refreshButton: false,
                                          );
                                        }
                                        return Container();
                                      },
                                    ),
                                  ),
                                ))
                              ]);
                        }
                        return Container();
                      }),
                ),
              ));
        });
  }
}
