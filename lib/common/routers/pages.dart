import 'package:get/get.dart';

import '../../pages/index.dart';
import 'names.dart';

class RoutePages {
  // 列表
  static List<GetPage> list = [
      GetPage(
        name: RouteNames.awardCategory,
        page: () => const AwardCategoryPage(),
      ),
      GetPage(
        name: RouteNames.awardManagement,
        page: () => const AwardManagementPage(),
      ),
      GetPage(
        name: RouteNames.home,
        page: () => const HomePage(),
      ),
      GetPage(
        name: RouteNames.login,
        page: () => const LoginPage(),
      ),
      GetPage(
        name: RouteNames.main,
        page: () => const MainPage(),
      ),
      GetPage(
        name: RouteNames.securityCenter,
        page: () => const SecurityCenterPage(),
      ),
  ];
}
