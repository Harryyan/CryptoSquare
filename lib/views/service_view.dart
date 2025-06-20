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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header + Tab导航栏 (共享背景图片)
            _buildHeaderWithTabs(),
            // 内容区域
            _buildTabContent(),
          ],
        ),
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
                  padding: const EdgeInsets.only(top: 15, bottom: 0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSegmentTabItem('服务介绍', 0),
                          _buildSegmentTabItem('推荐课程', 1),
                          _buildSegmentTabItem('学员访谈', 2),
                        ],
                      ),
                    ),
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

  Widget _buildSegmentTabItem(String title, int index) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return _getTabContent();
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
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/service_list_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        child: Column(
          children: [
            // 第一个卡片 - 左对齐
            _buildServiceItemCard(
              title: '运营转型',
              description: '基于你的情况，为你定制 1v1 的转型咨询服务，由行业资深从业者专程指导。',
              features: ['Web3运营策略学习', '履历优化', 'Web3运营基础知识学习', '模拟面试', '项目实战及发展', '就业指导'],
              isLeftAligned: true,
            ),
            const SizedBox(height: 32),
            // 第二个卡片 - 右对齐  
            _buildServiceItemCard(
              title: '1v1 咨询服务',
              description: '由行业资深从业者，TOP 关老师主管等级的专家教授，解答你的Web3求职工作转型相关问题。',
              features: ['社区运营及用户画像', '活动运营', '内容运营与品牌建设', '合作推广', '用户增长与服务策略', '数据分析'],
              isLeftAligned: false,
            ),
            const SizedBox(height: 32),
            // 第三个卡片 - 左对齐
            _buildServiceItemCard(
              title: '求职实流',
              description: '进入 Web3 求职交流群，交流求职经验，获取最新职位信息。',
              features: [],
              isLeftAligned: true,
            ),
            const SizedBox(height: 32),
            // 第四个卡片 - 右对齐
            _buildServiceItemCard(
              title: '简历推送',
              description: '留下你的求职意向，有适合的你的新职位，我们会第一时间推荐，这样你可以保持一步，跟招聘方提前接触。',
              features: [],
              isLeftAligned: false,
            ),
            const SizedBox(height: 32),
            // 第五个卡片 - 左对齐
            _buildServiceItemCard(
              title: '简历优化',
              description: '手把手帮你做好简历优化，提升简历与目标职位的适配度，直达招聘平台。',
              features: [],
              isLeftAligned: true,
            ),
            const SizedBox(height: 30),
          ],
        ),
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

  Widget _buildServiceItemCard({
    required String title,
    required String description,
    required List<String> features,
    required bool isLeftAligned,
  }) {
    Widget buildCard() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/tick_service.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            if (features.isNotEmpty) ...[
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 10,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            features[index],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      );
    }

    if (isLeftAligned) {
      // 左对齐：卡片贴左边，右边有空间
      return Padding(
        padding: const EdgeInsets.only(right: 60),
        child: buildCard(),
      );
    } else {
      // 右对齐：左边有空间，卡片贴右边
      return Padding(
        padding: const EdgeInsets.only(left: 60),
        child: buildCard(),
      );
    }
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