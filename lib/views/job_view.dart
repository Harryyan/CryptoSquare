import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async'; // 添加async导入
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptosquare/util/tag_utils.dart';
import 'package:flutter/rendering.dart';

class JobView extends StatefulWidget {
  JobView({super.key});

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> with AutomaticKeepAliveClientMixin {
  final JobController jobController = Get.put(JobController());

  // 搜索框的文本控制器
  final TextEditingController _searchController = TextEditingController();
  
  // 保存监听器引用，用于在dispose时取消
  late StreamSubscription _searchQuerySubscription;

  @override
  bool get wantKeepAlive => true;

  // 格式化薪资为 $1,500 - $2,500 格式，如果最低和最高都是0则显示面议
  String _formatSalary(int minSalary, int maxSalary, String currency) {
    // 如果最低和最高薪资都为0，则显示面议
    if (minSalary == 0 && maxSalary == 0) {
      return "面议";
    }

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
    _searchQuerySubscription = jobController.searchQuery.listen((query) {
      if (mounted && _searchController.text != query) {
        _searchController.text = query;
      }
    });
  }

  @override
  void dispose() {
    // 先取消监听器
    _searchQuerySubscription.cancel();
    // 再dispose控制器
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          color: Color(0xFFF4F7FD),
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
          textAlignVertical: TextAlignVertical.center, // 确保文字垂直居中
          decoration: InputDecoration(
            hintText: '请输入关键字搜索岗位',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Obx(
              () =>
                  jobController.isSearching.value
                      ? Container(
                        padding: const EdgeInsets.all(12), // 调整padding使spinner居中
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CupertinoActivityIndicator(
                            radius: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                      : Icon(Icons.search, color: Colors.grey[500], size: 20),
            ),
            suffixIcon: Obx(
              () =>
                  jobController.searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                        onPressed: () {
                          // 使用控制器的清除方法
                          jobController.clearSearch();
                        },
                      )
                      : const SizedBox(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), // 调整vertical padding
            isDense: true, // 使输入框更紧凑
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
              List<String> selectedValues = [];

              switch (filterType) {
                case 0:
                  selectedValues = jobController.selectedJobTypes.toList();
                  break;
                case 1:
                  selectedValues = jobController.selectedWorkModes.toList();
                  break;
                case 2:
                  selectedValues = jobController.selectedLanguages.toList();
                  break;
              }

              if (selectedValues.isNotEmpty) {
                // 如果选择了多个值，显示"已选择X项"
                if (selectedValues.length > 1) {
                  displayText = '已选择${selectedValues.length}项';
                } else {
                  // 如果只选择了一个值，直接显示该值
                  displayText = selectedValues[0];
                }
              }

              return Text(
                displayText,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      selectedValues.isEmpty
                          ? Colors.grey[700]
                          : Color(0xff2164EB),
                  fontWeight:
                      selectedValues.isEmpty
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
                jobController.selectedJobTypes,
                0,
              ),

              // 办公方式筛选
              _buildFilterOptionSection(
                '办公方式',
                jobController.workModes,
                jobController.selectedWorkModes,
                1,
              ),

              // 语言要求筛选
              _buildFilterOptionSection(
                '语言要求',
                jobController.languages,
                jobController.selectedLanguages,
                2,
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
                            backgroundColor: Color(0xff2164EB),
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
    RxList<String> selectedValues,
    int filterType,
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
                  // 选择"不限"时清空所有选择
                  selectedValues.clear();
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
                          selectedValues.isEmpty
                              ? const Color(0xFF2164EB)
                              : const Color(0xFFF4F7FD),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            selectedValues.isEmpty
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
                            selectedValues.isEmpty
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
                        // 多选逻辑
                        if (selectedValues.contains(option)) {
                          // 如果已选中，则取消选中
                          selectedValues.remove(option);
                        } else {
                          // 如果未选中，则添加到选中列表
                          // 先清空"不限"选项（如果有的话）
                          selectedValues.add(option);
                        }
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
                                selectedValues.contains(option)
                                    ? const Color(0xFF2164EB)
                                    : const Color(0xFFF4F7FD),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  selectedValues.contains(option)
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
                                  selectedValues.contains(option)
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
                '没有符合条件的职位',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center, // 确保文字居中
              ),
              if (jobController.hasSearched.value) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    jobController.clearSearch();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2164EB),
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
        ),
      ),
    );
  }

