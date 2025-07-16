import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/views/page_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:async';
import 'package:cryptosquare/views/article_list_example.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:cryptosquare/model/article_list.dart';
import 'package:cryptosquare/controllers/article_controller.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/views/post_create_view.dart';
import 'package:flutter/rendering.dart';

class ForumView extends StatefulWidget {
  const ForumView({super.key});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final RxInt currentTabIndex = 0.obs;
  final TextEditingController _searchController = TextEditingController();
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasSearchText = false.obs;
  final RxBool isNetworkAvailable = true.obs; // 网络连接状态
  final RxBool isSearching = false.obs; // 搜索状态ggg
  final RxString searchKeyword = ''.obs; // 搜索关键词

  // 防抖计时器
  Timer? _debounce;

  // WebView相关
  WebViewController? _webViewController;
  final RxInt webViewProgress = 0.obs; // WebView加载进度

  // 论坛文章数据 - 全部
  final RxList<ArticleItem> forumArticles = <ArticleItem>[].obs;
  final RxBool isLoading = true.obs; // 初始加载状态
  final RxBool isError = false.obs; // 错误状态
  final RxString errorMessage = ''.obs; // 错误信息
  final RxInt currentPage = 1.obs; // 当前页码
  final RxBool hasMoreData = true.obs; // 是否有更多数据

  // 行业动态文章数据 - cat_id: 32
  final RxList<ArticleItem> industryArticles = <ArticleItem>[].obs;
  final RxBool isIndustryLoading = false.obs; // 初始加载状态
  final RxBool isIndustryError = false.obs; // 错误状态
  final RxString industryErrorMessage = ''.obs; // 错误信息
  final RxInt industryCurrentPage = 1.obs; // 当前页码
  final RxBool hasMoreIndustryData = true.obs; // 是否有更多数据
  final RxBool industryInitialized = false.obs; // 是否已初始化

  // 闲谈天地文章数据 - cat_id: 47
  final RxList<ArticleItem> casualArticles = <ArticleItem>[].obs;
  final RxBool isCasualLoading = false.obs; // 初始加载状态
  final RxBool isCasualError = false.obs; // 错误状态
  final RxString casualErrorMessage = ''.obs; // 错误信息
  final RxInt casualCurrentPage = 1.obs; // 当前页码
  final RxBool hasMoreCasualData = true.obs; // 是否有更多数据
  final RxBool casualInitialized = false.obs; // 是否已初始化

  // RestClient实例
  late RestClient _restClient;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 初始化RestClient
    _restClient = RestClient();

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        currentTabIndex.value = _tabController.index;

