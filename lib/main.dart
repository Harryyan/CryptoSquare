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
import 'package:app_links/app_links.dart';
import 'package:cryptosquare/controllers/article_controller.dart';
import 'package:cryptosquare/views/topic_webview.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cryptosquare/services/analytics_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase初始化成功');
  } catch (e) {
    print('Firebase初始化失败: $e');
    // 继续运行app，但Firebase功能将不可用
  }

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

  try {
    // 默认使用正式环境
    // 如需切换到测试环境，取消下面这行注释
    EnvironmentConfig.switchToProduction();
    await GetStorage.init();
    print('GetStorage初始化成功');
  } catch (e) {
    print('GetStorage初始化失败: $e');
  }

  // 初始化深度链接监听器
  _initDeepLinkListener();

  runApp(const MyApp());
}

// 初始化深度链接监听器
void _initDeepLinkListener() async {
  try {
    final appLinks = AppLinks();

    // 监听所有深度链接事件（包括初始链接和运行时链接）
    appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (error) {
        print('深度链接监听器错误: $error');
      },
    );

    print('深度链接监听器初始化成功');
  } catch (e) {
    print('初始化深度链接监听器失败: $e');
    // 深度链接失败不应该阻止app启动
  }
}

// 处理深度链接
void _handleDeepLink(Uri uri) async {
  print('收到深度链接: $uri');

  try {
    // 检查scheme是否匹配
    if (uri.scheme == 'cryptosquare' ||
        (uri.scheme == 'https' && uri.host == 'cryptosquare.org')) {
      // 解析参数
      String? topicId = uri.queryParameters['topicId'];
      String? jobId = uri.queryParameters['jobId'];

      if (topicId != null && topicId.isNotEmpty) {
        // 有topicId参数，导航到文章详情
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToArticle(topicId);
        });
      } else if (jobId != null && jobId.isNotEmpty) {
        // 有jobId参数，导航到工作详情
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToJob(jobId);
        });
      } else {
        // 没有任何参数，直接打开app停留在首页，不做任何跳转
        print('深度链接没有特定参数，app正常启动到首页');
      }
    }
  } catch (e) {
    print('处理深度链接时出错: $e');
  }
}

// 导航到文章详情页面
void _navigateToArticle(String topicId) {
  try {
    // 获取HomeController实例
    final homeController = Get.find<HomeController>();

    // 先切换到全球论坛Tab（index 3）
    homeController.changeTab(3);

    // 延迟导航到文章详情，确保论坛页面已加载
    Future.delayed(const Duration(milliseconds: 300), () {
      // 获取当前context并导航到文章详情
      final context = Get.context;
      if (context != null) {
        // 处理特定的topicId（参考截图中的逻辑）
        if (topicId == '5313' || topicId == '5981') {
          // 这些是特殊的topicId，导航到WebView页面
          Get.toNamed(
            '/topic/$topicId',
            arguments: {
              'title':
                  topicId == '5313' || topicId == '5981'
                      ? '300U大奖过来拿！Web2与Web3大佬选美大比拼！'
                      : '话题详情',
              'path': topicId,
            },
          );
        } else {
          // 普通文章，导航到文章详情页面
          ArticleController().navigateToArticleDetail(context, topicId);
        }
      }
    });
  } catch (e) {
    print('导航到文章详情页面失败: $e');
    // 如果导航失败，至少跳转到论坛页面
    _navigateToForum();
  }
}

// 导航到论坛页面
void _navigateToForum() {
  try {
    // 获取HomeController实例
    final homeController = Get.find<HomeController>();

    // 切换到全球论坛Tab（index 3）
    homeController.changeTab(3);
  } catch (e) {
    print('导航到论坛页面失败: $e');
  }
}

// 导航到工作详情页面
void _navigateToJob(String jobId) {
  try {
    // 获取HomeController实例
    final homeController = Get.find<HomeController>();

    // 先切换到Web3工作Tab（index 1）
    homeController.changeTab(1);

    // 延迟导航到工作详情，确保工作页面已加载
    Future.delayed(const Duration(milliseconds: 300), () {
      // 创建一个JobData对象用于导航
      // 使用jobId作为jobKey，其他字段使用默认值
      final jobData = JobData(
        jobKey: jobId,
        jobTitle: "职位详情", // 占位符，实际详情会通过API获取
        jobCompany: "加载中...", // 占位符
        jobSalaryCurrency: "USD", // 默认值
      );

      // 使用JobController导航到工作详情页面
      Get.find<JobController>().navigateToJobDetail(jobData);
    });
  } catch (e) {
    print('导航到工作详情页面失败: $e');
    // 如果导航失败，至少跳转到工作页面
    try {
      Get.find<HomeController>().changeTab(1);
    } catch (fallbackError) {
      print('切换到工作页面也失败: $fallbackError');
    }
  }
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
      // 添加路由配置，支持深度链接
      getPages: [
        GetPage(
          name: '/topic/:topicId',
          page: () {
            final arguments = Get.arguments as Map<String, dynamic>?;
            return TopicWebView(
              title: arguments?['title'] ?? '话题详情',
              path: arguments?['path'] ?? '',
            );
          },
        ),
        GetPage(
          name: '/job/:jobId',
          page: () {
            final arguments = Get.arguments as Map<String, dynamic>?;
            final jobData = arguments?['jobData'] as JobData?;
            if (jobData != null) {
              // 直接导航到JobDetailView，让JobController处理详情获取
              Get.find<JobController>().navigateToJobDetail(jobData);
            }
            // 返回一个占位页面，实际会被JobDetailView替换
            return Container();
          },
        ),
      ],
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
      navigatorObservers: [
        FlutterSmartDialog.observer,
        AnalyticsService.observer,
      ],
    );
  }
}
