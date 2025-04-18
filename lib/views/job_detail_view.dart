import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/controllers/user_controller.dart';

class JobDetailView extends StatelessWidget {
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildJobHeader(),
                  // 添加灰色背景区域作为明显的分隔
                  Container(height: 12, color: const Color(0xFFF5F5F5)),
                  _buildJobDescription(),
                ],
              ),
            ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }

  // 岗位头部信息
  Widget _buildJobHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 职位名称
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          // 公司名称
          Text(
            company,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          // 岗位标签
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _buildTag(tag)).toList(),
          ),

          const SizedBox(height: 12),
          // 添加分隔线
          const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
          // 薪资和发布时间
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                salary,
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
            data: description,
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
                const Text(
                  '预计消耗5积分',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
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
  void navigateToJobDetail(int jobId) {
    // 这里应该根据jobId获取完整的岗位信息
    // 暂时使用模拟数据
    final description =
        "在多个平台（如Twitter，LinkedIn等）上创建与Orca品牌和语调相符的有针对性的相关内容。<br>开发并实施Orca的渠道营销策略：排名渠道，计划特定渠道的活动，确定成功的度量标准，并执行活动。<br>与组织内的各个功能部门合作，以营销产品发布。<br>通过整合关于帖子性能的数据洞察，建立以分析驱动的增长文化。<br>继续扩大Orca对新的和现有的DeFi用户的覆盖范围。<br>职位要求：<br>你将带来什么：<br>对加密Twitter文化，特别是在Solana社区内的深入理解。<br>有使用Orca和/或其他Solana DeFi协议的丰富经验。<br>对AMMs和DeFi的理解。<br>成功执行跨渠道营销活动的记录。<br>所有权心态：如果你看到更好的方式，就说出来并与他人合作来完成。<br>既富有创造力又具有分析性的思维过程，能够设身处地为用户着想。";

    // 模拟岗位数据
    final job = jobs.firstWhere(
      (job) => job.id == jobId,
      orElse: () => jobs.first,
    );

    Get.to(
      () => JobDetailView(
        title: job.title,
        company: job.company,
        salary: job.salary,
        publishTime: job.getFormattedTime(),
        tags: job.tags,
        description: description,
      ),
    );
  }
}
