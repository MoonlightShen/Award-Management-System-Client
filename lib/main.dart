import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cherrilog/cherrilog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'common/index.dart';

void main() {
  databaseFactory = databaseFactoryFfi;
  CherriLog.init(
    options: CherriOptions()
      ..logLevelRange = CherriLogLevelRanges.all
      ..useBuffer = false,
  ).logTo(
      CherriConsole()); // Use `CherriFile()` instead of `CherriConsole` if you want to log to file system

  runApp(const MyApp());
  doWhenWindowReady(() {
    appWindow.size = const Size(1700, 1020);
    appWindow.minSize = const Size(867, 540);
    appWindow.alignment = Alignment.topCenter;
    appWindow.title = '123';
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
        fontFamily: 'ALiMaMaShuHei',
      ),
      getPages: RoutePages.list,
      initialRoute: RouteNames.login,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'), // 支持中文
        Locale('en'), // 支持英文
      ],
      locale: const Locale('zh'), // 设置为中文环境
    );
  }
}
