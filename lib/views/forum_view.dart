import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:cryptosquare/views/article_list_example.dart';

class ForumView extends StatefulWidget {
  const ForumView({super.key});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RxInt currentTabIndex = 0.obs;
  final TextEditingController _searchController = TextEditingController();
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasSearchText = false.obs;
  final RxBool isNetworkAvailable = true.obs; // 网络连接状态

  // WebView相关
  WebViewController? _webViewController;
  final RxInt webViewProgress = 0.obs; // WebView加载进度

  // 模拟的论坛数据
  final RxList<Map<String, dynamic>> forumList =
      [
        {
          "title": "从技术到应用：普通人的 Web3 学习手册",
          "time": "1小时前",
          "comments": 10,
          "image": "https://via.placeholder.com/150",
          "summary":
              "美国SEC前官员John Reed Stark认为，SEC对Coinbase的诉讼可能会胜诉中，因为该监管机构新成立的加密货币工作组...",
          "author": "我不是韭菜",
          "category": "技术应用",
        },
        {
          "title": "美国SEC前官员John Reed Stark认为，SEC对Coinbase的诉讼可能会胜诉中",
          "time": "1小时前",
          "comments": 10,
          "image": "https://via.placeholder.com/150",
          "summary":
              "美国SEC前官员John Reed Stark认为，SEC对Coinbase的诉讼可能会胜诉中，因为该监管机构新成立的加密货币工作组...",
          "author": "我不是韭菜",
          "category": "行业动态",
        },
        {
          "title": "从技术到应用：普通人的 Web3 学习手册",
          "time": "1小时前",
          "comments": 10,
          "image": "https://via.placeholder.com/150",
          "summary":
              "美国SEC前官员John Reed Stark认为，SEC对Coinbase的诉讼可能会胜诉中，因为该监管机构新成立的加密货币工作组构新成立的加密货币工作组...",
          "author": "我不是韭菜",
          "category": "闲谈天地",
        },
      ].obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        currentTabIndex.value = _tabController.index;

