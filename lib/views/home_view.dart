import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/models/app_models.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBannerSlider(),
          _buildServiceSection(),
          _buildJobNewsSection(),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Obx(() {
      if (homeController.banners.isEmpty) {
        return const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return CarouselSlider(
        options: CarouselOptions(
          height: 150,
          viewportFraction: 0.9,
          autoPlay: true,
          enlargeCenterPage: true,
          autoPlayInterval: const Duration(seconds: 3),
        ),
        items:
            homeController.banners.map((banner) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
                      padding: const EdgeInsets.all(16),
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
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
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
    return Container(
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
            child: Image.asset(
              _getServiceIcon(service.title),
              width: 36,
              height: 36,
            ),
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
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
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
                Text(
                  'Finance',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
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
                  '${job.timeAgo}分钟前发布',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildJobTag('全职'),
                      const SizedBox(width: 8),
                      _buildJobTag('远程'),
                      const SizedBox(width: 8),
                      _buildJobTag('本科'),
                      const SizedBox(width: 8),
                      _buildJobTag('需要英语'),
                    ],
                  ),
                ),
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

  Widget _buildNewsList() {
    return Obx(() {
      if (homeController.news.isEmpty) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
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
              '01:49', // 使用固定格式的时间，实际应用中应该转换newsItem.timeAgo为小时:分钟格式
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
