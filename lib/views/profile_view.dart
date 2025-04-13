import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/models/app_models.dart';

// 请确保 GStorage 类已在项目中实现，其 getLanguageCN() 方法返回 true 表示中文界面
// import 'package:cryptosquare/utils/gstorage.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  final UserController userController = Get.find<UserController>();
  final HomeController homeController = Get.find<HomeController>();
  final JobController jobController = Get.find<JobController>();

  late TabController _tabController;
  // 左侧大类：0 - 我的发布，1 - 我的收藏
  final RxInt currentTabIndex = 0.obs;
  // 右侧小分类：2 - 岗位，3 - 帖子；初始值默认为 2（岗位）
  final RxInt postTabIndex = 2.obs;

  @override
  void initState() {
    super.initState();
    // TabController 长度设置为 4（0、1 对应左侧，大于等于2对应右侧）
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    currentTabIndex.value = 0;
    postTabIndex.value = 2;

    // 当 TabController 的 index 改变时同步更新 postTabIndex
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        int idx = _tabController.index;
        // 仅允许 2 或 3
        if (idx != 2 && idx != 3) {
          postTabIndex.value = 2;
        } else {
          postTabIndex.value = idx;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 格式化用户名，中间用 ... 替代（保留头尾各 4 个字符）
  String _formatUserName(String name) {
    if (name.length <= 20) return name;
    return name.substring(0, 4) + '...' + name.substring(name.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: null, // 头部在 _buildHeaderWithAppBar 中自定义实现
      body: Column(
        children: [
          _buildHeaderWithAppBar(),
          _buildTabBar(),
          // 下方内容区域，由 Obx 包裹，依赖 currentTabIndex 和 postTabIndex 变化更新列表
          Expanded(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => _buildTabContent()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithAppBar() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/profile_header.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          // AppBar 部分
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      // 菜单功能
                    },
                  ),
                ],
              ),
            ),
          ),
          // 用户信息部分
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: _buildUserInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              if (userController.isLoggedIn &&
                  userController.user.avatarUrl != null) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      userController.user.avatarUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              } else {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
            }),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      userController.isLoggedIn
                          ? _formatUserName(userController.user.name)
                          : '未登录',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/coin-icon.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '199积分',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    // 签到功能
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '签到',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/profile_header.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 左侧大类：“我的发布” 和 “我的收藏”
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTabItem('我的发布', 0),
                      const SizedBox(width: 15),
                      _buildTabItem('我的收藏', 1),
                    ],
                  ),
                  // 右侧小分类：岗位与帖子 segment
                  Container(
                    width: 160,
                    child: Obx(() {
                      // 确保 postTabIndex 仅为 2 或 3
                      int segValue = postTabIndex.value;
                      if (segValue != 2 && segValue != 3) {
                        segValue = 2;
                        postTabIndex.value = 2;
                      }
                      return CupertinoSegmentedControl<int>(
                        children: {
                          2: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Text(
                              '岗位',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          3: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Text(
                              '帖子',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        },
                        groupValue: segValue,
                        onValueChanged: (int value) {
                          postTabIndex.value = value;
                          // 如需要同步更新 TabController，也可调用：
                          // _tabController.animateTo(value);
                        },
                        selectedColor: const Color(0xFF2563EB),
                        unselectedColor: Colors.grey[100]!,
                        borderColor: Colors.transparent,
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(height: 1, color: Colors.grey.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  /// 左侧大类标签构建
  Widget _buildTabItem(String text, int index) {
    return Obx(() {
      final isSelected = currentTabIndex.value == index;
      return GestureDetector(
        onTap: () {
          currentTabIndex.value = index;
          _tabController.animateTo(index);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 3,
              width: 70,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 根据大类和小分类返回对应内容
  Widget _buildTabContent() {
    print(
      "Rebuild _buildTabContent: currentTabIndex = ${currentTabIndex.value}, postTabIndex = ${postTabIndex.value}",
    );
    if (currentTabIndex.value == 0) {
      // 我的发布下根据小分类显示内容
      if (postTabIndex.value == 2) {
        return _buildMyPostsJobsTab();
      } else if (postTabIndex.value == 3) {
        return _buildMyPostsForumTab();
      }
    } else if (currentTabIndex.value == 1) {
      // 我的收藏下
      if (postTabIndex.value == 2) {
        return _buildMyFavoritesJobsTab();
      } else if (postTabIndex.value == 3) {
        return _buildMyFavoritesForumTab();
      }
    }
    return Container();
  }

  /// 我的发布 - 岗位列表
  Widget _buildMyPostsJobsTab() {
    // 这里用示例数据替代，实际可替换为真实数据
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(title: Text("我的发布 - 岗位 第${index + 1}项"));
      },
    );
  }

  /// 我的发布 - 帖子列表
  Widget _buildMyPostsForumTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(title: Text("我的发布 - 帖子 第${index + 1}项"));
      },
    );
  }

  /// 我的收藏 - 岗位列表
  Widget _buildMyFavoritesJobsTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(title: Text("我的收藏 - 岗位 第${index + 1}项"));
      },
    );
  }

  /// 我的收藏 - 帖子列表
  Widget _buildMyFavoritesForumTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(title: Text("我的收藏 - 帖子 第${index + 1}项"));
      },
    );
  }
}
