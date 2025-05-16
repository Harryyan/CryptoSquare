import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptosquare/util/tag_utils.dart';

class JobView extends StatefulWidget {
  JobView({super.key});

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  final JobController jobController = Get.put(JobController());

  // 搜索框的文本控制器
  final TextEditingController _searchController = TextEditingController();

  // 格式化薪资为 $1,500 - $2,500 格式
  String _formatSalary(int minSalary, int maxSalary, String currency) {
    // 转换货币符号，确保大写的货币代码转为符号
    String currencySymbol = '';
    if (currency.toUpperCase() == 'USD') {
      currencySymbol = '\$';
    } else if (currency.toUpperCase() == 'RMB') {
      currencySymbol = '¥';
    } else {
      // 如果是其他货币代码，尝试转换为符号，否则使用原代码
      currencySymbol = currency;
    }

    // 添加千位分隔符
    String formattedMinSalary = minSalary.toString().replaceAllMapped(
      RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[0]},',
    );

    String formattedMaxSalary = maxSalary.toString().replaceAllMapped(
      RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[0]},',
    );

    return "$currencySymbol$formattedMinSalary - $currencySymbol$formattedMaxSalary";
  }

  @override
  void initState() {
    super.initState();
    // 初始化搜索控制器
    _searchController.text = jobController.searchQuery.value;
    // 监听搜索查询变化，更新搜索框
    jobController.searchQuery.listen((query) {
      if (_searchController.text != query) {
        _searchController.text = query;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterSection(),
          Expanded(
            child: Obx(() {
              return jobController.noResults.value
                  ? _buildEmptyState()
                  : _buildJobList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(22),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            // 直接调用搜索方法，内部已实现防抖
            jobController.searchJobs(value);
          },
          onSubmitted: (value) {
            // 提交时立即搜索
            if (value.length >= 2) {
              jobController.searchJobs(value);
            }
          },
          decoration: InputDecoration(
            hintText: '请输入关键字搜岗位',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Obx(
              () =>
                  jobController.isSearching.value
                      ? Container(
                        padding: const EdgeInsets.all(10),
                        height: 24,
                        width: 24,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey,
                          ),
                        ),
                      )
                      : Icon(Icons.search, color: Colors.grey[500]),
            ),
            suffixIcon: Obx(
              () =>
                  jobController.searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          // 使用控制器的清除方法
                          jobController.clearSearch();
                        },
                      )
                      : const SizedBox(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterButton('工作类型', 0),
          _buildFilterButton('办公方式', 1),
          _buildFilterButton('英语要求', 2),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, int filterType) {
    return GestureDetector(
      onTap: () {
        _showFilterBottomSheet(title, filterType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Obx(() {
              String displayText = title;
              String selectedValue = '';

              switch (filterType) {
                case 0:
                  selectedValue = jobController.selectedJobType.value;
                  break;
                case 1:
                  selectedValue = jobController.selectedWorkMode.value;
                  break;
                case 2:
                  selectedValue = jobController.selectedLanguage.value;
                  break;
              }

              if (selectedValue.isNotEmpty) {
                displayText = selectedValue;
              }

              return Text(
                displayText,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      selectedValue.isEmpty
                          ? Colors.grey[700]
                          : AppTheme.primaryColor,
                  fontWeight:
                      selectedValue.isEmpty
                          ? FontWeight.normal
                          : FontWeight.bold,
                ),
              );
            }),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.grey[700], size: 18),
          ],
        ),
      ),
    );
  }

  // 底部弹出筛选菜单
  void _showFilterBottomSheet(String title, int filterType) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部标题栏
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Text(
                      '筛选条件',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(Icons.close, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),

              // 工作类型筛选
              _buildFilterOptionSection(
                '工作类型',
                jobController.jobTypes,
                jobController.selectedJobType,
              ),

              // 办公方式筛选
              _buildFilterOptionSection(
                '办公方式',
                jobController.workModes,
                jobController.selectedWorkMode,
              ),

              // 语言要求筛选
              _buildFilterOptionSection(
                '语言要求',
                jobController.languages,
                jobController.selectedLanguage,
              ),

              // 底部按钮区域
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 重置按钮
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          jobController.resetFilters();
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: Colors.grey[700],
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '重置',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // 立即搜索按钮
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            // 在这里应用筛选条件并刷新工作列表
                            jobController.applyFilters();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text(
                            '立即搜索',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // 构建筛选选项部分
  Widget _buildFilterOptionSection(
    String title,
    RxList<String> options,
    RxString selectedValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 筛选类别标题
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Row(
            children: [
              Image.asset('assets/images/menu.png', width: 16, height: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),

        // 选项列表
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Wrap(
            spacing: 8, // 水平间距
            runSpacing: 8, // 垂直间距
            children: [
              // 不限选项
              GestureDetector(
                onTap: () {
                  selectedValue.value = '';
                  // 不再立即应用筛选，而是等待用户点击立即搜索按钮
                },
                child: Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selectedValue.value.isEmpty
                              ? const Color(0xFF2164EB)
                              : const Color(0xFFF4F7FD),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            selectedValue.value.isEmpty
                                ? const Color(0xFF2164EB)
                                : const Color(0xFFF4F7FD),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '不限',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            selectedValue.value.isEmpty
                                ? Colors.white
                                : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
              // 其他选项
              ...options
                  .map(
                    (option) => GestureDetector(
                      onTap: () {
                        selectedValue.value = option;
                        // 不再立即应用筛选，而是等待用户点击立即搜索按钮
                      },
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedValue.value == option
                                    ? const Color(0xFF2164EB)
                                    : const Color(0xFFF4F7FD),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  selectedValue.value == option
                                      ? const Color(0xFF2164EB)
                                      : const Color(0xFFF4F7FD),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  selectedValue.value == option
                                      ? Colors.white
                                      : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            jobController.hasSearched.value ? '没有找到相关职位' : '没有符合条件的职位',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            jobController.hasSearched.value ? '请尝试其他关键词' : '请尝试其他搜索条件',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (jobController.hasSearched.value) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                jobController.clearSearch();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('清除搜索', style: TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobList() {
    return RefreshIndicator(
      onRefresh: jobController.onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!jobController.isLoadingMore.value &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            jobController.onLoading();
          }
          return false;
        },
        child: Obx(() {
          // 检查是否正在加载
          if (jobController.jobs.isEmpty && jobController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // 检查是否搜索无结果
          if (jobController.jobs.isEmpty &&
              jobController.hasSearched.value &&
              jobController.noResults.value) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount:
                jobController.jobs.length +
                (jobController.isLoadingMore.value ||
                        jobController.hasMore.value
                    ? 1
                    : 0),
            itemBuilder: (context, index) {
              if (index == jobController.jobs.length) {
                // 底部加载更多指示器
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        jobController.isLoadingMore.value
                            ? const CircularProgressIndicator()
                            : jobController.hasMore.value
                            ? TextButton(
                              onPressed: () => jobController.onLoading(),
                              child: const Text('加载更多'),
                            )
                            : Text(
                              '没有更多职位了',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                  ),
                );
              }
              // 正常的工作项
              final job = jobController.jobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildJobItem(job),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildJobItem(JobData job) {
    // 解析标签
    List<String> tagList = job.tags?.split(',') ?? [];
    // 格式化薪资
    String salary = _formatSalary(
      job.minSalary ?? 0,
      job.maxSalary ?? 0,
      job.jobSalaryCurrency ?? '',
    );
    // 计算发布时间（简化处理，实际应该根据createdAt计算）
    String timeAgo =
        job.createdAt != null
            ? '${DateTime.now().difference(DateTime.parse(job.createdAt!)).inDays}天前'
            : '未知';

    return GestureDetector(
      onTap: () {
        jobController.navigateToJobDetail(job);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.jobTitle ?? '未知职位',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    salary,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    job.jobCompany ?? '未知公司',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        _buildJobTag(job.jobPosition ?? '远程'),
                        const SizedBox(width: 8),
                        ...tagList.take(2).map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildJobTag(tag),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap:
                        () => jobController.toggleFavorite(
                          job.id,
                          job.jobKey ?? "",
                        ),
                    child: Image.asset(
                      job.jobIsCollect == 1
                          ? 'assets/images/star_fill.png'
                          : 'assets/images/star.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.tagBackgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        TagUtils.formatTag(tag),
        style: const TextStyle(color: AppTheme.tagTextColor, fontSize: 12),
      ),
    );
  }
}
