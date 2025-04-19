import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/util/language_management.dart';

class JobDetailView extends GetView<JobController> {
  final String title;
  final String company;
  final String salary;
  final String publishTime;
  final List<String> tags;
  final String description;

  const JobDetailView({
    Key? key,
    required this.title,
    required this.company,
    required this.salary,
    required this.publishTime,
    required this.tags,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('岗位详情'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset('assets/images/share.png', width: 24, height: 24),
            onPressed: () {
              // 分享功能实现
            },
          ),
        ],
      ),
      body: Obx(
        () =>
            controller.currentJobDetail.value == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildJobHeader(),
                            // 添加灰色背景区域作为明显的分隔
                            Container(
                              height: 12,
                              color: const Color(0xFFF5F5F5),
                            ),
                            _buildJobDescription(),
                          ],
                        ),
                      ),
                    ),
                    _buildApplyButton(),
                  ],
                ),
      ),
    );
  }

  // 岗位头部信息
  Widget _buildJobHeader() {
    // 使用API返回的数据，如果没有则使用构造函数传入的数据
    final jobDetail = controller.currentJobDetail.value;
    final displayTitle = jobDetail?.jobTitle ?? title;
    final displayCompany = jobDetail?.jobCompany ?? company;

    // 处理薪资显示
    String displaySalary = salary;
    if (jobDetail != null &&
        jobDetail.minSalary != null &&
        jobDetail.maxSalary != null) {
      final minSalary = jobDetail.minSalary!;
      final maxSalary = jobDetail.maxSalary!;

      // 根据货币类型显示对应的符号
      String currencySymbol = '¥';
      if (jobDetail.jobSalaryCurrency?.toLowerCase() == 'usd') {
        currencySymbol = '\$';
      } else if (jobDetail.jobSalaryCurrency?.toLowerCase() == 'rmb') {
        currencySymbol = '¥';
      }

      // 根据app语言设置显示单位
      String unitDisplay = jobDetail.jobSalaryUnit ?? 'K';
      if (unitDisplay.toLowerCase() == 'month') {
        // 根据当前语言设置显示月份
        unitDisplay = LanguageManagement.language() == 1 ? '/月' : '/month';
      }

      displaySalary = '$currencySymbol$minSalary-$maxSalary$unitDisplay';
    }

    // 处理标签
    List<String> displayTags = tags;
    if (jobDetail?.tags != null && jobDetail!.tags!.isNotEmpty) {
      displayTags = jobDetail.tags!.split(',');
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 职位名称
          Text(
            displayTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          // 公司名称
          Text(
            displayCompany,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          // 岗位标签
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayTags.map((tag) => _buildTag(tag)).toList(),
          ),

          const SizedBox(height: 12),
          // 添加分隔线
          const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
          // 薪资和发布时间
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displaySalary,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              Text(
                publishTime,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 单个标签方法保留，用于在_buildJobHeader中构建标签

  // 单个标签
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.tagBackgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 12, color: AppTheme.tagTextColor),
      ),
    );
  }

  // 岗位描述
  Widget _buildJobDescription() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  '岗位描述',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 使用flutter_html渲染HTML内容
          Html(
            data: controller.currentJobDetail.value?.jobDesc ?? description,
            style: {
              "body": Style(
                fontSize: FontSize(15),
                lineHeight: LineHeight(1.6),
                color: Colors.black87,
              ),
              "br": Style(margin: Margins.only(bottom: 12)),
            },
          ),
        ],
      ),
    );
  }

  // HR联系方式按钮区域
  Widget _buildApplyButton() {
    final UserController userController = Get.find<UserController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左侧 - 预计消耗积分
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/coin-icon.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '预计消耗${controller.currentJobDetail.value?.apply?.score ?? 5}积分',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 右侧 - 查看HR联系方式按钮
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // 检查用户是否登录
                if (!userController.isLoggedIn) {
                  Get.snackbar(
                    '提示',
                    '请先登录后再查看HR联系方式',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.grey[800],
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                  );
                  return;
                }

                // 已登录，实现查看HR联系方式功能
                // TODO: 实现查看HR联系方式的逻辑
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                '查看HR联系方式',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 扩展JobController，添加导航到岗位详情页的方法
extension JobDetailNavigation on JobController {
  void navigateToJobDetail(int jobId) async {
    // 查找本地岗位数据以获取jobKey
    final job = jobs.firstWhere(
      (job) => job.id == jobId,
      orElse: () => jobs.first,
    );

    // 清空当前岗位详情，以显示加载状态
    currentJobDetail.value = null;

    // 导航到岗位详情页面
    Get.to(
      () => JobDetailView(
        title: job.title,
        company: job.company,
        salary: job.salary,
        publishTime: job.getFormattedTime(),
        tags: job.tags,
        description: '', // 初始为空，将通过API获取
      ),
    );

    try {
      // 使用jobId作为jobKey调用API获取详细信息
      await fetchJobDetail(jobId.toString());

      // 如果获取失败，显示错误提示
      if (currentJobDetail.value == null) {
        Get.snackbar(
          '提示',
          '获取岗位详情失败，请稍后重试',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey[800],
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        '提示',
        '获取岗位详情失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
