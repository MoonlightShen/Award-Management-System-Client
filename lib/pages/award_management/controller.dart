import 'package:award_management_system/common/index.dart';
import 'package:award_management_system/common/models/award.dart';
import 'package:award_management_system/common/models/award_category.dart';
import 'package:get/get.dart';

class AwardCategoryDetail {
  final AwardCategory awardCategory;
  final int total;

  AwardCategoryDetail({required this.awardCategory, required this.total});

  factory AwardCategoryDetail.fromJson(Map<String, dynamic> json) =>
      AwardCategoryDetail(
        awardCategory: AwardCategory.fromJson(json['awardCategory']),
        total: json['total'] != null ? json['total'] as int : 0,
      );
}

class AwardManagementController extends GetxController {
  Future<List<AwardCategoryDetail>> getAwardCategoryDetails() async {
    // List.generate(
    //     10,
    //     (index) => AwardCategoryDetail(
    //         awardCategory: AwardCategory(
    //             awardCategoryId: index, awardCategoryName: '种类$index'),
    //         total: Random().nextInt(10) + 1))
    return (await HttpRequestUtil.postList<AwardCategoryDetail>(
        endpoint: '/award/getAwardCategoryDetails',
        parameters: {},
        fromJson: (json) => AwardCategoryDetail.fromJson(json),
        optionFailCallback: (String failCode) {}))!;
  }

  Future<int> getTotalNum() async {
    return (await HttpRequestUtil.totalNumberPost(
        endpoint: '/award/getTotal',
        parameters: {},
        optionFailCallback: (String failCode) {}))!;
  }

  var awards = <int, Award>{}.obs;

  Future<List<Award>> getAwards(int page, int pageSize) async {
    var newData = (await HttpRequestUtil.postList<Award>(
        endpoint: '/award/getByPage',
        parameters: {'page': page, 'pageSize': pageSize},
        fromJson: (Map<String, dynamic> jsonData) => Award.fromJson(jsonData),
        optionFailCallback: (String failCode) {}))!;
    for (int i = 0; i < newData.length; i++) {
      awards[(page - 1) * pageSize + i] = newData[i];
    }
    return newData;
    // List<AwardCategory> awardCategories = [];
    // for (int i = 0; i < 5; i++) {
    //   awardCategories.add(AwardCategory(
    //       awardCategoryId: i + 1, awardCategoryName: '奖励成果种类${i + 1}', hasAwardLevel: true));
    // }
    // for (int i = 0; i < pageSize; i++) {
    //   bool flag = Random().nextBool();
    //   awards[(page - 1) * pageSize + i] = Award(
    //       awardId: (page - 1) * pageSize + i,
    //       awardCategory: awardCategories[Random().nextInt(5)],
    //       raceLevel: RaceLevel.get(Random().nextInt(6) + 1),
    //       awardName: '奖项名称${awards.length + (page - 1) * pageSize + i}',
    //       awardLevel: AwardLevel.get(Random().nextInt(4) + 1),
    //       acquisitionTime: DateTime(2024 + (flag ? -1 : 0),
    //               (flag ? Random().nextInt(4) + 9 : Random().nextInt(9) + 1))
    //           .millisecondsSinceEpoch);
    // }
    // List<Award> newData = [];
    // for(int i=0;i<pageSize;i++){
    //   newData.add(awards[(page - 1) * pageSize + i]!);
    // }
    // return newData;
  }
}
