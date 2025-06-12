import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:cryptosquare/views/job_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/controllers/service_controller.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/views/job_view.dart';
import 'package:cryptosquare/util/qr_border_painter.dart';
import 'package:cryptosquare/util/tag_utils.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cryptosquare/rest_service/bitpush_client.dart';
import 'package:dio/dio.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();
  final ServiceController serviceController = Get.put(ServiceController());

  HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 使用全局loading状态
      if (homeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 网络错误状态UI
      if (homeController.isNetworkError.value) {
        return Expanded(
          child: Center(
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
                      return GestureDetector(
                        onTap: () {
                          // Handle banner tap - open link in external browser
                          _handleBannerTap(banner.link);
                        },
                        child: Container(
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
            style: TextStyle(color: Color(0xff575D6A), fontSize: 14),
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
      propertyTags.add('英语');
    }

    return GestureDetector(
      onTap: () {
        // 导航到岗位详情页面
        // 创建一个JobData对象传递给navigateToJobDetail方法
        final jobData = JobData(
          jobKey: job.jobKey ?? job.id.toString(),
          jobTitle: job.title,
          jobCompany: job.company,
          minSalary: 0, // 使用默认值
          maxSalary: 0, // 使用默认值
          jobSalaryCurrency: job.salary, // 临时使用salary字段
          createdAt: job.createdAt, // 使用createdAt而不是getFormattedTime()
          tags: job.tags.join(','), // 将tags数组转换为逗号分隔的字符串
          jobIsCollect: job.isFavorite ? 1 : 0, // 转换收藏状态
          jobType: job.jobType,
          officeMode: job.officeMode,
          jobLang: job.jobLang,
        );
        Get.find<JobController>().navigateToJobDetail(jobData);
      },
      child: Container(
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
                        fontSize: 16,
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
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    job.getFormattedTime(),
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
                          onTap: () => homeController.toggleFavorite(
                            job.id,
                            job.jobKey ?? "",
                          ),
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
                    // 分割线和原始tags
                    if (_hasDisplayableTags(job)) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: const Color(0xFFF4F7FD),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return _buildHashTagsWithMaxLines(
                            _getDisplayableTags(job),
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
                      child: _hasDisplayableTags(job)
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                return _buildHashTagsWithMaxLines(
                                  _getDisplayableTags(job),
                                  constraints.maxWidth - 32, // 减去收藏按钮和间距的宽度
                                );
                              },
                            )
                          : const SizedBox(),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => homeController.toggleFavorite(
                        job.id,
                        job.jobKey ?? "",
                      ),
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
      ),
    );
  }

  // 检查是否有可展示的tags
  bool _hasDisplayableTags(JobPost job) {
    final allTags = <String>[];
    if (job.location.isNotEmpty) allTags.add(job.location);
    allTags.addAll(job.tags.where((tag) => tag.isNotEmpty));
    return allTags.isNotEmpty;
  }

  // 获取可展示的tags列表
  List<String> _getDisplayableTags(JobPost job) {
    final allTags = <String>[];
    if (job.location.isNotEmpty) allTags.add(job.location);
    allTags.addAll(job.tags.where((tag) => tag.isNotEmpty));
    return allTags;
  }

  // 构建带#标识的tags，显示所有tags
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

  Widget _buildSkillTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        '#${TagUtils.formatTag(tag)}',
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

    // 检查redirect_type，如果是1则使用外部浏览器打开链接
    if (homeService?.redirectType == '1' &&
        homeService?.redirectLink != null &&
        homeService!.redirectLink!.isNotEmpty) {
      _launchURL(homeService.redirectLink!);
      return;
    }

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
      introText = service.description.isNotEmpty ? service.description : '空数据';
    }

    // 检查introText是否只包含空格，如果是则提供默认文本
    if (introText.trim().isEmpty) {
      introText = '空数据';
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
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                              color: AppTheme.primaryColor,
                                            ),
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

  // 打开外部URL的方法
  void _launchURL(String url) async {
    try {
      // 确保URL是有效的
      if (url.isEmpty) {
        print('URL为空');
        return;
      }

      // 解析URL
      final Uri uri = Uri.parse(url);
      print('尝试打开URL: $uri');

      // 检查URL是否可以打开
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
        // 尝试使用系统浏览器打开
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
      // 尝试使用系统浏览器打开
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

  // 处理Banner点击事件
  void _handleBannerTap(String link) {
    if (link.isEmpty) {
      print('Banner链接为空');
      return;
    }
    
    // 检查链接是否是有效的HTTP/HTTPS URL
    if (link.startsWith('http://') || link.startsWith('https://')) {
      _launchURL(link);
    } else {
      print('Banner链接格式不正确: $link');
      // 如果不是完整URL，尝试添加https://前缀
      if (link.contains('.') && !link.startsWith('//')) {
        _launchURL('https://$link');
      }
    }
  }

  Widget _buildNewsList() {
    return Obx(() {
      // 如果正在加载且没有数据，显示loading spinner
      if (homeController.isNewsLoading.value && homeController.news.isEmpty) {
        return Container(
          height: 200,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
        );
      }

      // 如果加载完成但没有数据，检查是否有错误
      if (homeController.news.isEmpty && !homeController.isNewsLoading.value) {
        return Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '暂无数据',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    homeController.fetchNews();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: homeController.news.length,
            itemBuilder: (context, index) {
              // 当滚动到最后一项时，触发加载更多
              if (index == homeController.news.length - 1) {
                // 检查是否需要加载更多
                if (homeController.hasMoreNews.value &&
                    !homeController.isLoadingMoreNews.value) {
                  // 延迟执行，避免构建过程中调用setState
                  Future.microtask(() => homeController.loadMoreNews());
                }
              }
              final newsItem = homeController.news[index];
              return _buildNewsItem(newsItem);
            },
          ),
          // 加载更多指示器
          Obx(
            () =>
                homeController.isLoadingMoreNews.value
                    ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : homeController.hasMoreNews.value
                    ? GestureDetector(
                      onTap: () => homeController.loadMoreNews(),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('加载更多')),
                      ),
                    )
                    : const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('没有更多数据了')),
                    ),
          ),
        ],
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
      'MM-dd HH:mm',
    ).format(newsTime);

    return GestureDetector(
      onTap: () {
        // 点击Web3动态item时，显示详情弹窗
        _showWeb3NewsDialog(newsItem, formattedTime);
      },
      child: Container(
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
      ),
    );
  }

  // 显示Web3动态详情弹窗
  void _showWeb3NewsDialog(NewsItem newsItem, String formattedTime) {
    // 直接使用NewsItem中的content数据，如果为空则使用标题
    String content = newsItem.content ?? newsItem.title;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.85, // 最大高度限制
          minHeight: Get.height * 0.3,  // 最小高度限制
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 让Column自适应内容高度
          children: [
            // 顶部标题栏
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 恢复原始设计的Web3动态标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/web3_title.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Web3 动态',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 内容区域 - 使用Flexible而不是Expanded，让内容自适应
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newsItem.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: AppTheme.subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(content, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // 底部固定区域 - 分割线和声明文字
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 分割线
                Container(
                  height: 1,
                  color: Colors.grey[300],
                ),
                // 声明文字
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: const Text(
                    '以上内容由Cryptosquare合作伙伴Bitpush提供，不构成任何投资建议。',
                    style: TextStyle(
                      color: Color(0xFF91929E), // 更改文字颜色为#91929E
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                // 增加底部安全区域间距
                SizedBox(height: MediaQuery.of(Get.context!).padding.bottom + 16),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
