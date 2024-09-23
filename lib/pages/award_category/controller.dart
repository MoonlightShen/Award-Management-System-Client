

import 'package:award_management_system/common/index.dart';
import 'package:award_management_system/common/models/award_category.dart';
import 'package:get/get.dart';

class AwardCategoryController extends GetxController {
  Future<List<AwardCategory>> getAllAwardCategory() async{
    // List<AwardCategory> awardCategories = [];
    // for (int i = 0; i < 5; i++) {
    //   awardCategories.add(AwardCategory(
    //       awardCategoryId: i + 1,
    //       awardCategoryName: '奖励成果种类${i+1}'));
    // }
    return (await HttpRequestUtil.postList<AwardCategory>(endpoint: '/awardCategory/getAll',
     parameters: {}, fromJson: (json)=>AwardCategory.fromJson(json), optionFailCallback: (String failCode){}))!;
  }
}
