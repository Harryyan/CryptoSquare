import 'dart:async';
import 'dart:io';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:cryptosquare/util/language_management.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/views/job_detail_view.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/views/page_login.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cryptosquare/l10n/l18n_keywords.dart';

class JobController extends GetxController {
  final RestClient _restClient = RestClient();

  // 防抖计时器
  Timer? _debounce;

  // 工作列表数据
  final RxList<JobData> jobs = <JobData>[].obs;
  final Rx<JobDetailData?> currentJobDetail = Rx<JobDetailData?>(null);

  // 分页相关
  final RxInt currentPage = 1.obs;
  final RxInt totalPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isFirstLoad = true.obs;

  // 搜索相关状态
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  final RxBool noResults = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  // 筛选条件 - 支持多选
  final RxList<String> selectedJobTypes = <String>[].obs;
  final RxList<String> selectedWorkModes = <String>[].obs;
  final RxList<String> selectedLanguages = <String>[].obs;

  // 筛选选项
  final RxList<String> jobTypes =
      <String>['长期全职', '长期兼职', '短期兼职', '无薪实习', '全职/兼职'].obs;

  final RxList<String> workModes = <String>['远程办公', '实地办公'].obs;

  final RxList<String> languages = <String>['中文', '英文'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchJobs(isRefresh: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // 获取工作列表
  Future<void> fetchJobs({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      isFirstLoad.value = true;
    }

    isLoading.value = true;
    try {
      // 处理办公方式参数
      int officeMode = -1; // 默认不限
      String workModeStr = '';
      if (selectedWorkModes.isNotEmpty) {
        // 将多个办公方式转换为逗号分隔的字符串
        List<int> officeModes = [];
        for (var mode in selectedWorkModes) {
          if (mode == '远程办公') {
            officeModes.add(0);
          } else if (mode == '实地办公') {
            officeModes.add(1);
          }
        }

        // 如果只有一个选项，使用单个值
        if (officeModes.length == 1) {
          officeMode = officeModes[0];
        } else {
          // 多个选项时，使用第一个值，后续可根据API调整
          officeMode = officeModes.isNotEmpty ? officeModes[0] : -1;
          // 保存为逗号分隔的字符串，以备将来API支持
          workModeStr = selectedWorkModes.join(',');
        }
      }

      // 处理语言要求参数
      int jobLang = -1; // 默认不限
      String languageStr = '';
      if (selectedLanguages.isNotEmpty) {
        // 将多个语言要求转换为逗号分隔的字符串
        List<int> langs = [];
        for (var lang in selectedLanguages) {
          if (lang == '中文') {
            langs.add(0);
          } else if (lang == '英文') {
            langs.add(1);
          }
        }

        // 如果只有一个选项，使用单个值
        if (langs.length == 1) {
          jobLang = langs[0];
        } else {
          // 多个选项时，使用第一个值，后续可根据API调整
          jobLang = langs.isNotEmpty ? langs[0] : -1;
          // 保存为逗号分隔的字符串，以备将来API支持
          languageStr = selectedLanguages.join(',');
        }
      }

      // 处理工作类型参数
      String jobType = '';
      if (selectedJobTypes.isNotEmpty) {
        // 将多个工作类型转换为逗号分隔的字符串
        jobType = selectedJobTypes.join(',');
      }

      final response = await _restClient.getJobList(
        Platform.isAndroid ? "android" : "ios",
        pageSize: 10,
        page: currentPage.value,
        keyword: searchQuery.value,
        lang: LanguageManagement.language(),
        jobType: jobType,
        officeMode: officeMode,
        jobLang: jobLang,
      );

      if (response.code == 0 && response.data != null) {
        if (isRefresh) {
          jobs.clear();
        }

        if (response.data!.list != null) {
          jobs.addAll(response.data!.list!);
        }

        totalPage.value = response.data!.totalPage ?? 1;
        hasMore.value = currentPage.value < totalPage.value;
      } else {}

      isFirstLoad.value = false;
      isLoading.value = false;
    } catch (e) {
      print('获取工作列表失败: $e');
      isLoading.value = false;
      isFirstLoad.value = false;
    }
  }

  // 下拉刷新
  Future<void> onRefresh() async {
    await fetchJobs(isRefresh: true);
  }

  // 上拉加载更多
  Future<void> onLoading() async {
    if (hasMore.value && !isLoadingMore.value) {
      isLoadingMore.value = true;
      currentPage.value++;
      await fetchJobs(isRefresh: false);
      isLoadingMore.value = false;
    }
  }

  // 搜索工作 - 带防抖功能
  void searchJobs(String query) {
    // 取消之前的计时器
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    // 设置搜索查询
    searchQuery.value = query;

    // 如果查询为空，立即重置搜索并加载数据
    if (query.isEmpty) {
      hasSearched.value = false;
      noResults.value = false;
      fetchJobs(isRefresh: true);
      return;
    }

    // 设置防抖延迟
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // 只有当查询至少有2个字符时才执行搜索
      if (query.length >= 2) {
        isSearching.value = true;
        hasSearched.value = true;
        fetchJobs(isRefresh: true).then((_) {
          isSearching.value = false;
          // 检查是否有搜索结果
          noResults.value = jobs.isEmpty && hasSearched.value;
        });
      }
    });
  }

