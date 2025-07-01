import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/service_controller.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:url_launcher/url_launcher.dart';

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
      backgroundColor:
          selectedTabIndex == 0
              ? const Color(0xFFF5F7FA)
              : const Color(0xFFF2F5F9),
      body: Container(
        decoration:
            selectedTabIndex == 0
                ? const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/service_list_bg.png'),
                    fit: BoxFit.cover,
                  ),
                )
                : null,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header + Tab导航栏 (共享背景图片)
              _buildHeaderWithTabs(),
              // 内容区域
              _buildTabContent(),
            ],
          ),
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
            child: Obx(() {
              final banner = serviceController.serverIntro.value?.data?.banner;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), // 减少顶部间距
                  // 如果有 banner 图片，显示图片，否则不显示
                  if (banner?.img != null && banner!.img!.isNotEmpty) ...[
                    Image.network(
                      banner.img!,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink(); // 图片加载失败时不显示
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    banner?.title ?? '帮助更多人转行到 Web3',
                    style: const TextStyle(
                      fontSize: 24, // 减少字体大小
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12), // 减少间距
                  Text(
                    banner?.intro ?? '通过系统性指导、学习和实践，我们已经帮助 1000+ 客户成功转型到 Web3',
                    style: const TextStyle(
                      fontSize: 15, // 减少字体大小
                      color: Colors.black,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16), // 减少间距
                  ElevatedButton(
                    onPressed: () async {
                      final link = banner?.link;
                      if (link != null && link.isNotEmpty) {
                        final uri = Uri.parse(link);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ), // 减少内边距
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          banner?.linkText ?? '联系我们，免费获取转型咨询',
                          style: const TextStyle(
                            fontSize: 14, // 减少字体大小
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 16), // 减少图标大小
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // 减少底部间距
                ],
              );
            }),
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
            color: isSelected ? Colors.white : Colors.black,
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
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 30),
        child: Obx(() {
          if (serviceController.isServerIntroLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final serverIntroData =
              serviceController.serverIntro.value?.data?.data;
          if (serverIntroData == null || serverIntroData.isEmpty) {
            return const Center(child: Text('暂无服务介绍数据'));
          }

          return Column(
            children:
                serverIntroData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: 20),
                      _buildServiceItemCard(
                        title: item.title ?? '',
                        description: item.intro ?? '',
                        features: item.tips ?? [],
                        iconUrl: item.icon,
                        isLeftAligned: index % 2 == 0, // 偶数索引左对齐，奇数索引右对齐
                        serverIntroItem: item, // 传递完整的 ServerIntroItem 对象
                      ),
                    ],
                  );
                }).toList(),
          );
        }),
      ),
    );
  }

  Widget _buildRecommendedCoursesContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        if (serviceController.isCourseLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (serviceController.courses.isEmpty) {
          return const Center(child: Text('暂无课程数据'));
        }

        return Column(
          children:
              serviceController.courses.asMap().entries.map((entry) {
                final index = entry.key;
                final course = entry.value;
                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 20),
                    _buildNewCourseCard(course: course),
                  ],
                );
              }).toList(),
        );
      }),
    );
  }

  Widget _buildStudentInterviewsContent() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F5F9),
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        if (serviceController.isStudentViewLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (serviceController.studentViews.isEmpty) {
          return const Center(child: Text('暂无学员访谈数据'));
        }

        return Column(
          children:
              serviceController.studentViews.asMap().entries.map((entry) {
                final index = entry.key;
                final studentView = entry.value;
                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 20),
                    _buildStudentInterviewCard(
                      studentView: studentView,
                      index: index,
                    ),
                  ],
                );
              }).toList(),
        );
      }),
    );
  }

  Widget _buildServiceItemCard({
    required String title,
    required String description,
    required List<String> features,
    String? iconPath,
    String? iconUrl,
    required bool isLeftAligned,
    ServerIntroItem? serverIntroItem,
  }) {
    Widget buildCard() {
      return GestureDetector(
        onTap: () {
          if (serverIntroItem != null) {
            _onServiceItemTap(serverIntroItem!);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                isLeftAligned
                    ? const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )
                    : const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 优先使用网络图片，如果没有则使用本地图片，都没有则使用占位符
                  (iconUrl != null && iconUrl!.isNotEmpty)
                      ? Image.network(
                        iconUrl!,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return (iconPath != null && iconPath!.isNotEmpty)
                              ? Image.asset(iconPath!, width: 40, height: 40)
                              : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              );
                        },
                      )
                      : (iconPath != null && iconPath!.isNotEmpty)
                      ? Image.asset(iconPath!, width: 40, height: 40)
                      : Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image, color: Colors.grey),
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
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              if (features.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/service_feature.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 10,
                    bottom: 5,
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < features.length; i += 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Image.asset(
                                        'assets/images/tick_service.png',
                                        width: 12,
                                        height: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        features[i],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF575D6A),
                                          fontWeight: FontWeight.w500,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 23),
                              if (i + 1 < features.length)
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Image.asset(
                                          'assets/images/tick_service.png',
                                          width: 12,
                                          height: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          features[i + 1],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF575D6A),
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ), // Container 结束
      ); // GestureDetector 结束
    }

    if (isLeftAligned) {
      // 左对齐：卡片贴左边，右边有空间
      return Padding(
        padding: const EdgeInsets.only(right: 30),
        child: buildCard(),
      );
    } else {
      // 右对齐：左边有空间，卡片贴右边
      return Padding(
        padding: const EdgeInsets.only(left: 30),
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
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewCourseCard({required dynamic course}) {
    return GestureDetector(
      onTap: () async {
        final url = course.link;
        if (url != null && url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
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
            // 课程封面图片
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child:
                  course.img != null && course.img!.isNotEmpty
                      ? Image.network(
                        course.img!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/course_placeholder.png',
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      )
                      : Image.asset(
                        'assets/images/course_placeholder.png',
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
            ),
            // 课程信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title ?? '暂无标题',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.intro ?? '暂无简介',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Container(height: 1, color: Colors.grey.shade200),
                  // const SizedBox(height: 16),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       course.price != null ? '¥${course.price}' : '价格待定',
                  //       style: const TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //         color: Color(0xFFFF6B35),
                  //       ),
                  //     ),
                  //     Container(
                  //       padding: const EdgeInsets.symmetric(
                  //         horizontal: 16,
                  //         vertical: 8,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.circular(6),
                  //       ),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           const Text(
                  //             '立即购买',
                  //             style: TextStyle(
                  //               fontSize: 16,
                  //               color: Colors.black,
                  //             ),
                  //           ),
                  //           const SizedBox(width: 4),
                  //           const Icon(
                  //             Icons.arrow_forward,
                  //             size: 16,
                  //             color: Colors.black,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildStudentInterviewCard({
    required dynamic studentView,
    required int index,
  }) {
    final isImageLeft =
        index % 2 == 0; // 奇数项(index 0,2,4...)图片在左，偶数项(index 1,3,5...)图片在右

    return GestureDetector(
      onTap: () async {
        final url = studentView.link;
        if (url != null && url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isImageLeft) ...[
                // 图片在左边
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      studentView.img != null && studentView.img!.isNotEmpty
                          ? Image.network(
                            studentView.img!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/student_placeholder.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                          : Image.asset(
                            'assets/images/student_placeholder.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                ),
                const SizedBox(width: 12),
              ],
              // 文字内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      studentView.title ?? '暂无标题',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      studentView.intro ?? '暂无简介',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isImageLeft) ...[
                // 图片在右边
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      studentView.img != null && studentView.img!.isNotEmpty
                          ? Image.network(
                            studentView.img!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/student_placeholder.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                          : Image.asset(
                            'assets/images/student_placeholder.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 处理服务项目点击事件
  void _onServiceItemTap(ServerIntroItem item) {
    // 检查 redirectType
    if (item.redirectType == '1' &&
        item.redirectLink != null &&
        item.redirectLink!.isNotEmpty) {
      // 类型1：打开外部链接
      _launchURL(item.redirectLink!);
    } else if (item.redirectType == '2') {
      // 类型2：显示弹窗
      _showServiceDetailBottomSheet(item);
    }
  }

  // 显示服务详情底部弹窗
  void _showServiceDetailBottomSheet(ServerIntroItem item) {
    final pop = item.pop;

    // 处理标题
    String titleText =
        pop?.title?.isNotEmpty == true ? pop!.title! : item.title ?? '服务详情';

    // 处理intro数组
    String introText = '';
    if (pop?.intro != null && pop!.intro!.isNotEmpty) {
      for (int i = 0; i < pop.intro!.length; i++) {
        introText += pop.intro![i];
        if (i < pop.intro!.length - 1) {
          introText += '\n';
        }
      }
    } else {
      introText = item.intro ?? '暂无详细介绍';
    }

    // 处理tips数组
    String tipsText = '';
    if (pop?.tips != null && pop!.tips!.isNotEmpty) {
      for (int i = 0; i < pop.tips!.length; i++) {
        tipsText += pop.tips![i];
        if (i < pop.tips!.length - 1) {
          tipsText += '\n';
        }
      }
    } else {
      tipsText = '扫码添加客服，获取更多服务';
    }

    // 确定二维码图片路径
    String qrCodeImagePath = 'assets/images/qr-code.jpg';
    if (pop?.img != null && pop!.img!.isNotEmpty) {
      qrCodeImagePath = pop.img!;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    item.icon != null && item.icon!.isNotEmpty
                        ? Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Image.network(
                            item.icon!,
                            width: 16,
                            height: 16,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              );
                            },
                          ),
                        )
                        : Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ),
                    const SizedBox(width: 8),
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 服务详情描述
            Text(
              introText,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 32),

            // 二维码部分
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      children: [
                        // 边框图片
                        Center(
                          child: Image.asset(
                            'assets/images/qr-box.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                        // 二维码图片
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  qrCodeImagePath.startsWith('http') ||
                                          qrCodeImagePath.startsWith('https')
                                      ? Image.network(
                                        qrCodeImagePath,
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Image.asset(
                                            'assets/images/qr-code.jpg',
                                            width: 160,
                                            height: 160,
                                            fit: BoxFit.contain,
                                          );
                                        },
                                      )
                                      : Image.asset(
                                        qrCodeImagePath,
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.contain,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tips显示
                  if (tipsText.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      tipsText,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  // 打开外部URL的方法
  void _launchURL(String url) async {
    try {
      if (url.isEmpty) {
        print('URL为空');
        return;
      }

      final Uri uri = Uri.parse(url);
      print('尝试打开URL: $uri');

      if (await canLaunchUrl(uri)) {
        print('URL可以打开，正在启动...');
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          print('URL启动失败: $url');
        }
      } else {
        print('无法打开URL: $url');
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (!launched) {
          print('使用系统浏览器打开也失败了: $url');
        }
      }
    } catch (e) {
      print('打开URL时出错: $e');
      try {
        final Uri uri = Uri.parse(url);
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (!launched) {
          print('使用系统浏览器打开也失败了: $url');
        }
      } catch (e2) {
        print('使用系统浏览器打开时也出错: $e2');
      }
    }
  }
}
