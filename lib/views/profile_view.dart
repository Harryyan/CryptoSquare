import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/models/app_models.dart';

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
  final RxInt currentTabIndex = 0.obs;
  final RxInt postTabIndex = 0.obs; // 新增变量用于岗位和帖子标签

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 2,
    ); // 默认选中"岗位"标签
    currentTabIndex.value = 0; // 默认选中"我的发布"标签
    postTabIndex.value = 2; // 默认选中"岗位"标签
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        postTabIndex.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 格式化用户名，保留两端，中间用...替代
  String _formatUserName(String name) {
    if (name.length <= 20) return name;
    return name.substring(0, 4) + '...' + name.substring(name.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: null, // 移除AppBar，我们将在自定义头部中添加返回按钮和菜单
      body: Column(
        children: [
          _buildHeaderWithAppBar(), // 新的方法，包含AppBar和用户信息
          _buildTabBar(),
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
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/profile_header.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          // AppBar部分
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

  // 此方法已被_buildHeaderWithAppBar替代，保留以防其他地方引用
  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/profile_header.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: _buildUserInfo(),
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
                          : _formatUserName('Harryyan1238'),
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
            // 使用Align组件使签到按钮与积分信息垂直居中对齐
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTabItem('我的发布', 0),
                      const SizedBox(width: 15),
                      _buildTabItem('我的收藏', 1),
                    ],
                  ),
                  // 使用CupertinoSegmentedControl替换岗位和帖子选项
                  Container(
                    width: 160, // 设置宽度与原来保持一致
                    child: CupertinoSegmentedControl<int>(
                      children: {
                        2: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Text(
                            '岗位',
                            style: TextStyle(
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
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (int value) {
                        setState(() {
                          postTabIndex.value = value;
                        });
                      },
                      groupValue: postTabIndex.value,
                      selectedColor: const Color(0xFF2563EB),
                      unselectedColor: Colors.grey[100]!,
                      borderColor: Colors.transparent,
                    ),
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

  // 修改后的_buildTabItem方法，只处理左侧的"我的发布"和"我的收藏"标签
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
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 17, // 增大字体
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 3,
              width: 70,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabContent() {
    // 首先检查是否选择了左侧标签（我的发布/我的收藏）
    if (currentTabIndex.value == 0) {
      return _buildMyPostsTab();
    } else if (currentTabIndex.value == 1) {
      return _buildMyFavoritesTab();
    }

    // 如果没有选择左侧标签，则根据右侧标签（岗位/帖子）显示内容
    if (postTabIndex.value == 2) {
      return _buildJobsTab();
    } else if (postTabIndex.value == 3) {
      return _buildForumPostsTab();
    } else {
      return _buildMyPostsTab(); // 默认显示我的发布
    }
  }

  Widget _buildMyPostsTab() {
    // 示例数据
    final List<Map<String, dynamic>> posts = [
      {
        'title': '从技术到应用：普通人的 Web3 学习手册',
        'image': 'https://via.placeholder.com/150',
        'time': '1小时前',
        'comments': 10,
      },
      {
        'title': '从技术到应用：普通人的 Web3 学习手册',
        'image': 'https://via.placeholder.com/150',
        'time': '1小时前',
        'comments': 10,
      },
      {
        'title': '从技术到应用：普通人的 Web3 学习手册',
        'image': 'https://via.placeholder.com/150',
        'time': '1小时前',
        'comments': 10,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostItem(post);
      },
    );
  }

  Widget _buildMyFavoritesTab() {
    // 与我的发布类似，但显示收藏的内容
    return _buildMyPostsTab(); // 暂时复用相同的UI
  }

  Widget _buildJobsTab() {
    // 显示岗位列表
    return Obx(() {
      if (jobController.jobs.isEmpty) {
        return const Center(child: Text('暂无岗位信息'));
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: jobController.jobs.length,
        itemBuilder: (context, index) {
          final job = jobController.jobs[index];
          return _buildJobItem(job);
        },
      );
    });
  }

  Widget _buildForumPostsTab() {
    // 显示论坛帖子
    return _buildMyPostsTab(); // 暂时复用相同的UI
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post['title'],
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '美国SEC前官员John Reed Stark认为，SEC对Coinbase的诉讼可能会胜诉中，因为该监管机构新成立的加密货币工作组正在寻求解决此前...',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  userController.user.avatarUrl ??
                      'https://via.placeholder.com/20',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                '我不是游客',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Text(
                post['time'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              const Icon(Icons.comment_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                '${post['comments']}条评论',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobItem(JobPost job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                job.company,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(width: 10),
              Text(
                job.location,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                job.salary,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                job.getFormattedTime(),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                job.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.tagBackgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.tagTextColor,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
