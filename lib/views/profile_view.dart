import 'dart:io';
import 'package:cryptosquare/model/user_post.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/controllers/article_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/util/tag_utils.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/util/event_bus.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/views/profile_edit_view.dart';
import 'package:cryptosquare/views/main_view.dart';
import 'package:cryptosquare/rest_service/user_client.dart';
import 'package:cryptosquare/model/collected_post.dart';
import 'package:cryptosquare/views/post_create_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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

  // 签到状态
  final RxBool isCheckedIn = false.obs;

  @override
  void initState() {
    super.initState();
    
    // 添加生命周期监听器
    WidgetsBinding.instance.addObserver(this);
    
    // TabController 仅作示例（长度4：0、1、2、3），你也可以仅用于左侧标签
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);

    currentTabIndex.value = 0; // 默认选中我的发布
    postTabIndex.value = 3; // 默认选中帖子

    // 检查签到状态
    _checkInStatus();

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

      // 当切换到我的发布+帖子标签时，加载用户发布的帖子列表
      if (currentTabIndex.value == 0 &&
          postTabIndex.value == 3 &&
          isUserLoggedIn.value) {
        _loadUserPosts(isRefresh: true);
      }

      // 当切换到我的收藏+岗位标签时，加载收藏的岗位列表
      if (currentTabIndex.value == 1 &&
          postTabIndex.value == 2 &&
          isUserLoggedIn.value) {
        _loadFavoriteJobs();
      }

      // 当切换到我的收藏+帖子标签时，加载收藏的帖子列表
      if (currentTabIndex.value == 1 &&
          postTabIndex.value == 3 &&
          isUserLoggedIn.value) {
        _loadFavoritePosts(isRefresh: true);
      }
    });

    // 从GStorage加载用户信息
    _loadUserInfo();
    
    // 每次进入页面时刷新积分
    _refreshUserScore();

    // 使用addPostFrameCallback确保在构建完成后再同步用户信息到UserController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUserInfoToController();

      // 如果用户已登录，预加载收藏的岗位列表
      if (isUserLoggedIn.value) {
        _loadFavoriteJobs();

        // 如果当前是收藏+帖子标签，预加载收藏的帖子列表
        if (currentTabIndex.value == 1 && postTabIndex.value == 3) {
          _loadFavoritePosts(isRefresh: true);
        }

        // 如果当前是我的发布+帖子标签，预加载用户发布的帖子列表
        if (currentTabIndex.value == 0 && postTabIndex.value == 3) {
          _loadUserPosts(isRefresh: true);
        }
      }
    });

    // 监听头像更新事件
    eventBus.on('avatarUpdated', (_) {
      // 当头像更新时，重新加载用户信息以更新头像显示
      _loadUserInfo();
      // 同时刷新积分
      _refreshUserScore();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 当页面依赖发生变化时（比如从其他页面返回），刷新积分
    if (mounted && GStorage().getLoginStatus()) {
      _refreshUserScore();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 当应用重新获得焦点时，刷新积分
    if (state == AppLifecycleState.resumed && mounted && GStorage().getLoginStatus()) {
      _refreshUserScore();
    }
  }

  /// 从后端刷新用户积分信息
  Future<void> _refreshUserScore() async {
    // 只有用户已登录时才刷新积分
    if (!GStorage().getLoginStatus()) {
      return;
    }

    try {
      // 调用API获取最新的用户资料（包括积分）
      final userProfile = await UserRestClient().userProfile();
      
      if (userProfile.code == 0 && userProfile.data != null) {
        // 更新积分到UI
        userScore.value = userProfile.data?.score ?? 0;
        
        // 同时更新存储中的用户信息
        Map userInfo = GStorage().getUserInfo();
        userInfo['score'] = userProfile.data?.score ?? 0;
        
        // 如果有新的头像或昵称信息，也一并更新
        if (userProfile.data?.avatar != null && userProfile.data!.avatar!.isNotEmpty) {
          userInfo['avatar'] = userProfile.data!.avatar;
          userAvatar.value = userProfile.data!.avatar!;
        }
        if (userProfile.data?.nickname != null && userProfile.data!.nickname!.isNotEmpty) {
          userInfo['userName'] = userProfile.data!.nickname;
          userName.value = userProfile.data!.nickname!;
        }
        
        // 保存更新后的用户信息
        GStorage().setUserInfo(userInfo);
        
        print('用户积分刷新成功: ${userProfile.data?.score}');
      } else {
        print('刷新用户积分失败: ${userProfile.message}');
      }
    } catch (e) {
      print('刷新用户积分异常: $e');
    }
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

      // 检查签到状态
      _checkInStatus();
    }
  }

  /// 检查签到状态
  void _checkInStatus() {
    if (isUserLoggedIn.value) {
      UserRestClient()
          .checkInStatus()
          .then((resp) {
            if (resp.code == 0 && resp.data != null) {
              isCheckedIn.value = resp.data!.isCheckIn ?? false;
            }
          })
          .catchError((error) {
            print('获取签到状态失败: $error');
          });
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
    // 移除生命周期监听器
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    // 移除事件监听
    eventBus.off('avatarUpdated');
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
                      // 显示底部菜单
                      Get.bottomSheet(
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('编辑个人信息'),
                                onTap: () {
                                  Get.back(); // 关闭底部菜单
                                  Get.to(() => const ProfileEditView());
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  '退出登录',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  Get.back(); // 关闭底部菜单
                                  // 显示确认对话框
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('退出登录'),
                                      content: const Text('确定要退出登录吗？'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // 清除用户登录信息
                                            GStorage().setLoginStatus(false);
                                            GStorage().setToken("");
                                            GStorage().setUserInfo({});

                                            // 通知其他页面用户已登出
                                            eventBus.emit('logoutSuccessful');

                                            Get.back(); // 关闭对话框
                                            Get.offAll(
                                              () => MainView(),
                                            ); // 跳转到主页
                                          },
                                          child: const Text('确认'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
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
                          '${userScore.value} 积分',
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
                child: Obx(
                  () => ElevatedButton(
                    onPressed:
                        isCheckedIn.value
                            ? null
                            : () {
                              // 点击签到
                              if (isUserLoggedIn.value) {
                                UserRestClient()
                                    .checkIn()
                                    .then((resp) {
                                      if (resp.code == 0) {
                                        // 签到成功
                                        isCheckedIn.value = true;
                                        Get.snackbar(
                                          '提示',
                                          '签到成功',
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.green[100],
                                          colorText: Colors.green[800],
                                          duration: const Duration(seconds: 2),
                                        );

                                        // 更新积分
                                        _refreshUserScore();
                                      } else {
                                        // 签到失败
                                        Get.snackbar(
                                          '提示',
                                          '签到失败: ${resp.message}',
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.red[100],
                                          colorText: Colors.red[800],
                                          duration: const Duration(seconds: 2),
                                        );
                                      }
                                    })
                                    .catchError((error) {
                                      // 签到异常
                                      Get.snackbar(
                                        '提示',
                                        '签到异常: $error',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.red[100],
                                        colorText: Colors.red[800],
                                        duration: const Duration(seconds: 2),
                                      );
                                    });
                              } else {
                                // 未登录提示
                                Get.snackbar(
                                  '提示',
                                  '请先登录',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.amber[100],
                                  colorText: Colors.amber[800],
                                  duration: const Duration(seconds: 2),
                                );
                              }
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
                      disabledBackgroundColor: Colors.grey[200],
                      disabledForegroundColor: Colors.grey[600],
                    ),
                    child: Text(
                      isCheckedIn.value ? '已签到' : '签到',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                // 当选择"我的发布"时，岗位tab文字显示为灰色
                                color:
                                    currentTabIndex.value == 0
                                        ? Colors.grey[400]
                                        : null,
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
                          // 当选择"我的发布"时，不允许切换到岗位tab
                          if (currentTabIndex.value == 0 && value == 2) {
                            return; // 不执行任何操作
                          }
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

          // 当点击"我的发布"标签时，自动切换到帖子tab
          if (index == 0) {
            postTabIndex.value = 3; // 切换到帖子tab
            // 如果用户已登录，加载用户发布的帖子列表
            if (isUserLoggedIn.value) {
              _loadUserPosts(isRefresh: true);
            }
          }
          // 当点击"我的收藏"标签且用户已登录时
          else if (index == 1 && isUserLoggedIn.value) {
            // 加载收藏的岗位列表
            _loadFavoriteJobs();

            // 如果当前选中的是帖子标签，也加载收藏的帖子列表
            if (postTabIndex.value == 3) {
              _loadFavoritePosts(isRefresh: true);
            }
          }
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
        // 如果用户已登录且收藏帖子列表为空，尝试加载数据
        if (isUserLoggedIn.value &&
            favoritePostList.isEmpty &&
            !isLoadingFavoritePosts.value &&
            !hasTriedLoadingFavoritePosts.value) {
          _loadFavoritePosts(isRefresh: true);
          hasTriedLoadingFavoritePosts.value = true;
        }
        return _buildMyFavoritesForumList();
      }
    }
    return Container(); // 默认空白，或可自定义"无数据"提示
  }

  /// [我的发布 - 帖子] 列表
  Widget _buildMyPostsForumList() {
    // 如果用户未登录，显示提示信息
    if (!isUserLoggedIn.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '请先登录后查看发布的帖子',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 添加下拉刷新和上拉加载更多功能
    return RefreshIndicator(
      onRefresh: () async {
        // 刷新用户发布的帖子列表
        currentUserPostPage.value = 1;
        await _loadUserPosts(isRefresh: true);
      },
      child: Obx(() {
        // 加载中显示进度指示器
        if (isLoadingUserPosts.value && userPostList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        // 没有发布的帖子
        if (userPostList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 50, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '暂无发布的帖子',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // 显示用户发布的帖子列表
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // 检测是否滑动到底部，加载更多数据
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                !isLoadingUserPosts.value &&
                hasMoreUserPosts.value) {
              _loadMoreUserPosts();
            }
            return false;
          },
          child: ListView.builder(
            padding: EdgeInsets.only(top: 4, bottom: 16),
            itemCount: userPostList.length + (hasMoreUserPosts.value ? 1 : 0),
            itemBuilder: (context, index) {
              // 如果是最后一个item且还有更多数据，显示加载更多
              if (index == userPostList.length && hasMoreUserPosts.value) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              // 正常显示帖子
              if (index < userPostList.length) {
                final post = userPostList[index];
                return _buildUserPostCard(post);
              }

              return Container();
            },
          ),
        );
      }),
    );
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
        "tags": ["全职", "远程", "本科", "英语"],
        "extraTags": ["#AWS", "#Development", "#React", "#UI/UX"],
        "isFavorite": false,
      },
      {
        "title": "Backend Engineer",
        "company": "Binance",
        "time": "1小时前发布",
        "salary": "\$2,000-3,500",
        "tags": ["全职", "上海", "本科", "英语"],
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
  // 收藏的岗位列表
  final RxList<Map<String, dynamic>> favoriteJobList =
      <Map<String, dynamic>>[].obs;
  // 加载状态
  final RxBool isLoadingFavoriteJobs = false.obs;

  /// [我的收藏 - 岗位] 列表
  Widget _buildMyFavoritesJobsList() {
    // 如果用户未登录，显示提示信息
    if (!isUserLoggedIn.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '请先登录后查看收藏的岗位',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 添加下拉刷新功能
    return RefreshIndicator(
      onRefresh: () async {
        // 刷新收藏岗位列表
        await _loadFavoriteJobs();
      },
      child: Obx(() {
        // 加载中显示进度指示器
        if (isLoadingFavoriteJobs.value && favoriteJobList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        // 没有收藏的岗位
        if (favoriteJobList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 50, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '暂无收藏的岗位',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // 显示收藏的岗位列表
        return ListView.builder(
          padding: EdgeInsets.only(top: 4, bottom: 16),
          itemCount: favoriteJobList.length,
          itemBuilder: (context, index) {
            final job = favoriteJobList[index];
            return _buildJobCard(job);
          },
        );
      }),
    );
  }

  /// 加载收藏的岗位列表
  Future<void> _loadFavoriteJobs() async {
    try {
      // 设置加载状态
      isLoadingFavoriteJobs.value = true;

      // 调用API获取收藏的岗位列表
      final response = await UserRestClient().getJobCollectList();

      // 检查API返回结果
      if (response.code == 0 && response.data != null) {
        // 清空现有列表
        favoriteJobList.clear();

        // 将API返回的数据转换为UI需要的格式
        for (var item in response.data!.list) {
          // 从标题中提取薪资信息
          String title = item.jobTitle;
          String salary = "";

          // 检查是否包含"薪资面议"文本
          if (title.contains("薪资面议")) {
            // 从标题中移除"薪资面议"并添加到salary字段
            salary = "薪资面议";
            title = title.replaceAll("薪资面议", "").trim();
          } else {
            // 查找薪资部分（如"$4000-$10000/月"）
            RegExp salaryRegex = RegExp(r'\$\d+(?:-\$\d+)?(?:/[^|]+)?$');
            Match? match = salaryRegex.firstMatch(title);

            if (match != null) {
              // 提取薪资部分
              salary = match.group(0) ?? "";
              // 从标题中移除薪资部分
              title = title.substring(0, match.start).trim();
            }
          }

          // 移除标题末尾的竖线符号
          if (title.endsWith("|")) {
            title = title.substring(0, title.length - 1).trim();
          }

          favoriteJobList.add({
            "title": title,
            "company": item.jobPosition,
            "time": "", // 可以根据需要调整
            "salary": salary, // 从标题中提取的薪资信息
            "extraTags": ["#${item.jobKey}"], // 使用jobKey作为额外标签
            "isFavorite": true,
          });
        }
      } else {
        // 处理API错误
        print("加载收藏岗位失败: ${response.message}");
      }
    } catch (e) {
      // 处理异常
      print("加载收藏岗位异常: $e");
    } finally {
      // 无论成功失败，都结束加载状态
      isLoadingFavoriteJobs.value = false;
    }
  }

  /// 岗位样式卡片
  Widget _buildJobCard(Map<String, dynamic> job) {
    return GestureDetector(
      onTap: () {
        // 从extraTags中提取jobKey
        String jobKey = "";
        List<String> extraTags = job["extraTags"] ?? [];
        for (String tag in extraTags) {
          if (tag.startsWith("#")) {
            jobKey = tag.substring(1); // 去掉#前缀
            break;
          }
        }

        if (jobKey.isNotEmpty) {
          // 创建一个JobData对象，用于传递给navigateToJobDetail方法
          JobData jobData = JobData(
            jobKey: jobKey,
            jobTitle: job["title"] ?? "",
            jobCompany: job["company"] ?? "",
            jobSalaryCurrency: job["salary"]?.contains("\$") ? "USD" : "RMB",
            // 其他字段可以根据需要设置
          );

          // 使用JobController跳转到岗位详情页面
          jobController.navigateToJobDetail(jobData);
        } else {
          // 如果没有找到jobKey，显示提示信息
          Get.snackbar(
            '提示',
            '无法获取岗位详情，请稍后重试',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job["title"] ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16), // 添加固定间距
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
            // 标签部分已移除，因为后台没有返回相关数据
            const SizedBox(height: 0),
            const SizedBox(height: 6),
            // // 额外标签
            // Text(
            //   (job["extraTags"] as List)
            //       .map((tag) => TagUtils.formatTag(tag))
            //       .join(" "),
            //   style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            // ),
            const SizedBox(height: 6),
            // 收藏图标
            Align(
              alignment: Alignment.centerRight,
              child:
                  job["isFavorite"] == true
                      ? Image.asset(
                        "assets/images/star_fill.png",
                        width: 20,
                        height: 20,
                      )
                      : Image.asset(
                        "assets/images/star.png",
                        width: 20,
                        height: 20,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  //=======================用户发布的帖子============================

  // 用户发布的帖子列表
  final RxList<UserPostItem> userPostList = <UserPostItem>[].obs;
  // 加载状态
  final RxBool isLoadingUserPosts = false.obs;
  // 是否还有更多数据
  final RxBool hasMoreUserPosts = true.obs;
  // 当前页码
  final RxInt currentUserPostPage = 1.obs;
  // 每页数量
  final int userPostPageSize = 20;

  //=======================收藏列表 - 帖子============================

  // 收藏的帖子列表
  final RxList<PostItem> favoritePostList = <PostItem>[].obs;
  // 加载状态
  final RxBool isLoadingFavoritePosts = false.obs;
  // 是否还有更多数据
  final RxBool hasMorePosts = true.obs;
  // 当前页码
  final RxInt currentPostPage = 1.obs;
  // 每页数量
  final int postPageSize = 20;
  // 是否已尝试加载收藏帖子
  final RxBool hasTriedLoadingFavoritePosts = false.obs;

  /// [我的收藏 - 帖子] 列表
  Widget _buildMyFavoritesForumList() {
    // 如果用户未登录，显示提示信息
    if (!isUserLoggedIn.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '请先登录后查看收藏的帖子',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 添加下拉刷新和上拉加载更多功能
    return RefreshIndicator(
      onRefresh: () async {
        // 刷新收藏帖子列表
        currentPostPage.value = 1;
        hasTriedLoadingFavoritePosts.value = false; // 重置尝试加载标志
        await _loadFavoritePosts(isRefresh: true);
      },
      child: Obx(() {
        // 加载中显示进度指示器
        if (isLoadingFavoritePosts.value && favoritePostList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        // 没有收藏的帖子
        if (favoritePostList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 50, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '暂无收藏的帖子',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // 显示收藏的帖子列表
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // 检测是否滑动到底部，加载更多数据
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                !isLoadingFavoritePosts.value &&
                hasMorePosts.value) {
              _loadMorePosts();
            }
            return false;
          },
          child: ListView.builder(
            padding: EdgeInsets.only(top: 4, bottom: 16),
            itemCount: favoritePostList.length + (hasMorePosts.value ? 1 : 0),
            itemBuilder: (context, index) {
              // 如果是最后一个item且还有更多数据，显示加载更多
              if (index == favoritePostList.length && hasMorePosts.value) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              // 正常显示帖子
              if (index < favoritePostList.length) {
                final post = favoritePostList[index];
                return _buildCollectedPostCard(post);
              }

              return Container();
            },
          ),
        );
      }),
    );
  }

  /// 加载用户发布的帖子列表
  Future<void> _loadUserPosts({bool isRefresh = false}) async {
    try {
      // 设置加载状态
      isLoadingUserPosts.value = true;

      // 调用API获取用户发布的帖子列表
      final response = await UserRestClient().getUserPosts(
        pageSize: userPostPageSize,
        page: currentUserPostPage.value,
      );

      // 检查API返回结果
      if (response.code == 0) {
        // 如果是刷新，清空现有列表
        if (isRefresh) {
          userPostList.clear();
        }

        // 添加新数据到列表（如果有的话）
        if (response.data.data.isNotEmpty) {
          userPostList.addAll(response.data.data);
          // 判断是否还有更多数据
          hasMoreUserPosts.value = userPostList.length < response.data.total;
        } else {
          // 如果返回数据为空，设置没有更多数据
          hasMoreUserPosts.value = false;
        }
      } else {
        // API返回错误
        print('加载用户发布帖子失败: ${response.message}');
        hasMoreUserPosts.value = false;
      }
    } catch (e) {
      print('加载用户发布帖子失败: $e');
      hasMoreUserPosts.value = false;
    } finally {
      // 无论成功失败，都结束加载状态
      isLoadingUserPosts.value = false;
    }
  }

  /// 加载更多用户发布的帖子
  Future<void> _loadMoreUserPosts() async {
    if (isLoadingUserPosts.value || !hasMoreUserPosts.value) return;

    // 页码加1
    currentUserPostPage.value++;
    // 加载更多数据
    await _loadUserPosts();
  }

  /// 加载收藏的帖子列表
  Future<void> _loadFavoritePosts({bool isRefresh = false}) async {
    try {
      // 设置加载状态
      isLoadingFavoritePosts.value = true;

      // 调用API获取收藏的帖子列表
      final response = await UserRestClient().getCollectedPosts(
        type: "eye",
        pageSize: postPageSize,
        page: currentPostPage.value,
      );

      // 检查API返回结果
      if (response.code == 0) {
        // 如果是刷新，清空现有列表
        if (isRefresh) {
          favoritePostList.clear();
        }

        // 添加新数据到列表（如果有的话）
        if (response.data.data.isNotEmpty) {
          favoritePostList.addAll(response.data.data);
          // 判断是否还有更多数据
          hasMorePosts.value = favoritePostList.length < response.data.total;
        } else {
          // 如果返回数据为空，设置没有更多数据
          hasMorePosts.value = false;
        }
      } else {
        // 如果API返回错误，设置没有更多数据
        hasMorePosts.value = false;
      }
    } catch (e) {
      print('加载收藏帖子失败: $e');
      // 发生异常时，设置没有更多数据
      hasMorePosts.value = false;
    } finally {
      // 无论成功失败，都结束加载状态
      isLoadingFavoritePosts.value = false;
    }
  }

  /// 加载更多收藏的帖子
  Future<void> _loadMorePosts() async {
    if (isLoadingFavoritePosts.value || !hasMorePosts.value) return;

    // 页码加1
    currentPostPage.value++;
    // 加载更多数据
    await _loadFavoritePosts();
  }

  /// 用户发布的帖子卡片
  Widget _buildUserPostCard(UserPostItem post) {
    return GestureDetector(
      onTap: () {
        // 使用ArticleController导航到文章详情页面
        ArticleController().navigateToArticleDetail(
          context,
          post.id.toString(),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 帖子标题
                Expanded(
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 编辑按钮
                if (post.status == 1) // 只有已发布的帖子才显示编辑按钮
                  GestureDetector(
                    onTap: () {
                      // 获取文章详情并跳转到编辑页面
                      _navigateToEditPost(post);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '编辑',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 分类标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                post.catName,
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 12),
            // 底部信息
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
                Text(
                  userName.value,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                // 状态标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        post.status == 0
                            ? Colors.grey.withOpacity(0.1)
                            : post.status == 1
                            ? Colors.green.withOpacity(0.1)
                            : post.status == 2
                            ? Colors.red.withOpacity(0.1)
                            : post.status == 3
                            ? Colors.grey.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    post.status == 0
                        ? '审核中'
                        : post.status == 1
                        ? '在线'
                        : post.status == 2
                        ? '审核拒绝'
                        : post.status == 3
                        ? '下线'
                        : '未知状态',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          post.status == 0
                              ? Colors.grey
                              : post.status == 1
                              ? Colors.green
                              : post.status == 2
                              ? Colors.red
                              : post.status == 3
                              ? Colors.grey
                              : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 导航到编辑帖子页面
  Future<void> _navigateToEditPost(UserPostItem post) async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // 获取文章详情
      final client = RestClient();
      final response = await client.getArticleDetail(
        post.id.toString(),
        GStorage().getLanguageCN() ? 1 : 0,
        Platform.isAndroid ? "android" : "ios",
      );

      // 关闭加载指示器
      Navigator.pop(context);

      if (response.code == 0 && response.data != null) {
        // 导航到编辑页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PostCreateView(
                  isEditMode: true,
                  articleId: post.id.toString(),
                  initialTitle: response.data!.title ?? '',
                  initialContent: response.data!.content ?? '',
                  initialCategoryId: response.data!.catId ?? 0,
                  initialTags:
                      response.data!.extension?.tag != null
                          ? _extractTagsFromList(response.data!.extension!.tag!)
                          : '',
                ),
          ),
        );
      } else {
        // 显示错误信息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message ?? '获取文章详情失败')));
      }
    } catch (e) {
      // 关闭加载指示器
      Navigator.pop(context);
      // 显示错误信息
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('网络错误: ${e.toString()}')));
    }
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

  /// 收藏的帖子卡片
  Widget _buildCollectedPostCard(PostItem post) {
    // 从内容中提取摘要，去除HTML标签
    String summary = post.content;
    // 简单处理HTML标签（实际项目中可能需要更复杂的HTML解析）
    summary = summary.replaceAll(RegExp(r'<[^>]*>'), '');
    // 限制摘要长度
    if (summary.length > 100) {
      summary = summary.substring(0, 100) + '...';
    }

    // 格式化时间
    String formattedTime = '';
    try {
      // 从Unix时间戳创建UTC时间，避免时区问题
      final DateTime postTimeUtc = DateTime.fromMillisecondsSinceEpoch(
        post.createTime * 1000,
        isUtc: true,
      );
      final DateTime nowUtc = DateTime.now().toUtc();
      final Duration difference = nowUtc.difference(postTimeUtc);

      if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        // 防止显示负数分钟
        if (minutes <= 0) {
          formattedTime = '刚刚';
        } else {
          formattedTime = '$minutes分钟前';
        }
      } else if (difference.inHours < 24) {
        formattedTime = '${difference.inHours}小时前';
      } else if (difference.inDays < 30) {
        formattedTime = '${difference.inDays}天前';
      } else {
        // 转换为本地时间显示
        final localTime = postTimeUtc.toLocal();
        formattedTime = '${localTime.year}-${localTime.month}-${localTime.day}';
      }
    } catch (e) {
      formattedTime = '未知时间';
    }

    // 获取帖子作者信息
    String authorName =
        post.extension.auth.nickname.isNotEmpty
            ? post.extension.auth.nickname
            : '匿名用户';
    String authorAvatar =
        post.extension.auth.avatar.isNotEmpty
            ? post.extension.auth.avatar
            : 'https://via.placeholder.com/20';

    return GestureDetector(
      onTap: () {
        // 使用ArticleController导航到文章详情页面
        ArticleController().navigateToArticleDetail(
          context,
          post.id.toString(),
        );
      },
      child: Container(
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
              post.title,
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
                    summary,
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
                // 如果有图片则显示，否则显示默认图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      post.extension.auth.avatar.isNotEmpty
                          ? Image.network(
                            post.extension.auth.avatar,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                          : Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 底部作者 + 时间 + 评论数
            Row(
              children: [
                // 作者头像
                CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage(authorAvatar),
                  onBackgroundImageError: (exception, stackTrace) {
                    // 头像加载失败时使用默认头像
                  },
                ),
                const SizedBox(width: 6),
                // 作者名称
                Text(
                  authorName,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 10),
                // 发布时间
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                // 评论图标和数量
                const Icon(
                  Icons.comment_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  '${post.replyNums}条评论',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _extractTagsFromList(List<dynamic> tagList) {
    List<String> tags = [];
    
    for (var tagItem in tagList) {
      if (tagItem is String) {
        // 如果直接是字符串，直接添加
        tags.add(tagItem);
      } else if (tagItem is Map<String, dynamic>) {
        // 如果是对象格式，提取 'tag' 字段的值
        if (tagItem.containsKey('tag')) {
          var tagValue = tagItem['tag'];
          if (tagValue is String) {
            tags.add(tagValue);
          }
        }
      } else {
        // 其他类型，转换为字符串（fallback）
        String tagStr = tagItem.toString();
        // 如果字符串看起来像对象格式，尝试解析
        if (tagStr.contains('tag:')) {
          RegExp regex = RegExp(r'tag:\s*([^,}]+)');
          RegExpMatch? match = regex.firstMatch(tagStr);
          if (match != null) {
            String tag = match.group(1)?.trim() ?? '';
            if (tag.isNotEmpty) {
              tags.add(tag);
            }
          }
        } else {
          tags.add(tagStr);
        }
      }
    }
    
    return tags.join(',');
  }
}
