import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/views/page_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/views/home_view.dart';
import 'package:cryptosquare/views/job_view.dart';
import 'package:cryptosquare/views/profile_view.dart';
import 'package:cryptosquare/views/forum_view.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/util/event_bus.dart';
import 'package:social_share_plus/social_share.dart';

class MainView extends StatefulWidget {
  MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  final HomeController homeController = Get.find<HomeController>();
  final UserController userController = Get.find<UserController>();
  late TabController _tabController;

  // 添加登录状态的响应式变量
  final RxBool isLoggedIn = false.obs;
  // 添加头像URL的响应式变量
  final RxString avatarUrl = ''.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 监听Tab切换，确保UI更新与控制器同步
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        homeController.changeTab(_tabController.index);
      }
    });

    ShareRegister register = ShareRegister();
    // 3ad2e82de7431e5d7a20d2ced74b1503
    register.setupWechat('wx510ea51166afc3ad', "https://cryptosquare.org/app");
    SharePlugin.registerPlatforms(register);

    // 初始化登录状态
    isLoggedIn.value = GStorage().getLoginStatus();

    // 如果用户已登录，从GStorage加载用户信息
    if (isLoggedIn.value) {
      _loadUserInfo();
    }

    // 注册所有事件监听
    _reregisterEventListeners();

    // 监听homeController的currentTabIndex变化，同步到TabController
    ever(homeController.currentTabIndex, (index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });
  }

  @override
  void dispose() {
    // 移除事件监听
    eventBus.off('loginSuccessful');
    eventBus.off('logoutSuccessful');
    eventBus.off('avatarUpdated');
    _tabController.dispose();
    super.dispose();
  }

  // 重新注册事件监听
  void _reregisterEventListeners() {
    // 先移除旧的监听器，防止重复注册
    eventBus.off('loginSuccessful');
    eventBus.off('logoutSuccessful');
    eventBus.off('avatarUpdated');

    // 重新注册监听器
    eventBus.on('loginSuccessful', (_) {
      updateLoginStatus();
      _loadUserInfo(); // 登录成功后加载用户信息
    });

    eventBus.on('logoutSuccessful', (_) {
      updateLoginStatus();
      userController.logout(); // 登出时清除用户信息
    });

    eventBus.on('avatarUpdated', (_) {
      // 当头像更新时，重新加载用户信息以更新头像显示
      _loadUserInfo();
    });
  }

  // 监听登录状态变化
  void updateLoginStatus() {
    isLoggedIn.value = GStorage().getLoginStatus();
  }

  // 从GStorage加载用户信息
  void _loadUserInfo() {
    Map userInfo = GStorage().getUserInfo();
    if (userInfo.isNotEmpty) {
      // 更新头像URL的响应式变量
      avatarUrl.value = userInfo['avatar'] ?? '';

      // 创建User对象并更新UserController
      User user = User(
        id: userInfo['userID'] ?? 0,
        name: userInfo['userName'] ?? '',
        avatarUrl: userInfo['avatar'],
        isLoggedIn: true,
      );
      userController.login(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false, // 确保底部安全区域不会被压着,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: Obx(() {
                switch (homeController.currentTabIndex.value) {
                  case 0:
                    return HomeView();
                  case 1:
                    return JobView();
                  case 2:
                    return const ForumView();
                  default:
                    return HomeView();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/logo.png', height: 20),
          // 用户头像
          GestureDetector(
            onTap: () async {
              // 使用响应式变量检查登录状态
              if (isLoggedIn.value) {
                // 已登录，直接跳转到个人资料页面
                Get.to(() => const ProfileView());
              } else {
                // 未登录，先跳转到登录页面
                final result = await Get.to(() => const LoginPage());
                // 检查登录结果，如果登录成功则跳转到个人资料页面
                if (result != null && result['loginStatus'] == 'success') {
                  // 重新注册事件监听，确保登录后事件能正常触发
                  _reregisterEventListeners();
                  // 更新登录状态
                  isLoggedIn.value = true;
                  // 手动加载用户信息，确保头像能立即显示
                  _loadUserInfo();
                  Get.to(() => const ProfileView());
                }
              }
            },
            child: Obx(() {
              if (isLoggedIn.value) {
                // 使用响应式变量avatarUrl
                if (avatarUrl.value.isNotEmpty) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatarUrl.value),
                  );
                }
              }
              // 未登录或没有头像时显示默认头像
              return Image.asset(
                'assets/images/avatar2.png',
                height: 40,
                width: 40,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: [
          _buildTab('首页', 0),
          _buildTab('Web3工作', 1),
          _buildTab('全球论坛', 2),
        ],
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        padding: const EdgeInsets.only(left: 16, right: 8),
        onTap: (index) {
          homeController.changeTab(index);
        },
        tabAlignment: TabAlignment.start,
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Obx(
      () => Tab(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color:Colors.black,
            fontWeight:
                homeController.currentTabIndex.value == index
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
