import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/views/main_view.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/controllers/service_controller.dart';
import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/l10n/translation.dart';
import 'package:cryptosquare/util/environment_config.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  // 默认使用正式环境
  // 如需切换到测试环境，取消下面这行注释
  EnvironmentConfig.switchToProduction();
  await GetStorage.init();

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
    Get.put(JobController());

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
      // 添加SmartDialog配置
      builder: FlutterSmartDialog.init(),
      navigatorObservers: [FlutterSmartDialog.observer],
    );
  }
}
