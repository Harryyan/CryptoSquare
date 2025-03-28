import 'package:get/get.dart';
import 'package:cryptosquare/models/app_models.dart';

class HomeController extends GetxController {
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
    // 模拟网络请求获取Banner数据
    Future.delayed(const Duration(milliseconds: 500), () {
      banners.value = [
        Banner(
          id: 1,
          imageUrl: 'https://via.placeholder.com/800x200?text=Banner+1',
          title: 'Web3 开发者社区',
          link: '/community',
        ),
        Banner(
          id: 2,
          imageUrl: 'https://via.placeholder.com/800x200?text=Banner+2',
          title: '区块链技术交流',
          link: '/blockchain',
        ),
        Banner(
          id: 3,
          imageUrl: 'https://via.placeholder.com/800x200?text=Banner+3',
          title: '加密货币行情',
          link: '/crypto',
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
    // 模拟网络请求获取岗位数据
    Future.delayed(const Duration(milliseconds: 800), () {
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
        JobPost(
          id: 2,
          title: '区块链架构师',
          company: 'Gate.io',
          location: '远程',
          salary: '\$1,500-2,500',
          timeAgo: 37,
          tags: ['AWS', 'Development', 'React', 'UI/UX'],
        ),
        JobPost(
          id: 3,
          title: '智能合约开发',
          company: 'Gate.io',
          location: '远程',
          salary: '\$1,500-2,500',
          timeAgo: 37,
          tags: ['AWS', 'Development', 'React', 'UI/UX'],
        ),
        JobPost(
          id: 4,
          title: '产品经理',
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
    // 模拟网络请求获取动态数据
    Future.delayed(const Duration(milliseconds: 900), () {
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
        NewsItem(
          id: 3,
          title: '加密货币市场分析',
          source: 'CoinDesk',
          timeAgo: 8,
          tags: ['Crypto', 'Market', 'Analysis'],
        ),
        NewsItem(
          id: 4,
          title: 'NFT艺术品拍卖创新高',
          source: 'NFTWorld',
          timeAgo: 12,
          tags: ['NFT', 'Art', 'Auction'],
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
