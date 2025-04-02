import 'package:get/get.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:cryptosquare/rest_service/bitpush_client.dart';
import 'package:dio/dio.dart';

class HomeController extends GetxController {
  final RestClient _restClient = RestClient(Dio());
  final BitpushClient _bitpushClient = BitpushClient(Dio());
  // 使用自定义的BitpushClient实现，处理字符串响应
  final RxList<Banner> banners = <Banner>[].obs;
  final RxList<ServiceItem> services = <ServiceItem>[].obs;
  final RxList<JobPost> jobs = <JobPost>[].obs;
  final RxList<NewsItem> news = <NewsItem>[].obs;
  final RxInt currentTabIndex = 0.obs;
  final RxInt currentServiceTabIndex = 0.obs;
  final RxInt currentBannerIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isNetworkError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  void loadAllData() {
    isLoading.value = true;
    isNetworkError.value = false;

    // 使用Future.wait等待所有数据加载完成，但允许部分失败
    Future.wait([
          _fetchBannersAsync().catchError((error) {
            print('Banner加载失败: $error');
            return null; // 返回null而不是重新抛出错误
          }),
          _fetchServicesAsync().catchError((error) {
            print('Services加载失败: $error');
            return null;
          }),
          _fetchJobsAsync().catchError((error) {
            print('Jobs加载失败: $error');
            return null;
          }),
          _fetchNewsAsync().catchError((error) {
            print('News加载失败: $error');
            return null;
          }),
        ])
        .then((results) {
          // 检查是否所有请求都失败了
          // 注意：我们的_fetchXxxAsync方法即使在出错时也会返回Future.value()而不是null
          // 所以我们需要检查是否有任何成功的数据加载
          bool anyDataLoaded =
              banners.isNotEmpty ||
              services.isNotEmpty ||
              jobs.isNotEmpty ||
              news.isNotEmpty;
          isNetworkError.value = !anyDataLoaded;
          isLoading.value = false;
        })
        .catchError((error) {
          print('数据加载出错: $error');
          isLoading.value = false;
          isNetworkError.value = true;
        });
  }

  // 原来的方法保留，但改为私有，并返回Future
  Future<void> _fetchBannersAsync() {
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
        })
        .catchError((error) {
          print('获取Banner数据失败: $error');
          // 加载失败时使用默认数据
          banners.value = [
            Banner(
              id: 1,
              imageUrl: 'https://via.placeholder.com/800x200?text=Banner+1',
              title: 'Web3 开发者社区',
              link: '/community',
            ),
          ];
          // 不再抛出错误，而是返回成功，这样即使这个请求失败，其他请求仍然可以继续
          return Future.value();
        });
  }

  // 保留公共方法用于手动刷新
  void fetchBanners() {
    _fetchBannersAsync();
  }

  Future<void> _fetchServicesAsync() {
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
        })
        .catchError((error) {
          print('获取服务项目数据失败: $error');
          // 加载失败时使用默认数据
          services.value = [
            ServiceItem(
              id: 1,
              title: '在线课程',
              description: '学习最前沿的Web3开发技术',
              iconUrl: 'https://via.placeholder.com/50?text=Course',
              link: '/courses',
            ),
            ServiceItem(
              id: 2,
              title: '运营转型',
              description: '为你的团队提供专业的转型服务',
              iconUrl: 'https://via.placeholder.com/50?text=Transform',
              link: '/transform',
            ),
          ];
          // 不再抛出错误，而是返回成功
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
    _fetchNewsAsync();
  }

  Future<void> _fetchJobsAsync() {
    // 从API获取岗位数据
    return _restClient
        .getFeaturedJobs('h5')
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

                  // 计算发布时间（默认值，当无法从createdAt计算时使用）
                  int timeAgo = 30;

                  return JobPost(
                    id: apiJob.id ?? 0,
                    title: apiJob.jobTitle ?? '',
                    company: apiJob.jobCompany ?? '',
                    location: apiJob.jobPosition ?? '远程',
                    salary: salary,
                    createdAt: createdAt,
                    timeAgo: timeAgo,
                    tags: tagsList,
                  );
                }).toList();
          }
        })
        .catchError((error) {
          print('获取岗位数据失败: $error');
          // 加载失败时使用默认数据
          jobs.value = [
            JobPost(
              id: 1,
              title: 'Web3 开发工程师',
              company: 'Gate.io',
              location: '远程',
              salary: '\$1,500-2,500',
              timeAgo: 37,
              tags: ['AWS', 'Development', 'React', 'UI/UX'],
            ),
          ];
          // 不再抛出错误，而是返回成功，这样即使这个请求失败，其他请求仍然可以继续
          return Future.value();
        });
  }

  // 这里不需要重复的方法声明，已在上方定义

  Future<void> _fetchNewsAsync() {
    // 从Bitpush API获取Web3动态数据
    return _bitpushClient
        .getTagnews()
        .then((response) {
          if (response.data != null && response.data!.isNotEmpty) {
            final apiNews = response.data!;
            news.value =
                apiNews
                    .map((apiNewsItem) {
                      // 解析标签字符串为列表
                      List<String> tagsList = [];
                      if (apiNewsItem.tags != null &&
                          apiNewsItem.tags!.isNotEmpty) {
                        tagsList = apiNewsItem.tags!.split(',');
                      }

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
                        tags: tagsList,
                      );
                    })
                    .toList()
                    .take(20)
                    .toList(); // 只显示前20条数据
          }
        })
        .catchError((error) {
          print('获取Web3动态数据失败: $error');
          // 加载失败时使用默认数据
          news.value = [
            NewsItem(
              id: 1,
              title: '美国财政部长贝森特：目前对政府效率部和财政部存在"大量不实的信息"',
              source: 'CryptoNews',
              timeAgo: 2,
              tags: ['Web3', 'Technology', 'Trend'],
            ),
            NewsItem(
              id: 2,
              title: '区块链在金融领域的应用',
              source: 'BlockchainDaily',
              timeAgo: 5,
              tags: ['Blockchain', 'Finance', 'Application'],
            ),
          ];
          // 不再抛出错误，而是返回成功，这样即使这个请求失败，其他请求仍然可以继续
          return Future.value();
        });
  }

  // 这里不需要重复的方法声明，已在上方定义

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void changeServiceTab(int index) {
    currentServiceTabIndex.value = index;
  }

  void toggleFavorite(int jobId) {
    final index = jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = jobs[index];
      jobs[index] = JobPost(
        id: job.id,
        title: job.title,
        company: job.company,
        location: job.location,
        salary: job.salary,
        timeAgo: job.timeAgo,
        createdAt: job.createdAt,
        tags: job.tags,
        isFavorite: !job.isFavorite,
      );
    }
  }
}
