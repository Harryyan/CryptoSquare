import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:cryptosquare/util/language_management.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:cryptosquare/views/job_detail_view.dart';
import 'package:cryptosquare/util/storage.dart';

class JobController extends GetxController {
  final RestClient _restClient = RestClient();

  // 工作列表数据
  final RxList<JobPost> jobs = <JobPost>[].obs;
  final Rx<JobDetailData?> currentJobDetail = Rx<JobDetailData?>(null);

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

  // 获取岗位详情
  Future<void> fetchJobDetail(String jobKey) async {
    try {
      final response = await _restClient.getJobDetail(
        jobKey,
        LanguageManagement.language(), // language
        'app', // platformStr
      );

      if (response.data != null) {
        currentJobDetail.value = response.data;
      }
    } catch (e) {
      print('获取岗位详情失败: $e');
      rethrow;
    }
  }

  // 切换收藏状态
  void toggleFavorite(int jobId) {
    final index = jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = jobs[index];
      final String jobKey = job.jobKey ?? "";
      final newFavoriteStatus = !job.isFavorite;

      // 检查用户是否已登录
      if (!GStorage().getLoginStatus()) {
        // 用户未登录，显示提示信息
        Get.snackbar(
          I18nKeyword.tip.tr,
          I18nKeyword.loginToFavorite.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
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

              // 更新收藏状态
              job.isFavorite = isCollected;
              jobs[index] = job;
              jobs.refresh();

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

  // 导航到岗位详情页面
  void navigateToJobDetail(
    String jobKey, {
    String? title,
    String? company,
    String? salary,
    String? publishTime,
    List<String>? tags,
  }) async {
    // 清空当前岗位详情，以显示加载状态
    currentJobDetail.value = null;

    // 导航到岗位详情页面
    Get.to(
      () => JobDetailView(
        title: title ?? '',
        company: company ?? '',
        salary: salary ?? '',
        publishTime: publishTime ?? '',
        tags: tags ?? [],
        description: '', // 初始为空，将通过API获取
      ),
    );

    try {
      // 直接使用传入的jobKey调用API获取详细信息
      await fetchJobDetail(jobKey);

      // 如果获取失败，显示错误提示
      if (currentJobDetail.value == null) {
        Get.snackbar(
          '提示',
          '获取岗位详情失败，请稍后重试',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('导航到岗位详情页面失败: $e');
      Get.snackbar('提示', '获取岗位详情失败，请稍后重试', snackPosition: SnackPosition.BOTTOM);
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
        jobKey: 'job_1',
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
        jobKey: 'job_2',
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
        jobKey: 'job_3',
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
        jobKey: 'job_4',
        isFavorite: false,
      ),
    ];
  }
}
