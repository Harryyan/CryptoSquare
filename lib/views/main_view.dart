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

    // 监听homeController的currentTabIndex变化，同步到TabController
    ever(homeController.currentTabIndex, (index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              // 根据登录状态决定跳转到登录页面还是个人资料页面
              if (userController.isLoggedIn) {
                // 已登录，直接跳转到个人资料页面
                Get.to(() => const ProfileView());
              } else {
                // 未登录，先跳转到登录页面
                final result = await Get.to(() => const LoginPage());
                // 检查登录结果，如果登录成功则跳转到个人资料页面
                if (result != null && result['loginStatus'] == 'success') {
                  Get.to(() => const ProfileView());
                }
              }
            },
            child: Obx(() {
              if (userController.isLoggedIn &&
                  userController.user.avatarUrl != null) {
                return CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(userController.user.avatarUrl!),
                );
              } else {
                return SvgPicture.asset(
                  'assets/images/avatar_placeholder.svg',
                  height: 30,
                  width: 30,
                );
              }
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
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        padding: const EdgeInsets.only(left: 0, right: 8), // 修改padding，确保左侧从0开始
        onTap: (index) {
          homeController.changeTab(index);
        },
        // 添加这个属性，确保首页Tab始终靠近左侧
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
            color:
                homeController.currentTabIndex.value == index
                    ? AppTheme.primaryColor
                    : Colors.black54,
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
