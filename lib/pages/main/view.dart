import 'dart:typed_data';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:get/get.dart';
import 'package:award_management_system/common/components/side_navigation.dart';
import 'package:award_management_system/common/index.dart';
import 'package:award_management_system/pages/index.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  void _signOut() {
    Get.offAllNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
        init: MainController(),
        id: "main",
        builder: (_) {
          return Scaffold(
            key: controller.scaffoldKey,
            endDrawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(120),
                          child: FutureBuilder(
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
                                return Image.memory(data);
                              }
                              return Container();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('退出登录'),
                    onTap: _signOut,
                  ),
                  // ...
                ],
              ),
            ),
            body: WindowBorder(
                color: Colors.black,
                width: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      // gradient: LinearGradient(
                      //   colors: [
                      //     Color.fromARGB(255, 98, 197, 255),
                      //     Color.fromARGB(255, 245, 246, 250),
                      //   ],
                      //   begin: Alignment.bottomLeft,
                      //   end: Alignment.topRight,
                      // ),
                      color: Color.fromARGB(255, 245, 247, 250)),
                  child: AdaptiveLayout(
                    transitionDuration: const Duration(seconds: 1),
                    topNavigation: SlotLayout(
                      config: <Breakpoint, SlotLayoutConfig>{
                        Breakpoints.largeDesktop: SlotLayout.from(
                          key: const Key('Top Menu Medium'),
                          inAnimation: AdaptiveScaffold.fadeIn,
                          outAnimation: AdaptiveScaffold.fadeOut,
                          builder: (_) => Container(
                            height: 85,
                            color: Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  child: MoveWindow(
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          left: 20, top: 8, bottom: 8),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '成果奖励管理系统',
                                            style: TextStyle(fontSize: 30),
                                          )),
                                    ),
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(
                                      maxHeight: double.infinity),
                                  child: Wrap(
                                    spacing: 20,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Obx(() => Text(
                                            controller.userName.value,
                                            style:
                                                const TextStyle(fontSize: 24),
                                          )),
                                      SizedBox(
                                        width: 65,
                                        height: 65,
                                        child: Center(
                                          child: IconButton(
                                            icon: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(33),
                                              child: FutureBuilder(
                                                future:
                                                    HttpRequestUtil.imagePost(
                                                        endpoint:
                                                            '/user/getAvatar'),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    return const Center(
                                                      child: Text(
                                                        '加载失败',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    );
                                                  } else if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                      child: SizedBox(
                                                        width: 200,
                                                        height: 200,
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  } else if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.done) {
                                                    Uint8List data =
                                                        snapshot.data!;
                                                    return Image.memory(data);
                                                  }
                                                  return Container();
                                                },
                                              ),
                                            ),
                                            onPressed: controller.openEndDrawer,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                              onPressed: () =>
                                                  appWindow.minimize(),
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
                                              icon: const Icon(
                                                  Icons.fit_screen_outlined)),
                                          IconButton(
                                              onPressed: () =>
                                                  appWindow.close(),
                                              icon: const Icon(Icons.close))
                                        ],
                                      ),
                                      const SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      },
                    ),
                    primaryNavigation: SlotLayout(
                      config: <Breakpoint, SlotLayoutConfig>{
                        Breakpoints.large: SlotLayout.from(
                          key: const Key('Side Navigation Medium'),
                          inAnimation: AdaptiveScaffold.leftOutIn,
                          outAnimation: AdaptiveScaffold.leftInOut,
                          builder: (context) => SideNavigationRail(
                            boxes: [
                              NavigationBox(
                                title: '可视化信息展示',
                                contents: [
                                  NavigationItem(
                                    content: '首页',
                                    defaultIcon: Icons.home,
                                    selectedIcon: Icons.home,
                                  ),
                                ],
                              ),
                              NavigationBox(
                                title: '成果管理',
                                contents: [
                                  NavigationItem(
                                    content: '成果种类',
                                    defaultIcon: Icons.home,
                                    selectedIcon: Icons.home,
                                  ),
                                  NavigationItem(
                                    content: '成果列表',
                                    defaultIcon: Icons.home,
                                    selectedIcon: Icons.home,
                                  ),
                                ],
                              ),
                              NavigationBox(
                                title: '设置',
                                contents: [
                                  NavigationItem(
                                    content: '安全中心',
                                    defaultIcon: Icons.person,
                                    selectedIcon: Icons.person,
                                  ),
                                ],
                              ),
                            ],
                            onItemSelected: (boxIndex, itemIndex) {
                              if (boxIndex == 0) {
                                if (itemIndex == 0) {
                                  Get.offAllNamed(RouteNames.home, id: 1);
                                }
                              } else if (boxIndex == 1) {
                                if (itemIndex == 0) {
                                  Get.offAllNamed(RouteNames.awardCategory,
                                      id: 1);
                                } else if (itemIndex == 1) {
                                  Get.offAllNamed(RouteNames.awardManagement,
                                      id: 1);
                                }
                              } else if (boxIndex == 2) {
                                if (itemIndex == 0) {
                                  Get.offAllNamed(RouteNames.securityCenter,
                                      id: 1);
                                }
                              }
                            },
                          ),
                        ),
                      },
                    ),
                    body: SlotLayout(
                      config: <Breakpoint, SlotLayoutConfig>{
                        Breakpoints.largeDesktop: SlotLayout.from(
                          key: const Key('Body Large Desktop'),
                          builder: (context) => Column(
                            children: [
                              Expanded(
                                  child: Container(
                                margin: const EdgeInsets.all(20),
                                child: Navigator(
                                  key: Get.nestedKey(1),
                                  initialRoute: RouteNames.home,
                                  onGenerateRoute: (settings) {
                                    Widget page;
                                    switch (settings.name) {
                                      case RouteNames.home:
                                        page = HomePage();
                                        break;
                                      case RouteNames.awardCategory:
                                        page = AwardCategoryPage();
                                        break;
                                      case RouteNames.awardManagement:
                                        page = AwardManagementPage();
                                        break;
                                      case RouteNames.securityCenter:
                                        page = SecurityCenterPage();
                                        break;
                                      default:
                                        page = HomePage();
                                        break;
                                    }
                                    Get.routing.args = settings.arguments;
                                    return PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          page,
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return FadeTransition(
                                            opacity: animation, child: child);
                                      },
                                      settings: settings,
                                    );
                                  },
                                ),
                              )),
                            ],
                          ),
                        )
                      },
                    ),
                  ),
                )),
          );
        });
  }
}
