import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:cryptosquare/rest_service/bitpush_client.dart';
import 'dart:io';

class ForumController extends GetxController {
  // 文章列表数据
  final RxList<BitpushNewsItem> articles = <BitpushNewsItem>[].obs;

  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isNetworkError = false.obs;
  final RxBool hasMore = true.obs;

  // 当前页码
  final RxInt currentPage = 1.obs;

  // 语言设置 (0: 中文, 1: 英文)
  final RxInt language = 0.obs;

  // BitPush客户端
  late BitpushClient _bitpushClient;

  @override
  void onInit() {
    super.onInit();
    _initBitpushClient();
    loadArticles();
  }

  // 初始化BitPush客户端
  void _initBitpushClient() {
    final dioInstance = dio.Dio();
    _bitpushClient = BitpushClient(dioInstance);
  }

  // 加载文章列表
  Future<void> loadArticles({bool refresh = true}) async {
    try {
      // 如果是刷新，重置页码和状态
      if (refresh) {
        currentPage.value = 1;
        isLoading.value = true;
        isNetworkError.value = false;
        hasMore.value = true;
      } else {
        // 如果是加载更多，更新加载更多状态
        isLoadingMore.value = true;
      }

      // 获取平台信息
      String platform = 'ios';
      if (Platform.isAndroid) {
        platform = 'android';
      }

      // 构建请求参数
      final Map<String, dynamic> params = {
        'm': 'get_article_list',
        'cat_id': 0, // 0表示全部分类
        'page': currentPage.value,
        'page_size': 30, // 默认每页30条
        'lang': language.value, // 0是中文，1是英文
        'platform': platform,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      // 创建FormData对象
      final formData = dio.FormData.fromMap(params);

      // 发送请求
      final response = await _bitpushClient.getArticleList(formData);

      // 处理响应数据
      if (response.item_list != null) {
        if (refresh) {
          // 刷新时替换数据
          articles.value = response.item_list!;
        } else {
          // 加载更多时追加数据
          articles.addAll(response.item_list!);
        }

        // 更新分页信息
        currentPage.value++;
        hasMore.value = response.has_more ?? false;
      } else {
        // 无数据时
        if (refresh) {
          articles.clear();
        }
        hasMore.value = false;
      }
    } catch (e) {
      // 处理错误
      isNetworkError.value = true;
      print('加载文章列表失败: $e');
    } finally {
      // 更新状态
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // 刷新文章列表
  Future<void> refreshArticles() async {
    await loadArticles(refresh: true);
  }

  // 加载更多文章
  Future<void> loadMoreArticles() async {
    if (!isLoadingMore.value && !isLoading.value && hasMore.value) {
      await loadArticles(refresh: false);
    }
  }

  // 切换语言
  void toggleLanguage(int lang) {
    if (language.value != lang) {
      language.value = lang;
      refreshArticles();
    }
  }
}
