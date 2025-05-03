import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/util/tag_utils.dart';
import 'package:cryptosquare/util/storage.dart';
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
  // 左侧：0=我的发布，1=我的收藏
  final RxInt currentTabIndex = 0.obs;
  // 右侧：2=岗位，3=帖子
  final RxInt postTabIndex = 2.obs;

  // 用户信息
  final RxBool isUserLoggedIn = false.obs;
  final RxString userName = '未登录'.obs;
  final RxString userAvatar = ''.obs;
  final RxInt userScore = 0.obs;

  @override
  void initState() {
    super.initState();
    // TabController 仅作示例（长度4：0、1、2、3），你也可以仅用于左侧标签
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);

    currentTabIndex.value = 0; // 默认选中我的发布
    postTabIndex.value = 2; // 默认选中岗位

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

    // 从GStorage加载用户信息
    _loadUserInfo();

    // 使用addPostFrameCallback确保在构建完成后再同步用户信息到UserController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUserInfoToController();
    });
  }

  /// 从GStorage加载用户信息
  void _loadUserInfo() {
    // 检查登录状态
    isUserLoggedIn.value = GStorage().getLoginStatus();

    if (isUserLoggedIn.value) {
      // 获取用户信息
      Map userInfo = GStorage().getUserInfo();

      // 更新用户信息
      userName.value = userInfo['userName'] ?? '未登录';
      userAvatar.value = userInfo['avatar'] ?? '';
      userScore.value = userInfo['score'] ?? 0;
    }
  }

  /// 将用户信息同步到UserController
  void _syncUserInfoToController() {
    if (isUserLoggedIn.value && userController.user.id == 0) {
      Map userInfo = GStorage().getUserInfo();
      userController.login(
        User(
          id: userInfo['userID'] ?? 0,
          name: userName.value,
          avatarUrl: userAvatar.value,
          isLoggedIn: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 简单格式化用户名，保留前4位和后4位，中间用 ... 替代
  String _formatUserName(String name) {
    if (name.length <= 20) return name;
    return name.substring(0, 4) + '...' + name.substring(name.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: null,
      body: Column(
        children: [
          _buildHeaderWithAppBar(), // 头部区域
          _buildTabBar(), // 上方标签栏
          // 下方内容区域
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

  /// 包含自定义的 AppBar + 用户信息
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
          // 自定义 AppBar
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
                      // 可扩展：点击事件
                    },
                  ),
                ],
              ),
            ),
          ),
          // 用户信息
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: _buildUserInfo(),
          ),
        ],
      ),
    );
  }

  /// 用户信息
  Widget _buildUserInfo() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              if (isUserLoggedIn.value && userAvatar.value.isNotEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      userAvatar.value,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              } else {
                // 未登录或无头像
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
                      isUserLoggedIn.value
                          ? _formatUserName(userName.value)
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
                      Obx(
                        () => Text(
                          '${userScore.value}积分',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
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
                    // 点击签到
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

  /// 包含左侧"我的发布/我的收藏" + 右侧"岗位/帖子"segmentedControl
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
                  // 左侧大类
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTabItem('我的发布', 0),
                      const SizedBox(width: 15),
                      _buildTabItem('我的收藏', 1),
                    ],
                  ),
                  // 右侧小分类：岗位/帖子
                  Container(
                    width: 160,
                    child: Obx(() {
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
                          // 如要同步TabController:
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
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.grey.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  /// 构建左侧标签item
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

  /// 根据大类(currentTabIndex) + 小分类(postTabIndex) 返回对应的列表UI
  Widget _buildTabContent() {
    print(
      "Rebuild _buildTabContent => "
      "currentTabIndex = ${currentTabIndex.value}, "
      "postTabIndex = ${postTabIndex.value}",
    );

    if (currentTabIndex.value == 0) {
      // 我的发布
      if (postTabIndex.value == 2) {
        // 我的发布 + 岗位
        return _buildMyPostsJobsList();
      } else if (postTabIndex.value == 3) {
        // 我的发布 + 帖子
        return _buildMyPostsForumList();
      }
    } else if (currentTabIndex.value == 1) {
      // 我的收藏
      if (postTabIndex.value == 2) {
        // 我的收藏 + 岗位
        return _buildMyFavoritesJobsList();
      } else if (postTabIndex.value == 3) {
        // 我的收藏 + 帖子
        return _buildMyFavoritesForumList();
      }
    }
    return Container(); // 默认空白，或可自定义“无数据”提示
  }

  //=======================示例列表 - 岗位============================

  /// [我的发布 - 岗位] 示例列表
  Widget _buildMyPostsJobsList() {
    // 示例数据
    final jobList = [
      {
        "title": "Finance",
        "company": "Gate.io",
        "time": "37分钟前发布",
        "salary": "\$1,500-2,500",
        "tags": ["全职", "远程", "本科", "需要英语"],
        "extraTags": ["#AWS", "#Development", "#React", "#UI/UX"],
        "isFavorite": false,
      },
      {
        "title": "Backend Engineer",
        "company": "Binance",
        "time": "1小时前发布",
        "salary": "\$2,000-3,500",
        "tags": ["全职", "上海", "本科", "需要英语"],
        "extraTags": ["#Golang", "#K8s", "#Microservice"],
        "isFavorite": true,
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.only(top: 4, bottom: 16),
      itemCount: jobList.length,
      itemBuilder: (context, index) {
        final job = jobList[index];
        return _buildJobCard(job);
      },
    );
  }

  /// [我的收藏 - 岗位] 示例列表
  Widget _buildMyFavoritesJobsList() {
    final jobList = [
      {
        "title": "Product Manager",
        "company": "OKX",
        "time": "2小时前发布",
        "salary": "\$2,500-4,000",
        "tags": ["全职", "北京", "本科", "需要英语"],
        "extraTags": ["#DeFi", "#Trading", "#Crypto"],
        "isFavorite": true,
      },
    ];
    return ListView.builder(
      padding: EdgeInsets.only(top: 4, bottom: 16),
      itemCount: jobList.length,
      itemBuilder: (context, index) {
        final job = jobList[index];
        return _buildJobCard(job);
      },
    );
  }

  /// 岗位样式卡片
  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：title + salary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job["title"] ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                job["salary"] ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 第二行：company + time
          Row(
            children: [
              Text(
                job["company"] ?? "",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              Text(
                job["time"] ?? "",
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 标签
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children:
                (job["tags"] as List).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      TagUtils.formatTag(tag),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 6),
          // 额外标签
          Text(
            (job["extraTags"] as List)
                .map((tag) => TagUtils.formatTag(tag))
                .join(" "),
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 6),
          // 收藏图标
          Align(
            alignment: Alignment.centerRight,
            child:
                job["isFavorite"] == true
                    ? const Icon(Icons.star, color: Colors.orange)
                    : const Icon(Icons.star_border, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  //=======================示例列表 - 帖子============================

  /// [我的发布 - 帖子] 示例列表
  Widget _buildMyPostsForumList() {
    final forumList = [
      {
        "title": "从技术到应用：普通人的 Web3 学习手册",
        "time": "1小时前",
        "comments": 10,
        "image": "https://via.placeholder.com/150",
        "summary":
            "美国SEC前官员John Reed Stark认为，SEC对Coinbase的诉讼可能会胜诉中，因为该监管机构新成立的加密货币工作组...",
      },
      {
        "title": "如何快速上手智能合约开发",
        "time": "2小时前",
        "comments": 5,
        "image": "https://via.placeholder.com/150/cccccc",
        "summary": "合约开发中，Solidity是最流行的语言之一...",
      },
    ];
    return ListView.builder(
      padding: EdgeInsets.only(top: 4, bottom: 16),
      itemCount: forumList.length,
      itemBuilder: (context, index) {
        final post = forumList[index];
        return _buildForumCard(post);
      },
    );
  }

  /// [我的收藏 - 帖子] 示例列表
  Widget _buildMyFavoritesForumList() {
    final forumList = [
      {
        "title": "我收藏的一篇帖子",
        "time": "3小时前",
        "comments": 2,
        "image": "https://via.placeholder.com/150/aaaaaa",
        "summary": "这是我收藏的一篇帖子示例，里面可能包含一些关于区块链或Web3的心得...",
      },
    ];
    return ListView.builder(
      padding: EdgeInsets.only(top: 4, bottom: 16),
      itemCount: forumList.length,
      itemBuilder: (context, index) {
        final post = forumList[index];
        return _buildForumCard(post);
      },
    );
  }

  /// 帖子样式卡片
  Widget _buildForumCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 帖子标题
          Text(
            post['title'] ?? '',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // 摘要 + 缩略图
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  post['summary'] ?? '',
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
                  post['image'] ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 底部时间 + 评论数
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage(
                  userController.user.avatarUrl ??
                      'https://via.placeholder.com/20',
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '我不是游客',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Text(
                post['time'] ?? '',
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
}
