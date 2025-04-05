import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/models/app_models.dart';

class JobView extends StatelessWidget {
  final JobController jobController = Get.put(JobController());

  JobView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (jobController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildSearchBar(),
            _buildFilterSection(),
            Expanded(
              child:
                  jobController.noResults.value
                      ? _buildEmptyState()
                      : _buildJobList(),
            ),
          ],
        );
      }),
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
          onChanged: (value) {
            jobController.searchQuery.value = value;
          },
          onSubmitted: (value) {
            jobController.searchJobs(value);
          },
          decoration: InputDecoration(
            hintText: '请输入关键字搜岗位',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            suffixIcon: Obx(
              () =>
                  jobController.searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          jobController.searchQuery.value = '';
                          jobController.searchJobs('');
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
    return PopupMenuButton<String>(
      onSelected: (String value) {
        switch (filterType) {
          case 0:
            jobController.selectedJobType.value = value;
            break;
          case 1:
            jobController.selectedWorkMode.value = value;
            break;
          case 2:
            jobController.selectedLanguage.value = value;
            break;
        }
        jobController.applyFilters();
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      itemBuilder: (BuildContext context) {
        RxList<String> options;
        RxString selectedValue;

        switch (filterType) {
          case 0:
            options = jobController.jobTypes;
            selectedValue = jobController.selectedJobType;
            break;
          case 1:
            options = jobController.workModes;
            selectedValue = jobController.selectedWorkMode;
            break;
          case 2:
            options = jobController.languages;
            selectedValue = jobController.selectedLanguage;
            break;
          default:
            options = RxList<String>([]);
            selectedValue = RxString('');
        }

        List<PopupMenuItem<String>> menuItems = [];

        // 添加重置选项
        menuItems.add(
          PopupMenuItem<String>(
            value: '',
            child: Row(
              children: [
                Icon(Icons.refresh, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                const Text('重置', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        );

        // 添加分隔线
        menuItems.add(
          PopupMenuItem<String>(
            enabled: false,
            height: 1,
            padding: EdgeInsets.zero,
            child: Divider(height: 1, color: Colors.grey[300]),
          ),
        );

        // 添加选项
        for (var option in options) {
          menuItems.add(
            PopupMenuItem<String>(
              value: option,
              child: Obx(() {
                final isSelected = selectedValue.value == option;
                return Row(
                  children: [
                    isSelected
                        ? Icon(
                          Icons.check,
                          color: AppTheme.primaryColor,
                          size: 16,
                        )
                        : const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(
                      option,
                      style: TextStyle(
                        color:
                            isSelected ? AppTheme.primaryColor : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          );
        }

        return menuItems;
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

  // 移除底部弹出菜单方法，改为使用PopupMenuButton实现下拉菜单

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/job.png',
            width: 120,
            height: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '没有符合条件的职位',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请尝试其他搜索条件',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    return Obx(() {
      if (jobController.jobs.isEmpty) {
        return const Center(child: Text('暂无工作信息'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobController.jobs.length,
        itemBuilder: (context, index) {
          final job = jobController.jobs[index];
          return _buildJobItem(job);
        },
      );
    });
  }

  Widget _buildJobItem(JobPost job) {
    return Container(
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
                    job.getFormattedTitle(),
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
                  job.salary,
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
                  job.company,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  job.getFormattedTime(),
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
                      _buildJobTag(job.location),
                      const SizedBox(width: 8),
                      ...job.tags.take(2).map((tag) {
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
                  onTap: () => jobController.toggleFavorite(job.id),
                  child: Image.asset(
                    job.isFavorite
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
        tag,
        style: const TextStyle(color: AppTheme.tagTextColor, fontSize: 12),
      ),
    );
  }
}
