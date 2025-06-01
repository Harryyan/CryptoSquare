import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式，统一状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 透明状态栏
      statusBarIconBrightness: Brightness.dark, // 深色图标
      statusBarBrightness: Brightness.light, // iOS使用
      systemNavigationBarColor: Colors.white, // 导航栏颜色
      systemNavigationBarIconBrightness: Brightness.dark, // 导航栏图标
    ),
  );
  
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
      // 添加本地化代理
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      // 添加SmartDialog配置，并确保状态栏样式一致
      builder: (context, child) {
        // 在每个页面构建时强制设置状态栏样式
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        );
        return FlutterSmartDialog.init()(context, child);
      },
      navigatorObservers: [FlutterSmartDialog.observer],
    );
  }
}
