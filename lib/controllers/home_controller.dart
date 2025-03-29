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

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchServices();
    fetchJobs();
    fetchNews();
  }

  void fetchBanners() {
    // 从API获取Banner数据
    _restClient
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
        });
  }

  void fetchServices() {
    // 模拟网络请求获取服务项目数据
    Future.delayed(const Duration(milliseconds: 700), () {
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
        ServiceItem(
          id: 3,
          title: '求职交流',
          description: '与行业专家交流求职经验',
          iconUrl: 'https://via.placeholder.com/50?text=Job',
          link: '/job-exchange',
        ),
        ServiceItem(
          id: 4,
          title: '1v1咨询',
          description: '获取个性化的职业规划建议',
          iconUrl: 'https://via.placeholder.com/50?text=Consult',
          link: '/consultation',
        ),
      ];
    });
  }

  void fetchJobs() {
    // 从API获取岗位数据
    _restClient
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
        });
  }

  void fetchNews() {
    // 从Bitpush API获取Web3动态数据
    _bitpushClient
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
        });
  }

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
        tags: job.tags,
        isFavorite: !job.isFavorite,
      );
    }
  }
}
