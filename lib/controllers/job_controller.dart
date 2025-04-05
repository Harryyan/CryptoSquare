import 'package:get/get.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:dio/dio.dart';

class JobController extends GetxController {
  final RestClient _restClient = RestClient(Dio());

  // 工作列表数据
  final RxList<JobPost> jobs = <JobPost>[].obs;

  // 搜索相关状态
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  final RxBool noResults = false.obs;
  final RxBool isLoading = false.obs;

  // 筛选条件
  final RxString selectedJobType = ''.obs;
  final RxString selectedWorkMode = ''.obs;
  final RxString selectedLanguage = ''.obs;

  // 筛选选项
  final RxList<String> jobTypes =
      <String>['长期全职', '长期兼职', '短期兼职', '无薪实习', '全职/兼职'].obs;

  final RxList<String> workModes = <String>['远程办公', '实地办公'].obs;

  final RxList<String> languages = <String>['中文', '英文'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchJobs();
  }

  // 获取工作列表
  Future<void> fetchJobs() async {
    isLoading.value = true;
    try {
      // 这里应该调用实际的API
      // 暂时使用模拟数据
      await Future.delayed(const Duration(milliseconds: 800));
      jobs.value = _getMockJobs();
      isLoading.value = false;
    } catch (e) {
      print('获取工作列表失败: $e');
      isLoading.value = false;
    }
  }

  // 搜索工作
  void searchJobs(String query) {
    searchQuery.value = query;
    hasSearched.value = true;
    isLoading.value = true;

    // 模拟搜索过程
    Future.delayed(const Duration(milliseconds: 800), () {
      if (query.isEmpty) {
        jobs.value = _getMockJobs();
        noResults.value = false;
      } else {
        final filteredJobs =
            _getMockJobs().where((job) {
              return job.title.toLowerCase().contains(query.toLowerCase()) ||
                  job.company.toLowerCase().contains(query.toLowerCase());
            }).toList();

        jobs.value = filteredJobs;
        noResults.value = filteredJobs.isEmpty;
      }
      isLoading.value = false;
    });
  }

  // 应用筛选条件
  void applyFilters() {
    isLoading.value = true;

    // 模拟筛选过程
    Future.delayed(const Duration(milliseconds: 800), () {
      final allJobs = _getMockJobs();
      final filteredJobs =
          allJobs.where((job) {
            bool matchesJobType =
                selectedJobType.isEmpty ||
                job.tags.contains(selectedJobType.value);
            bool matchesWorkMode =
                selectedWorkMode.isEmpty ||
                job.location == selectedWorkMode.value;
            // 语言要求通常会在tags中
            bool matchesLanguage =
                selectedLanguage.isEmpty ||
                job.tags.contains(selectedLanguage.value);

            return matchesJobType && matchesWorkMode && matchesLanguage;
          }).toList();

      jobs.value = filteredJobs;
      noResults.value = filteredJobs.isEmpty;
      isLoading.value = false;
    });
  }

  // 重置筛选条件
  void resetFilters() {
    selectedJobType.value = '';
    selectedWorkMode.value = '';
    selectedLanguage.value = '';

    if (searchQuery.isEmpty) {
      fetchJobs();
    } else {
      searchJobs(searchQuery.value);
    }
  }

  // 切换收藏状态
  void toggleFavorite(int jobId) {
    final index = jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = jobs[index];
      job.isFavorite = !job.isFavorite;
      jobs[index] = job;
      jobs.refresh();
    }
  }

  // 模拟数据
  List<JobPost> _getMockJobs() {
    return [
      JobPost(
        id: 1,
        title: 'Finance',
        company: 'Gate.io',
        location: '远程',
        salary: '\$1,500-2,500',
        timeAgo: 37,
        tags: ['全职', '本科', '需要英语', 'AWS', 'Development', 'React', 'UI/UX'],
        isFavorite: true,
      ),
      JobPost(
        id: 2,
        title: 'Finance',
        company: 'Gate.io',
        location: '远程',
        salary: '\$1,500-2,500',
        timeAgo: 37,
        tags: ['全职', '本科', '需要英语', 'AWS', 'Development', 'React', 'UI/UX'],
        isFavorite: false,
      ),
      JobPost(
        id: 3,
        title: 'Finance',
        company: 'Gate.io',
        location: '远程',
        salary: '\$1,500-2,500',
        timeAgo: 37,
        tags: ['全职', '本科', '需要英语', 'AWS', 'Development', 'React', 'UI/UX'],
        isFavorite: false,
      ),
      JobPost(
        id: 4,
        title: 'Finance',
        company: 'Gate.io',
        location: '远程',
        salary: '\$1,500-2,500',
        timeAgo: 37,
        tags: ['全职', '本科', '需要英语', 'AWS', 'Development', 'React', 'UI/UX'],
        isFavorite: false,
      ),
    ];
  }
}
