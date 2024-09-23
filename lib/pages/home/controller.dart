import 'package:award_management_system/common/index.dart';
import 'package:get/get.dart';
import 'package:award_management_system/common/models/award.dart';

class HomeController extends GetxController {
  var pieChartTouchedIndex = RxInt(-1);

  Future<List<Award>> getLatelyAwards(int total) async {
    return (await HttpRequestUtil.postList<Award>(
        endpoint: '/award/recentAwards',
        parameters: {},
        fromJson: (json) => Award.fromJson(json),
        optionFailCallback: (String failCode) {}))!;
  }

  Future<List<Award>> getAwardsFromRange(int startTime, int endTime) async {
    return (await HttpRequestUtil.postList<Award>(
        endpoint: '/award/thisYearAwards',
        parameters: {},
        fromJson: (json) => Award.fromJson(json),
        optionFailCallback: (String failCode) {}))!;
  }
}