        // 当切换到加密百科标签时，检查网络连接
        if (currentTabIndex.value == 3) {
          _checkNetworkAndLoadWebView();
        }
      }
    });
  }

  // 检查网络连接并加载WebView
  void _checkNetworkAndLoadWebView() {
    // 如果WebView控制器已经初始化，则不需要重新创建
    if (_webViewController != null) return;

    try {
      // 尝试初始化WebView控制器
      _initWebViewController();
    } catch (e) {
      // 捕获可能的异常
      print('WebView初始化错误: $e');
      webViewProgress.value = 0;
      isNetworkAvailable.value = false;

      // 显示错误提示
      Get.snackbar(
        '加载错误',
        '无法加载网页内容，请检查网络连接',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
    }
  }

  // 初始化WebView控制器
  void _initWebViewController() {
    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                webViewProgress.value = progress;
                // 如果进度大于0，说明网络连接正常
                if (progress > 0) {
                  isNetworkAvailable.value = true;
                }
              },
              onPageStarted: (String url) {
                webViewProgress.value = 0;
                isNetworkAvailable.value = true; // 页面开始加载，网络应该是可用的
              },
              onPageFinished: (String url) {
                webViewProgress.value = 100;
                isNetworkAvailable.value = true; // 页面加载完成，网络是可用的
              },
              onWebResourceError: (WebResourceError error) {
                print(
                  'WebView error: ${error.description} (${error.errorCode})',
                );
                webViewProgress.value = 0;

                // 根据错误类型判断网络状态
                if (error.description.contains('SocketException') ||
                    error.description.contains('Connection refused') ||
                    error.description.contains('net::ERR_') ||
                    error.description.contains('Failed host lookup')) {
                  isNetworkAvailable.value = false;

                  Get.snackbar(
                    '网络连接错误',
                    '无法连接到服务器，请检查您的网络连接',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red[100],
                    colorText: Colors.red[900],
                    duration: const Duration(seconds: 3),
                  );
                }
              },
            ),
          )
          ..loadRequest(
            Uri.parse('https://www.cryptosquare.org/bbs?lng=zh-CN'),
          );

    // 保存控制器引用
    _webViewController = controller;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 下拉刷新
  Future<void> _onRefresh() async {
    isRefreshing.value = true;
    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));
    // 刷新数据
    forumList.shuffle();
    isRefreshing.value = false;
  }

  // 上拉加载更多
  Future<void> _onLoadMore() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;
    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));

    // 添加更多数据
    forumList.add({
      "title": "加载更多：Web3 发展趋势分析",
      "time": "${forumList.length + 1}小时前",
      "comments": 5,
      "image": "https://via.placeholder.com/150/cccccc",
      "summary": "这是加载的更多内容，Web3技术正在快速发展...",
      "author": "区块链爱好者",
      "category": "技术应用",
    });

    isLoadingMore.value = false;
  }

  // 导航到文章列表示例页面
  void _navigateToArticleListExample() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ArticleListExample()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 添加测试按钮
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: TextButton.icon(
                    icon: const Icon(
                      Icons.article,
                      color: AppTheme.primaryColor,
                    ),
                    label: const Text(
                      '测试文章列表',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                    onPressed: _navigateToArticleListExample,
                  ),
                ),
              ],
            ),
            _buildTabs(),
            Expanded(child: Obx(() => _buildTabContent())),
          ],
        ),
      ),
      bottomSheet: _buildBottomPublishBar(),
    );
  }

  // 搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        hasSearchText.value = value.isNotEmpty;
                      },
                      decoration: InputDecoration(
                        hintText: '学习手册',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                  Obx(
                    () =>
                        hasSearchText.value
                            ? Container(
                              width: 40,
                              child: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[400],
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  hasSearchText.value = false;
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 16,
                              ),
                            )
                            : const SizedBox(width: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 标签栏
  Widget _buildTabs() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      // margin: EdgeInsets.zero,
      child: TabBar(
        controller: _tabController,
        tabs: [
          _buildTab('全部', 0),
          _buildTab('行业动态', 1),
          _buildTab('闲谈天地', 2),
          _buildTab('加密百科', 3),
        ],
        indicator: const BoxDecoration(), // 移除默认指示器
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        // padding: EdgeInsets.zero, // 移除TabBar的内边距
        labelPadding: const EdgeInsets.only(right: 8, left: 0), // 完全移除左侧内边距
        padding: const EdgeInsets.only(left: 15, right: 8, bottom: 12, top: 8),
        indicatorPadding: const EdgeInsets.all(0),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
      ),
    );
  }

  // 单个标签
  Widget _buildTab(String text, int index) {
    return Obx(() {
      final isSelected = currentTabIndex.value == index;
      return Tab(
        height: 32,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF2563EB) : const Color(0xFFF2F5F9),
            borderRadius: BorderRadius.circular(8), // 增加圆角半径
            border: Border.all(color: Colors.transparent), // 移除边框
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600], // 调整未选中文字颜色
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }

  // 标签内容
  Widget _buildTabContent() {
    switch (currentTabIndex.value) {
      case 0:
        return _buildForumList(null); // 全部
      case 1:
        return _buildForumList('行业动态'); // 行业动态
      case 2:
        return _buildForumList('闲谈天地'); // 闲谈天地
      case 3:
        return _buildEncyclopediaWebView(); // 加密百科
      default:
        return _buildForumList(null);
    }
  }

  // 论坛列表
  Widget _buildForumList(String? category) {
    // 根据分类筛选数据
    final filteredList =
        category == null
            ? forumList
            : forumList.where((item) => item['category'] == category).toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoadingMore.value &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _onLoadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 70), // 为底部发布按钮留出空间
          itemCount: filteredList.length + (isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == filteredList.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildForumCard(filteredList[index]);
          },
        ),
      ),
    );
  }

  // 加密百科WebView
  Widget _buildEncyclopediaWebView() {
    // 如果WebView控制器未初始化，则初始化
    if (_webViewController == null) {
      _initWebViewController();
    }

    // 返回包含进度条和WebView的组件
    return Column(
      children: [
        // 加载进度条，仅在加载过程中显示
        Obx(
          () =>
              webViewProgress.value < 100 && webViewProgress.value > 0
                  ? LinearProgressIndicator(
                    value: webViewProgress.value / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF2563EB),
                    ),
                    minHeight: 3,
                  )
                  : const SizedBox.shrink(),
        ),
        // WebView组件
        Expanded(
          child:
              _webViewController == null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '正在加载...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                  : Stack(
                    children: [
                      WebViewWidget(controller: _webViewController!),
                      // 错误视图 - 当发生网络错误时显示
                      Obx(
                        () =>
                            (!isNetworkAvailable.value ||
                                        webViewProgress.value == 0) &&
                                    currentTabIndex.value == 3 &&
                                    webViewProgress.value != 100
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wifi_off,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '网络连接错误',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '无法连接到服务器，请检查您的网络连接',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // 重新加载WebView
                                          webViewProgress.value =
                                              1; // 重置进度以显示加载状态
                                          isNetworkAvailable.value =
                                              true; // 重置网络状态
                                          _webViewController?.reload();
                                        },
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          '重试',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2563EB,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  // 论坛卡片
  Widget _buildForumCard(Map<String, dynamic> post) {
    final bool hasImage = post['image'] != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题 - 单独占一行并左对齐
          Text(
            post['title'] ?? '',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // 内容摘要和图片在同一行
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧图片（如果有）
              if (hasImage) const SizedBox(width: 12),
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    post['image'],
                    height: 80,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),

              // 右侧内容摘要
              Expanded(
                child: Text(
                  post['summary'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 3, // 支持3行显示
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 底部信息区域 - 单独一行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 左侧：用户信息
              Row(
                children: [
                  // 作者头像
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // 作者名称
                  Text(
                    post['author'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 8),
                  // 发布时间
                  Text(
                    post['time'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),

              // 右侧：评论数
              Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post['comments'] ?? 0}条评论',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 底部发布栏
  Widget _buildBottomPublishBar() {
    // 获取底部安全区域高度
    return Container(
      // 高度包含内容高度(60)加上底部安全区域高度
      height: 80,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 18, // 底部padding增加安全区域高度
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/images/coin-icon.png', width: 24, height: 24),
          const SizedBox(width: 8),
          Text(
            '贡献内容可获4积分',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Spacer(flex: 6),
          ElevatedButton.icon(
            onPressed: () {
              // 发布动态逻辑
            },
            icon: Image.asset(
              'assets/images/write.png',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
            label: const Text('发布动态', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
