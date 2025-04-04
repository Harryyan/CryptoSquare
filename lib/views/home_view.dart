import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/service_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();
  final ServiceController serviceController = Get.put(ServiceController());

  HomeView({super.key});

  String _getServiceIcon(String title) {
    switch (title) {
      case '在线课程':
        return 'assets/images/online_course.png';
      case '运营转型':
        return 'assets/images/customize.png';
      case '求职交流':
        return 'assets/images/online_course.png';
      case '1v1咨询':
        return 'assets/images/online_course.png';
      default:
        return 'assets/images/online_course.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 使用全局loading状态
      if (homeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 网络错误状态UI
      if (homeController.isNetworkError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '网络连接失败',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => homeController.loadAllData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '重试',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          homeController.loadAllData();
        },
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBannerSlider(),
              _buildServiceSection(),
              _buildJobNewsSection(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBannerSlider() {
    return Obx(() {
      // 不再需要单独的loading指示器，因为我们有全局loading
      if (homeController.banners.isEmpty) {
        return const SizedBox(height: 150);
      }

      return Column(
        children: [
          const SizedBox(height: 16),
          CarouselSlider(
            options: CarouselOptions(
              height: 160,
              viewportFraction: 0.9,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged: (index, reason) {
                homeController.currentBannerIndex.value = index;
              },
            ),
            items:
                homeController.banners.map((banner) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(banner.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                homeController.banners.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          homeController.currentBannerIndex.value == entry.key
                              ? AppTheme.primaryColor
                              : Colors.grey.withOpacity(0.5),
                    ),
                  );
                }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildServiceSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/service_left.png',
                width: 40,
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: const Text(
                  '专业服务',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Image.asset(
                'assets/images/service_right.png',
                width: 40,
                height: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '我们正在帮助更多人进入 Web3',
            style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (homeController.services.isEmpty) {
              return const SizedBox(height: 120);
            }

            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: homeController.services.length,
                itemBuilder: (context, index) {
                  final service = homeController.services[index];
                  return _buildServiceItem(service);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceItem service) {
    return GestureDetector(
      onTap: () => _showServiceDetailBottomSheet(service),
      child: Container(
        width: 180,
        height: 120,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/service_bg.png'),
            fit: BoxFit.cover,
          ),
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
        child: Stack(
          children: [
            // 右上角图标
            Positioned(
              top: 12,
              right: 12,
              child: Image.network(service.iconUrl, width: 36, height: 36),
            ),
            // 内容
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobNewsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildServiceTabButton('精选岗位', 0),
                _buildServiceTabButton('Web3动态', 1),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          return homeController.currentServiceTabIndex.value == 0
              ? Column(
                children: [
                  _buildJobList(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        // 跳转到Web3工作Tab
                        homeController.changeTab(1);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '更多岗位',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : _buildNewsList();
        }),
      ],
    );
  }

  Widget _buildServiceTabButton(String title, int index) {
    return Obx(
      () => GestureDetector(
        onTap: () => homeController.changeServiceTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color:
                homeController.currentServiceTabIndex.value == index
                    ? AppTheme.primaryColor
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: TextStyle(
              color:
                  homeController.currentServiceTabIndex.value == index
                      ? Colors.white
                      : AppTheme.subtitleColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobList() {
    return Obx(() {
      if (homeController.jobs.isEmpty) {
        return const SizedBox(height: 200);
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: homeController.jobs.length,
        itemBuilder: (context, index) {
          final job = homeController.jobs[index];
          return _buildJobItem(job);
        },
      );
    });
  }

  Widget _buildJobItem(JobPost job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                const SizedBox(width: 16), // 添加固定间隔
                GestureDetector(
                  onTap: () => homeController.toggleFavorite(job.id),
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

  Widget _buildSkillTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(color: Colors.grey[700], fontSize: 12),
      ),
    );
  }

  // 显示服务详情底部弹窗
  void _showServiceDetailBottomSheet(ServiceItem service) {
    // 根据ServiceItem的标题查找对应的HomeServiceItem
    final homeService = serviceController.findHomeServiceItemByTitle(
      service.title,
    );
    final pop = homeService?.pop;

    // 处理title，当pop.title为空时使用service.title
    String titleText = '';
    if (pop?.title != null && pop!.title!.isNotEmpty) {
      titleText = pop.title!;
    } else {
      titleText = service.title;
    }

    // 处理intro数组，每个元素之间添加两个换行，增加段落间距
    String introText = '';
    if (pop?.intro != null) {
      if (pop!.intro is List) {
        final introList = pop.intro as List;
        for (int i = 0; i < introList.length; i++) {
          introText += introList[i].toString();
          if (i < introList.length - 1) {
            introText += '\n'; // 使用一个换行符作为段落间距
          }
        }
      } else {
        introText = pop!.intro.toString();
      }
    } else {
      // 如果pop.intro为空，使用service.description作为默认值
      introText =
          service.description.isNotEmpty
              ? service.description
              : '由行业资深从业者，TOP 交易所主管等组成的专家团队，解答您在 Web3 求职与工作过程中遇到的各种问题。例如：社区运营及用户画像、内容运营与品牌建设、用户增长与裂变策略、活动运营及合作推广、数据分析等。';
    }

    // 检查introText是否只包含空格，如果是则提供默认文本
    if (introText.trim().isEmpty) {
      introText =
          '由行业资深从业者，TOP 交易所主管等组成的专家团队，解答您在 Web3 求职与工作过程中遇到的各种问题。例如：社区运营及用户画像、内容运营与品牌建设、用户增长与裂变策略、活动运营及合作推广、数据分析等。';
    }

    // 处理tips数组，每个元素之间添加换行，最后一个不加
    String tipsText = '';
    if (pop?.tips != null) {
      if (pop!.tips is List) {
        final tipsList = pop.tips as List;
        for (int i = 0; i < tipsList.length; i++) {
          tipsText += tipsList[i].toString();
          if (i < tipsList.length - 1) {
            tipsText += '\n';
          }
        }
      } else {
        tipsText = pop!.tips.toString();
      }
    }
    // 如果pop.tips为空，提供一个默认值
    if (tipsText.isEmpty) {
      tipsText = '扫码添加客服，获取更多服务';
    }

    // 确定二维码图片路径
    String qrCodeImagePath = 'assets/images/qr-code.png';
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
                    homeService?.icon != null && homeService!.icon!.isNotEmpty
                        ? Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Image.network(
                            homeService.icon!,
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
                height: 1.5, // 调整行高，使段落内文本更紧凑
                letterSpacing: 0.3, // 调整字间距
              ),
              textAlign: TextAlign.justify, // 两端对齐，提高可读性
            ),

            // 删除这里的tips显示
            const SizedBox(height: 32),

            // 二维码部分
            Center(
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child:
                          qrCodeImagePath.startsWith('http') ||
                                  qrCodeImagePath.startsWith('https')
                              ? Image.network(
                                qrCodeImagePath,
                                width: 160,
                                height: 160,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/qr-code.png',
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
                  const SizedBox(height: 16),
                  // const Text(
                  //   '扫描识别二维码',
                  //   style: TextStyle(color: Colors.blue, fontSize: 14),
                  // ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   '添加求职助手微信咨询',
                  //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  // ),

                  // 如果有tips，在二维码下方显示tips
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

  Widget _buildNewsList() {
    return Obx(() {
      if (homeController.news.isEmpty) {
        return const SizedBox(height: 200);
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: homeController.news.length,
        itemBuilder: (context, index) {
          final newsItem = homeController.news[index];
          return _buildNewsItem(newsItem);
        },
      );
    });
  }

  Widget _buildNewsItem(NewsItem newsItem) {
    // 将timeAgo（分钟）转换为DateTime对象
    final DateTime newsTime = DateTime.now().subtract(
      Duration(minutes: newsItem.timeAgo),
    );
    // 使用DateFormat格式化为指定格式
    final String formattedTime = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(newsTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            Text(
              formattedTime,
              style: const TextStyle(
                color: AppTheme.subtitleColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              newsItem.title,
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
