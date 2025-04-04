import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/views/main_view.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/controllers/service_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/l10n/translation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化控制器
    Get.put(HomeController());
    Get.put(UserController());
    Get.put(ServiceController());

    return GetMaterialApp(
      title: 'CryptoSquare',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      translations: Translation(),
      locale: const Locale('zh', 'CN'),
      fallbackLocale: const Locale('en', 'US'),
      home: MainView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
