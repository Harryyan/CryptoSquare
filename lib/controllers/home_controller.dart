import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:cryptosquare/rest_service/bitpush_client.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/util/language_management.dart';
import 'package:cryptosquare/views/page_login.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Banner;

class HomeController extends GetxController {
  final RestClient _restClient = RestClient();
  final BitpushClient _bitpushClient = BitpushClient(Dio());
  final BitpushNewsClient _bitpushNewsClient = BitpushNewsClient();
  // 使用自定义的BitpushClient实现，处理字符串响应
  final RxList<Banner> banners = <Banner>[].obs;
  final RxList<ServiceItem> services = <ServiceItem>[].obs;
  final RxList<JobPost> jobs = <JobPost>[].obs;
  final RxList<NewsItem> news = <NewsItem>[].obs;
  final RxInt currentNewsPage = 1.obs;
  final RxBool isLoadingMoreNews = false.obs;
  final RxBool hasMoreNews = true.obs;
  final RxInt currentTabIndex = 0.obs;
  final RxInt currentServiceTabIndex = 0.obs;
  final RxInt currentBannerIndex = 0.obs;
  final RxBool isBannersLoading = true.obs;
  final RxBool isServicesLoading = true.obs;
  final RxBool isJobsLoading = true.obs;
  final RxBool isNewsLoading = true.obs;
  final RxBool isLoading = true.obs;
  final RxBool isNetworkError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllDataProgressively();
  }

  // 渐进式加载 - 关键性能优化
  void loadAllDataProgressively() {
    isLoading.value = true;
    isNetworkError.value = false;
    
    // 重置各个模块加载状态
    isBannersLoading.value = true;
    isServicesLoading.value = true;
    isJobsLoading.value = true;
    isNewsLoading.value = true;

    // 优先级1: 立即加载轻量级且重要的数据(Banner + Services)
    _loadCriticalData();
    
    // 优先级2: 延迟100ms加载次要数据，避免阻塞UI
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadSecondaryData();
    });
    
    // 检查是否所有基础数据加载完成(Banner + Services)
    Future.delayed(const Duration(milliseconds: 50), () {
      _checkInitialLoadingComplete();
    });
  }

  void _loadCriticalData() {
    // 并行加载关键数据
    _fetchBannersAsync();
    _fetchServicesAsync();
  }

  void _loadSecondaryData() {
    // 并行加载次要数据
    _fetchJobsAsync();
    _fetchNewsAsync();
  }

  void _checkInitialLoadingComplete() {
    // 每200ms检查一次，直到关键数据加载完成或超时
    int checkCount = 0;
    const maxChecks = 25; // 5秒超时
    
    void checkStatus() {
      checkCount++;
      
      // 如果Banner和Services都加载完成，或者超时
      if ((!isBannersLoading.value && !isServicesLoading.value) || 
          checkCount >= maxChecks) {
        isLoading.value = false;
        
        // 检查是否所有关键数据都失败了
        if (banners.isEmpty && services.isEmpty && checkCount >= 5) {
          isNetworkError.value = true;
        }
        return;
      }
      
      // 继续检查
      Future.delayed(const Duration(milliseconds: 200), checkStatus);
    }
    
    checkStatus();
  }

  // 兼容旧的方法名
  void loadAllData() {
    loadAllDataProgressively();
  }

  // 原来的方法保留，但改为私有，并返回Future
  Future<void> _fetchBannersAsync() {
    isBannersLoading.value = true;
    
    // 从API获取Banner数据
    return _restClient
        .getBanners(0, 'h5')
        .then((response) {
          if (response.data?.h5 != null && response.data!.h5!.isNotEmpty) {
            final apiBanners = response.data!.h5!;
            banners.value =
                apiBanners
                    .map(
                      (apiBanner) => Banner(
                        id: apiBanner.id ?? 0,
                        imageUrl: apiBanner.img ?? '',
                        title: apiBanner.title ?? '',
                        link: apiBanner.link ?? '',
                      ),
                    )
                    .toList();
          }
          isBannersLoading.value = false;
        })
        .catchError((error) {
          print('获取Banner数据失败: $error');
          banners.value = [];
          isBannersLoading.value = false;
          return Future.value();
        });
  }

  // 保留公共方法用于手动刷新
  void fetchBanners() {
    _fetchBannersAsync();
  }

  Future<void> _fetchServicesAsync() {
    isServicesLoading.value = true;
    
    // 从API获取服务项目数据
    return _restClient
        .getHomeServices()
        .then((response) {
          if (response.data != null && response.data!.isNotEmpty) {
            final apiServices = response.data!;
            services.value =
                apiServices
                    .map(
                      (apiService) => ServiceItem(
                        id: apiService.id ?? 0,
                        title: apiService.title ?? '',
                        description: apiService.intro ?? '',
                        iconUrl: apiService.icon ?? '',
                        link: apiService.redirectLink ?? '',
                      ),
                    )
                    .toList();
          }
          isServicesLoading.value = false;
        })
        .catchError((error) {
          print('获取服务项目数据失败: $error');
          services.value = [];
          isServicesLoading.value = false;
          return Future.value();
        });
  }

  // 保留公共方法用于手动刷新
  void fetchServices() {
    _fetchServicesAsync();
  }

  // 保留公共方法用于手动刷新
  void fetchJobs() {
    _fetchJobsAsync();
  }

  // 保留公共方法用于手动刷新
  void fetchNews() {
    // 重置分页状态并获取第一页数据
    currentNewsPage.value = 1;
    hasMoreNews.value = true;
    news.clear();
    _fetchNewsAsync();
  }

  // 加载更多新闻数据
  void loadMoreNews() {
    if (!isLoadingMoreNews.value && hasMoreNews.value) {
      isLoadingMoreNews.value = true;
      currentNewsPage.value++;
      _fetchNewsAsync(isLoadMore: true);
    }
  }

  Future<void> _fetchJobsAsync() {
    isJobsLoading.value = true;
    
    // 从API获取岗位数据
    return _restClient
        .getFeaturedJobs('h5', '30')
        .then((response) {
          if (response.data != null && response.data!.isNotEmpty) {
            final apiJobs = response.data!;
            jobs.value =
                apiJobs.map((apiJob) {
                  // 解析标签字符串为列表
                  List<String> tagsList = [];
                  if (apiJob.tags != null && apiJob.tags!.isNotEmpty) {
                    tagsList = apiJob.tags!.split(',');
                  }

                  // 构建薪资字符串
                  String salary = '';
                  if (apiJob.minSalary != null && apiJob.maxSalary != null) {
                    // 如果maxSalary为0，则显示面议
                    if (apiJob.maxSalary == 0) {
                      salary = '面议';
                    } else {
                      String currencySymbol = '';
                      if (apiJob.jobSalaryCurrency == 'usd') {
                        currencySymbol = '\$';
                      } else if (apiJob.jobSalaryCurrency == 'rmb') {
                        currencySymbol = '¥';
                      } else {
                        currencySymbol = '\$'; // 默认使用美元符号
                      }
                      salary =
                          '$currencySymbol${apiJob.minSalary}-$currencySymbol${apiJob.maxSalary}';
                    }
                  } else {
                    salary = '薪资面议';
                  }

                  // 获取创建时间
                  String? createdAt = apiJob.createdAt;

                  // 处理title，从"xxx|xxx|xxx"格式中提取第二个部分
                  String processedTitle = apiJob.jobTitle ?? '';
                  if (processedTitle.contains('|')) {
                    final titleParts = processedTitle.split('|');
                    if (titleParts.length >= 2) {
                      processedTitle = titleParts[1].trim(); // 取第二个部分并去除空格
                    }
                  }

                  // 计算发布时间（默认值，当无法从createdAt计算时使用）
                  int timeAgo = 30;

                  return JobPost(
                    id: apiJob.id ?? 0,
                    title: processedTitle, // 使用处理后的title
                    company: apiJob.jobCompany ?? '',
                    location: apiJob.jobPosition ?? '',
                    salary: salary,
                    createdAt: createdAt,
                    timeAgo: timeAgo,
                    tags: tagsList,
                    jobKey: apiJob.jobKey,
                    jobType: apiJob.jobType,
                    officeMode: apiJob.officeMode,
                    jobLang: apiJob.jobLang,
                    isFavorite: apiJob.jobIsCollect == 1,
                  );
                }).toList();
          }
          isJobsLoading.value = false;
        })
        .catchError((error) {
          print('获取岗位数据失败: $error');
          jobs.value = [];
          isJobsLoading.value = false;
          return Future.value();
        });
  }

  Future<void> _fetchNewsAsync({bool isLoadMore = false}) {
    // 从Bitpush API获取Web3动态数据，支持分页
    return _bitpushNewsClient
        .getWebNews(
          1551, // category_id
          DateTime.now().millisecondsSinceEpoch ~/ 1000, // timestamp
          currentNewsPage.value, // page
          1, // show_all
        )
        .then((response) {
          if (response.item_list != null && response.item_list!.isNotEmpty) {
            final apiNews = response.item_list!;
            final newItems =
                apiNews.map((apiNewsItem) {
                  // 计算时间差（分钟）
                  int timeAgo = 30; // 默认值
                  if (apiNewsItem.time != null) {
                    final DateTime newsTime =
                        DateTime.fromMillisecondsSinceEpoch(
                          apiNewsItem.time! * 1000,
                        );
                    final DateTime now = DateTime.now();
                    final Duration difference = now.difference(newsTime);
                    timeAgo = difference.inMinutes;
                  }

                  return NewsItem(
                    id: apiNewsItem.id ?? 0,
                    title: apiNewsItem.title ?? '',
                    source: 'BitPush',
                    timeAgo: timeAgo,
                    content: apiNewsItem.content,
                  );
                }).toList();

            // 判断是否还有更多数据
            if (newItems.isEmpty) {
              hasMoreNews.value = false;
            }

            // 如果是加载更多，则追加数据；否则替换数据
            if (isLoadMore) {
              news.addAll(newItems);
            } else {
              news.value = newItems;
            }
          } else {
            // 如果返回空数据，表示没有更多数据了
            hasMoreNews.value = false;
          }

          // 重置加载状态
          if (isLoadMore) {
            isLoadingMoreNews.value = false;
          }
        })
        .catchError((error) {
          print('获取Web3动态数据失败: $error');
          // 网络错误时不加载默认数据，保持列表为空
          if (!isLoadMore) {
            news.value = [];
          }
          // 重置加载状态
          if (isLoadMore) {
            isLoadingMoreNews.value = false;
            // 加载失败时，恢复页码
            currentNewsPage.value--;
          }
          throw error; // 重新抛出错误，让上层知道这个请求失败了
        });
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void changeServiceTab(int index) {
    currentServiceTabIndex.value = index;
  }

  void toggleFavorite(int jobId, String jobKey) {
    final index = jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = jobs[index];
      final newFavoriteStatus = !job.isFavorite;

      // 检查用户是否已登录
      if (!GStorage().getLoginStatus()) {
        // 用户未登录，显示居中对话框提示
        Get.dialog(
          AlertDialog(
            title: const Text('提示'),
            content: const Text('请先登录后再收藏岗位'),
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
        return; // 中断后续操作
      }

      // 用户已登录，调用收藏接口
      _restClient
          .collectJob(jobKey)
          .then((response) {
            // 检查响应的code字段，只有当code为0时才表示成功
            if (response.code == 0 && response.data != null) {
              // 根据返回的value值确定收藏状态
              // value为1表示收藏成功，为0表示取消收藏
              final bool isCollected = response.data?.value == 1;

              // 接口调用成功后更新UI
              jobs[index] = JobPost(
                id: job.id,
                title: job.title,
                company: job.company,
                location: job.location,
                salary: job.salary,
                timeAgo: job.timeAgo,
                createdAt: job.createdAt,
                tags: job.tags,
                jobKey: job.jobKey,
                jobType: job.jobType,
                officeMode: job.officeMode,
                jobLang: job.jobLang,
                isFavorite: isCollected,
              );
              print('收藏状态更新成功: ${isCollected ? "已收藏" : "取消收藏"}');
            } else {
              // code不为0，表示操作失败
              print(
                '收藏操作失败: code=${response.code}, message=${response.message}',
              );
              Get.snackbar(
                I18nKeyword.tip.tr,
                response.message ?? I18nKeyword.favoriteError.tr,
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            }
          })
          .catchError((error) {
            print('收藏操作失败: $error');
            // 显示错误提示
            Get.snackbar(
              I18nKeyword.tip.tr,
              I18nKeyword.favoriteError.tr,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          });
    }
  }
}
