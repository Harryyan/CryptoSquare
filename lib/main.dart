import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/views/main_view.dart';

void main() {
  // 初始化控制器
  Get.put(UserController());
  Get.put(HomeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cryptosquare',
      theme: AppTheme.lightTheme,
      home: MainView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