        // 根据当前标签加载相应数据（仅首次加载）
        switch (currentTabIndex.value) {
          case 1: // 行业动态
            if (!industryInitialized.value) {
              _loadIndustryArticles();
              industryInitialized.value = true;
            }
            break;
          case 2: // 闲谈天地
            if (!casualInitialized.value) {
              _loadCasualArticles();
              casualInitialized.value = true;
            }
            break;
          case 3: // 加密百科
            _checkNetworkAndLoadWebView();
            break;
        }
      }
    });

    // 加载论坛文章数据
    _loadForumArticles();
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
              // 检查用户是否已登录
              final userController = Get.find<UserController>();
              if (!userController.isLoggedIn) {
                // 用户未登录，显示居中对话框提示
                Get.dialog(
                  AlertDialog(
                    title: const Text('提示'),
                    content: const Text('请先登录后再发布动态'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // 用户点击取消，关闭对话框
                          Get.back();
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // 用户点击去登录，关闭对话框后跳转到登录页面
                          Get.back();
                          // 跳转到登录页面
                          Get.to(() => const LoginPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('去登录'),
                      ),
                    ],
                  ),
                  barrierDismissible: true, // 允许用户点击外部关闭对话框
                );
                return;
              }

              // 用户已登录，导航到发布动态页面
              Get.to(() => const PostCreateView())?.then((result) {
                // 如果发布成功，刷新论坛列表
                if (result == true) {
                  _loadForumArticles();
                }
              });
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

  // 初始化WebView控制器
  void _initWebViewController() {
    // 添加一个标志，表示是否是初始加载
    bool isInitialLoad = true;

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
                  isInitialLoad = false; // 已经开始加载，不再是初始状态
                }
              },
              onPageStarted: (String url) {
                webViewProgress.value = 0;
                isNetworkAvailable.value = true; // 页面开始加载，网络应该是可用的
                isInitialLoad = false; // 已经开始加载，不再是初始状态
              },
              onPageFinished: (String url) {
                webViewProgress.value = 100;
                isNetworkAvailable.value = true; // 页面加载完成，网络是可用的
                isInitialLoad = false; // 已经完成加载，不再是初始状态
              },
              onWebResourceError: (WebResourceError error) {
                print(
                  'WebView error: ${error.description} (${error.errorCode})',
                );

                // 根据错误类型判断网络状态
                if (error.description.contains('SocketException') ||
                    error.description.contains('Connection refused') ||
                    error.description.contains('net::ERR_') ||
                    error.description.contains('Failed host lookup')) {
                  // 只有在初始加载时才更新状态和显示错误
                  if (isInitialLoad) {
                    webViewProgress.value = 0;
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
                }
              },
            ),
          )
          ..loadRequest(
            Uri.parse('https://www.cryptosquare.org/wiki-panel?lng=zh-CN'),
          );

    // 保存控制器引用
    _webViewController = controller;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel(); // 取消防抖计时器
    super.dispose();
  }

  // 加载论坛文章数据 - 全部分类
  Future<void> _loadForumArticles() async {
    try {
      // 如果是第一页，显示加载状态
      if (currentPage.value == 1) {
        isLoading.value = true;
      }

      // 如果是搜索，显示搜索状态
      if (searchKeyword.value.isNotEmpty) {
        isSearching.value = true;
      }

      isError.value = false;
      errorMessage.value = '';

      // 获取平台信息
      String platform = 'ios';
      if (Platform.isAndroid) {
        platform = 'android';
      }

      // 调用RestClient的getArticleList API获取论坛文章
      final response = await _restClient.getArticleList(
        0, // cat_id: 0表示全部分类
        30, // page_size: 每页30条
        currentPage.value, // page: 当前页码
        GStorage().getLanguageCN() ? 1 : 0, // lang: 1是中文，0是英文
        platform,
        searchKeyword.value, // 传入搜索关键词
      );

      // 处理响应数据
      if (response.data?.data != null && response.data!.data!.isNotEmpty) {
        // 如果是第一页，清空现有数据
        if (currentPage.value == 1) {
          forumArticles.clear();
        }

        // 添加新数据
        forumArticles.addAll(response.data!.data!);

        // 更新分页信息
        hasMoreData.value =
            response.data!.total != null &&
            forumArticles.length < response.data!.total!;
      } else {
        // 没有数据
        if (currentPage.value == 1) {
          forumArticles.clear();
        }
        hasMoreData.value = false;
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = '加载失败: $e';
      print('加载论坛文章失败: $e');
    } finally {
      isLoading.value = false;
      isSearching.value = false;
      isLoadingMore.value = false;
    }
  }

  // 加载行业动态文章数据 - cat_id: 32
  Future<void> _loadIndustryArticles() async {
    try {
      // 如果是第一页，显示加载状态
      if (industryCurrentPage.value == 1) {
        isIndustryLoading.value = true;
      }

      // 如果是搜索，显示搜索状态
      if (searchKeyword.value.isNotEmpty) {
        isSearching.value = true;
      }

      isIndustryError.value = false;
      industryErrorMessage.value = '';

      // 获取平台信息
      String platform = 'ios';
      if (Platform.isAndroid) {
        platform = 'android';
      }

      // 调用RestClient的getArticleList API获取行业动态文章
      final response = await _restClient.getArticleList(
        32, // cat_id: 32表示行业动态分类
        30, // page_size: 每页30条
        industryCurrentPage.value, // page: 当前页码
        GStorage().getLanguageCN() ? 1 : 0, // lang: 1是中文，0是英文
        platform,
        searchKeyword.value, // 传入搜索关键词
      );

      // 处理响应数据
      if (response.data?.data != null && response.data!.data!.isNotEmpty) {
        // 如果是第一页，清空现有数据
        if (industryCurrentPage.value == 1) {
          industryArticles.clear();
        }

        // 添加新数据
        industryArticles.addAll(response.data!.data!);

        // 更新分页信息
        hasMoreIndustryData.value =
            response.data!.total != null &&
            industryArticles.length < response.data!.total!;
      } else {
        // 没有数据
        if (industryCurrentPage.value == 1) {
          industryArticles.clear();
        }
        hasMoreIndustryData.value = false;
      }
    } catch (e) {
      isIndustryError.value = true;
      industryErrorMessage.value = '加载失败: $e';
      print('加载行业动态文章失败: $e');
    } finally {
      isIndustryLoading.value = false;
      isSearching.value = false;
      isLoadingMore.value = false;
    }
  }

  // 加载闲谈天地文章数据 - cat_id: 47
  Future<void> _loadCasualArticles() async {
    try {
      // 如果是第一页，显示加载状态
      if (casualCurrentPage.value == 1) {
        isCasualLoading.value = true;
      }

      // 如果是搜索，显示搜索状态
      if (searchKeyword.value.isNotEmpty) {
        isSearching.value = true;
      }

      isCasualError.value = false;
      casualErrorMessage.value = '';

      // 获取平台信息
      String platform = 'ios';
      if (Platform.isAndroid) {
        platform = 'android';
      }

      // 调用RestClient的getArticleList API获取闲谈天地文章
      final response = await _restClient.getArticleList(
        47, // cat_id: 47表示闲谈天地分类
        30, // page_size: 每页30条
        casualCurrentPage.value, // page: 当前页码
        GStorage().getLanguageCN() ? 1 : 0, // lang: 1是中文，0是英文
        platform,
        searchKeyword.value, // 传入搜索关键词
      );

      // 处理响应数据
      if (response.data?.data != null && response.data!.data!.isNotEmpty) {
        // 如果是第一页，清空现有数据
        if (casualCurrentPage.value == 1) {
          casualArticles.clear();
        }

        // 添加新数据
        casualArticles.addAll(response.data!.data!);

        // 更新分页信息
        hasMoreCasualData.value =
            response.data!.total != null &&
            casualArticles.length < response.data!.total!;
      } else {
        // 没有数据
        if (casualCurrentPage.value == 1) {
          casualArticles.clear();
        }
        hasMoreCasualData.value = false;
      }
    } catch (e) {
      isCasualError.value = true;
      casualErrorMessage.value = '加载失败: $e';
      print('加载闲谈天地文章失败: $e');
    } finally {
      isCasualLoading.value = false;
      isSearching.value = false;
      isLoadingMore.value = false;
    }
  }

  // 下拉刷新
  Future<void> _onRefresh() async {
    isRefreshing.value = true;

    // 根据当前标签选择刷新的数据源
    switch (currentTabIndex.value) {
      case 0: // 全部
        // 重置分页参数
        currentPage.value = 1;
        // 加载第一页数据
        await _loadForumArticles();
        break;
      case 1: // 行业动态
        // 重置分页参数
        industryCurrentPage.value = 1;
        // 加载第一页数据
        await _loadIndustryArticles();
        break;
      case 2: // 闲谈天地
        // 重置分页参数
        casualCurrentPage.value = 1;
        // 加载第一页数据
        await _loadCasualArticles();
        break;
    }

    isRefreshing.value = false;
  }

  // 上拉加载更多
  Future<void> _onLoadMore() async {
    // 根据当前标签选择加载更多的数据源
    switch (currentTabIndex.value) {
      case 0: // 全部
        if (isLoadingMore.value || !hasMoreData.value) return;
        isLoadingMore.value = true;
        // 增加页码
        currentPage.value++;
        // 加载更多数据
        await _loadForumArticles();
        break;
      case 1: // 行业动态
        if (isLoadingMore.value || !hasMoreIndustryData.value) return;
        isLoadingMore.value = true;
        // 增加页码
        industryCurrentPage.value++;
        // 加载更多数据
        await _loadIndustryArticles();
        break;
      case 2: // 闲谈天地
        if (isLoadingMore.value || !hasMoreCasualData.value) return;
        isLoadingMore.value = true;
        // 增加页码
        casualCurrentPage.value++;
        // 加载更多数据
        await _loadCasualArticles();
        break;
    }

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
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
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
    return Obx(
      () =>
          currentTabIndex.value == 3
              ? const SizedBox.shrink() // 如果当前是加密百科标签，则不显示搜索栏
              : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F7FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            // 搜索图标，搜索中显示加载动画
                            Obx(
                              () =>
                                  isSearching.value
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CupertinoActivityIndicator(
                                          radius: 10,
                                          color: Colors.grey[400],
                                        ),
                                      )
                                      : Icon(
                                        Icons.search,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  hasSearchText.value = value.isNotEmpty;

                                  // 防抖处理，避免频繁请求
                                  if (_debounce?.isActive ?? false)
                                    _debounce?.cancel();

                                  // 如果输入为空，重置搜索
                                  if (value.isEmpty) {
                                    searchKeyword.value = '';
                                    _resetSearch();
                                    return;
                                  }

                                  // 至少2个字符才触发搜索
                                  if (value.length < 2) return;

                                  // 设置防抖，500ms后触发搜索
                                  _debounce = Timer(
                                    const Duration(milliseconds: 500),
                                    () {
                                      searchKeyword.value = value;
                                      _performSearch();
                                    },
                                  );
                                },
                                textAlignVertical:
                                    TextAlignVertical.center, // 确保文字垂直居中
                                decoration: InputDecoration(
                                  hintText: '搜索',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, // 调整垂直padding为0
                                  ),
                                  isDense: true, // 使输入框更紧凑
                                ),
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
                                            searchKeyword.value = '';
                                            _resetSearch();
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
              ),
    );
  }

  // 执行搜索
  void _performSearch() {
    // 根据当前标签执行搜索
    switch (currentTabIndex.value) {
      case 0: // 全部
        currentPage.value = 1;
        _loadForumArticles();
        break;
      case 1: // 行业动态
        industryCurrentPage.value = 1;
        _loadIndustryArticles();
        break;
      case 2: // 闲谈天地
        casualCurrentPage.value = 1;
        _loadCasualArticles();
        break;
    }
  }

  // 重置搜索
  void _resetSearch() {
    // 根据当前标签重置搜索
    switch (currentTabIndex.value) {
      case 0: // 全部
        currentPage.value = 1;
        _loadForumArticles();
        break;
      case 1: // 行业动态
        industryCurrentPage.value = 1;
        _loadIndustryArticles();
        break;
      case 2: // 闲谈天地
        casualCurrentPage.value = 1;
        _loadCasualArticles();
        break;
    }
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
        return _buildForumList(0); // 全部
      case 1:
        return _buildForumList(1); // 行业动态
      case 2:
        return _buildForumList(2); // 闲谈天地
      case 3:
        return _buildEncyclopediaWebView(); // 加密百科
      default:
        return _buildForumList(0);
    }
  }

  // 论坛列表
  Widget _buildForumList(int tabIndex) {
    // 根据标签选择对应的数据源和状态
    late RxList<ArticleItem> articleList;
    late RxBool isLoadingState;
    late RxBool isErrorState;
    late RxString errorMessageState;
    late RxBool hasMoreDataState;

    switch (tabIndex) {
      case 0: // 全部
        articleList = forumArticles;
        isLoadingState = isLoading;
        isErrorState = isError;
        errorMessageState = errorMessage;
        hasMoreDataState = hasMoreData;
        break;
      case 1: // 行业动态
        articleList = industryArticles;
        isLoadingState = isIndustryLoading;
        isErrorState = isIndustryError;
        errorMessageState = industryErrorMessage;
        hasMoreDataState = hasMoreIndustryData;
        break;
      case 2: // 闲谈天地
        articleList = casualArticles;
        isLoadingState = isCasualLoading;
        isErrorState = isCasualError;
        errorMessageState = casualErrorMessage;
        hasMoreDataState = hasMoreCasualData;
        break;
      default:
        articleList = forumArticles;
        isLoadingState = isLoading;
        isErrorState = isError;
        errorMessageState = errorMessage;
        hasMoreDataState = hasMoreData;
    }

    return Container(
      color: const Color(0xFFF4F7FD), // 添加背景色
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!isLoadingMore.value &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              _onLoadMore();
            }
            return false;
          },
          child: Obx(() {
            if (isLoadingState.value && articleList.isEmpty) {
              // 首次加载显示加载指示器
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (isErrorState.value && articleList.isEmpty) {
              // 显示错误信息
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessageState.value,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        '重试',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (articleList.isEmpty) {
              // 检查是否有搜索关键词，如果有则显示搜索无结果页面
              if (searchKeyword.value.isNotEmpty) {
                return _buildForumEmptyState();
              }
              // 没有搜索时显示普通的无内容页面
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无内容',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂时没有相关文章',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // 显示文章列表
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 70), // 为底部发布按钮留出空间
              itemCount:
                  articleList.length +
                  (isLoadingMore.value || hasMoreDataState.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == articleList.length) {
                  // 底部加载更多指示器
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                          isLoadingMore.value
                              ? const CircularProgressIndicator()
                              : hasMoreDataState.value
                              ? TextButton(
                                onPressed: _onLoadMore,
                                child: const Text('加载更多'),
                              )
                              : Text(
                                '没有更多内容了',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                    ),
                  );
                }
                return _buildForumCard(articleList[index]);
              },
            );
          }),
        ),
      ),
    );
  }

  // 论坛无结果页面
  Widget _buildForumEmptyState() {
    return Container(
      color: const Color(0xFFF4F7FD), // 添加与列表相同的背景色
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100), // 向上偏移，避免过于靠下
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // 确保水平居中对齐
            children: [
              // 使用search_result.png作为背景图标
              Image.asset(
                'assets/images/search_result.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20), // 减少间距使更紧凑
              // 底部提示文字
              Text(
                '没有符合的帖子',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center, // 确保文字居中
              ),
            ],
          ),
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
                      // 错误视图 - 只在初始加载时显示网络错误
                      Obx(
                        () =>
                            !isNetworkAvailable.value &&
                                    currentTabIndex.value == 3 &&
                                    webViewProgress.value == 0
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
  Widget _buildForumCard(ArticleItem article) {
    // 获取文章图片，从cover字段
    final String? imageUrl = article.cover;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    // 获取用户头像，从extension.auth.avatar字段
    final String? avatarUrl = article.extension?.auth?.avatar;
    final bool hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    // 处理文章内容，去除HTML标签
    String contentText = '';
    if (article.content != null && article.content!.isNotEmpty) {
      // 简单处理HTML标签
      contentText = article.content!.replaceAll(RegExp(r'<[^>]*>'), '');
      // 去除多余的空白字符
      contentText = contentText.replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    // 使用InkWell包装整个卡片，添加点击事件
    return InkWell(
      onTap: () {
        // 使用ArticleController导航到文章详情页面
        ArticleController().navigateToArticleDetail(
          context,
          article.id.toString(),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文章标题 - 单独占一行并左对齐
            Text(
              article.title ?? '',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // 文章内容区域 - 左侧封面图片，右侧文章描述
            if (hasImage || contentText.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧封面图片
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imageUrl!,
                        height: 80,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 80,
                            width: 120,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),

                  // 图片与内容之间的间距
                  if (hasImage && contentText.isNotEmpty)
                    const SizedBox(width: 12),

                  // 右侧文章内容文字（或无图片时从左侧开始）
                  if (contentText.isNotEmpty)
                    Expanded(
                      child: Text(
                        contentText,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),

            // 内容区域下方间距
            if (hasImage || contentText.isNotEmpty) const SizedBox(height: 12),

            // 分割线
            if (hasImage || contentText.isNotEmpty)
              Container(height: 1, color: const Color(0xFFF4F7FD)),

            // 分割线下方间距
            if (hasImage || contentText.isNotEmpty) const SizedBox(height: 12),

            // 底部用户信息区域
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左侧：用户头像、用户名和发布时间
                Expanded(
                  child: Row(
                    children: [
                      // 用户头像
                      if (hasAvatar)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            avatarUrl!,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                              );
                            },
                          ),
                        )
                      else
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                        ),

                      const SizedBox(width: 8),

                      // 用户名
                      Text(
                        article.extension?.auth?.nickname ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "|",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(width: 6),

                      // 发布时间
                      Text(
                        article.updatedAt ?? "",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
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
                      '${article.replyNums ?? '0'}条评论',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 解析时间戳字符串为整数
int _parseTimestamp(String timestampStr) {
  try {
    // 尝试直接解析为整数
    return int.parse(timestampStr);
  } catch (e) {
    // 如果解析失败，返回当前时间戳作为默认值
    return (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  }
}

// 格式化时间戳
String _formatTime(int timestamp) {
  final now = DateTime.now();
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  final difference = now.difference(dateTime);

  if (difference.inDays > 30) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  } else if (difference.inDays > 0) {
    return '${difference.inDays}天前';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}小时前';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}分钟前';
  } else {
    return '刚刚';
  }
}
