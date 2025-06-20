import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/service_controller.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({super.key});

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ServiceController serviceController = Get.put(ServiceController());
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header + Tab导航栏 (共享背景图片)
          _buildHeaderWithTabs(),
          // 内容区域
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7FA),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithTabs() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/header.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          // Header 内容
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // 减少顶部间距
                const Text(
                  '帮助更多人转行到 Web3',
                  style: TextStyle(
                    fontSize: 24, // 减少字体大小
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12), // 减少间距
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14, // 减少字体大小
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: '通过系统性指导、学习和实践，我们已经帮助 '),
                      TextSpan(
                        text: '1000+',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' 客户成功转型到 Web3'),
                    ],
                  ),
                ),
                const SizedBox(height: 16), // 减少间距
                ElevatedButton(
                  onPressed: () {
                    // 处理按钮点击
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 减少内边距
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '联系我们，免费获取转型咨询',
                        style: TextStyle(
                          fontSize: 14, // 减少字体大小
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16), // 减少图标大小
                    ],
                  ),
                ),
                const SizedBox(height: 20), // 减少底部间距
              ],
            ),
          ),
          // Tab 导航栏 (白色背景，圆角)
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabItem('服务介绍', 0),
                      const SizedBox(width: 15),
                      _buildTabItem('推荐课程', 1),
                      const SizedBox(width: 15),
                      _buildTabItem('学员访谈', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: Colors.grey.withOpacity(0.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 0),
        child: _getTabContent(),
      ),
    );
  }

  Widget _getTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildServiceIntroContent();
      case 1:
        return _buildRecommendedCoursesContent();
      case 2:
        return _buildStudentInterviewsContent();
      default:
        return _buildServiceIntroContent();
    }
  }

  Widget _buildServiceIntroContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildServiceCard(
            icon: Icons.trending_up,
            title: '运营转型',
            description: '从传统运营转向Web3项目运营，掌握社区建设、用户增长等核心技能',
            color: const Color(0xFF4285F4),
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            icon: Icons.code,
            title: '技术转型',
            description: '学习区块链开发技术，掌握智能合约、DApp开发等技术栈',
            color: const Color(0xFF34A853),
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            icon: Icons.business,
            title: '商务转型',
            description: '了解Web3商业模式，掌握项目BD、合作伙伴关系建立等技能',
            color: const Color(0xFFEA4335),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCoursesContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildCourseCard(
            title: 'Web3基础入门课程',
            duration: '4周',
            level: '初级',
            description: '零基础学习Web3概念、区块链原理、DeFi基础知识',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            title: '智能合约开发实战',
            duration: '8周',
            level: '中级',
            description: 'Solidity编程、智能合约开发、测试和部署实践',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            title: 'Web3项目运营进阶',
            duration: '6周',
            level: '高级',
            description: '社区运营、代币经济设计、用户增长策略',
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInterviewsContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInterviewCard(
            name: '张同学',
            from: '传统互联网产品经理',
            to: 'Web3项目运营总监',
            content: '"通过系统学习，我成功从传统产品经理转型为Web3项目运营，薪资提升了40%"',
          ),
          const SizedBox(height: 16),
          _buildInterviewCard(
            name: '李同学',
            from: '前端开发工程师',
            to: '区块链开发工程师',
            content: '"6个月的学习让我掌握了Solidity开发，现在在顶级DeFi项目担任核心开发"',
          ),
          const SizedBox(height: 16),
          _buildInterviewCard(
            name: '王同学',
            from: '市场营销专员',
            to: 'Web3社区负责人',
            content: '"Web3的社区运营与传统营销完全不同，这里学到的技能让我找到了理想工作"',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String duration,
    required String level,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewCard({
    required String name,
    required String from,
    required String to,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF4285F4).withOpacity(0.1),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$from → $to',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 