  Widget _buildJobList() {
    return Container(
      color: const Color(0xFFF4F7FD), // 添加背景色
      child: RefreshIndicator(
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
                  padding: const EdgeInsets.only(bottom:16),
                  child: _buildJobItem(job),
                );
              },
            );
          }),
        ),
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
    String timeAgo = _formatTime(job.createdAt);

    // 处理title，从"xxx|xxx|xxx"格式中提取第二个部分
    String processedTitle = job.jobTitle ?? '未知职位';
    if (processedTitle.contains('|')) {
      final titleParts = processedTitle.split('|');
      if (titleParts.length >= 2) {
        processedTitle = titleParts[1].trim(); // 取第二个部分并去除空格
      }
    }

    // 构建新的属性标签
    List<String> propertyTags = [];
    
    // 添加 jobType
    if (job.jobType?.isNotEmpty == true) {
      propertyTags.add(job.jobType!);
    }
    
    // 添加 officeMode
    if (job.officeMode == 1) {
      propertyTags.add('远程');
    } else if (job.officeMode == 0) {
      propertyTags.add('实地');
    }
    
    // 添加 jobLang
    if (job.jobLang == 1) {
      propertyTags.add('需要英语');
    }

    return GestureDetector(
      onTap: () {
        jobController.navigateToJobDetail(job);
      },
      child: Container(
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
                      processedTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeAgo,
                    style: TextStyle(color: Color(0xFF91929E), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 新的属性标签行
              if (propertyTags.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: propertyTags.map((tag) => _buildJobTag(tag)).toList(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => jobController.toggleFavorite(
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
                    // 分割线和原始tags
                    if (tagList.where((tag) => tag.isNotEmpty).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: const Color(0xFFF4F7FD),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return _buildHashTagsWithMaxLines(
                            tagList.where((tag) => tag.isNotEmpty).toList(),
                            constraints.maxWidth - 32, // 减去收藏按钮和间距的宽度
                          );
                        },
                      ),
                    ],
                  ],
                )
              else
                // 如果没有属性标签，保持原有的结构
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: tagList.where((tag) => tag.isNotEmpty).isNotEmpty
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                return _buildHashTagsWithMaxLines(
                                  tagList.where((tag) => tag.isNotEmpty).toList(),
                                  constraints.maxWidth - 32, // 减去收藏按钮和间距的宽度
                                );
                              },
                            )
                          : const SizedBox(),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => jobController.toggleFavorite(
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

  // 新增方法：构建带#标识的tags，显示所有tags
  Widget _buildHashTagsWithMaxLines(List<String> tags, double maxWidth) {
    if (tags.isEmpty) return const SizedBox();
    
    // 直接显示所有tags，不进行任何截断，不使用TagUtils.formatTag
    List<Widget> tagWidgets = tags.map((tag) {
      final tagText = '#$tag'; // 直接使用原始tag，不经过formatTag处理
      return _buildHashTag(tagText);
    }).toList();
    
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tagWidgets,
    );
  }

  Widget _buildHashTag(String tag) {
    return Text(
      tag,
      style: const TextStyle(
        color: Color(0xFF575D6A),
        fontSize: 13,
      ),
    );
  }

  // 格式化时间戳 - 参考 forum_view.dart 的实现
  String _formatTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return '未知';
    }

    try {
      // 尝试解析createdAt字符串为DateTime
      final DateTime dateTime = DateTime.parse(createdAt);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

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
    } catch (e) {
      // 解析失败时返回默认值
      return '未知';
    }
  }
}