  // 清除搜索
  void clearSearch() {
    searchQuery.value = '';
    hasSearched.value = false;
    noResults.value = false;
    // 同时清除所有筛选条件
    selectedJobTypes.clear();
    selectedWorkModes.clear();
    selectedLanguages.clear();
    fetchJobs(isRefresh: true);
  }

  // 应用筛选条件
  void applyFilters() {
    // 设置已搜索标志，这样如果没有结果会显示空状态
    hasSearched.value = true;
    
    fetchJobs(isRefresh: true).then((_) {
      // 检查是否有筛选结果，如果没有结果则显示空状态
      noResults.value = jobs.isEmpty && hasSearched.value;
    });
  }

  // 重置筛选条件
  void resetFilters() {
    selectedJobTypes.clear();
    selectedWorkModes.clear();
    selectedLanguages.clear();
    searchQuery.value = '';
    hasSearched.value = false;
    noResults.value = false;

    fetchJobs(isRefresh: true);
  }

  // 获取岗位详情
  Future<void> fetchJobDetail(String jobKey) async {
    try {
      final response = await _restClient.getJobDetail(
        jobKey,
        LanguageManagement.language(), // language
        Platform.isAndroid ? "android" : "ios", // platformStr
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
  void toggleFavorite(int? jobId, String jobKey) {
    final index = jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = jobs[index];
      final bool isCurrentlyCollected = job.jobIsCollect == 1;

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

              // 更新收藏状态 - 创建新的JobData实例，因为jobIsCollect是final的
              final updatedJob = JobData(
                slug: job.slug,
                id: job.id,
                jobKey: job.jobKey,
                jobTitle: job.jobTitle,
                jobPosition: job.jobPosition,
                createdAt: job.createdAt,
                tags: job.tags,
                jobCompany: job.jobCompany,
                jobSalaryType: job.jobSalaryType,
                jobSalaryUnit: job.jobSalaryUnit,
                jobSalaryCurrency: job.jobSalaryCurrency,
                minSalary: job.minSalary,
                maxSalary: job.maxSalary,
                jobIsCollect: isCollected ? 1 : 0,
              );
              jobs[index] = updatedJob;
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
  void navigateToJobDetail(JobData job) async {
    String jobKey = job.jobKey ?? "";
    String title = job.jobTitle ?? "";
    String company = job.jobCompany ?? "";
    String salary =
        "${job.minSalary ?? 0}-${job.maxSalary ?? 0} ${job.jobSalaryCurrency ?? ''}";
    String publishTime = job.createdAt ?? "";
    List<String> tags = job.tags?.split(',') ?? [];
    // 清空当前岗位详情，以显示加载状态
    currentJobDetail.value = null;

    // 导航到岗位详情页面
    Get.to(
      () => JobDetailView(
        title: title,
        company: company,
        salary: salary,
        publishTime: publishTime,
        tags: tags,
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
}
