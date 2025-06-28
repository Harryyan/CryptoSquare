import 'package:get/get.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';

class ServiceController extends GetxController {
  final RestClient _restClient = RestClient();
  final RxList<HomeServiceItem> homeServices = <HomeServiceItem>[].obs;
  final RxList<JobServiceItem> jobServices = <JobServiceItem>[].obs;
  final RxList<StudentViewItem> studentViews = <StudentViewItem>[].obs;
  final RxList<CourseItem> courses = <CourseItem>[].obs;
  final Rx<ServerIntroResponse?> serverIntro = Rx<ServerIntroResponse?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isNetworkError = false.obs;
  final RxBool isStudentViewLoading = true.obs;
  final RxBool isCourseLoading = true.obs;
  final RxBool isServerIntroLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeServices();
    initJobServices();
    fetchStudentViews();
    fetchCourses();
    fetchServerIntro();
  }

  // 初始化求职服务数据（placeholder）
  void initJobServices() {
    jobServices.value = [
      JobServiceItem(
        id: 1,
        title: '专项技能',
        description: '基于专业需求从Web3入门到精通的成长规划',
        icon: 'assets/images/customize.png',
        color: 0xFF4A90E2,
      ),
      JobServiceItem(
        id: 2,
        title: '1v1 营销服务',
        description: '作为专业的Web3项目营销导师，为你提供实用的1v1 Web3项目营销指导',
        icon: 'assets/images/consult.png',
        color: 0xFF50C878,
      ),
      JobServiceItem(
        id: 3,
        title: '求职改版',
        description: '让你的简历、作品等达到Web3公司心仪候选人的标准',
        icon: 'assets/images/transform.png',
        color: 0xFFFF6B6B,
      ),
      JobServiceItem(
        id: 4,
        title: '面试改版',
        description: '深入理解求职公司的发展现状，了解公司的技术架构，为你提供有效的Web3面试准备',
        icon: 'assets/images/write.png',
        color: 0xFF9B59B6,
      ),
    ];
  }

  Future<void> fetchHomeServices() {
    isLoading.value = true;
    isNetworkError.value = false;

    return _restClient
        .getHomeServices()
        .then((response) {
          if (response.data != null && response.data!.isNotEmpty) {
            homeServices.value = response.data!;
          }
          isLoading.value = false;
        })
        .catchError((error) {
          print('获取服务项目数据失败: $error');
          // 加载失败时使用空列表
          homeServices.value = [];
          isNetworkError.value = true;
          isLoading.value = false;
        });
  }

  Future<void> fetchStudentViews() {
    isStudentViewLoading.value = true;

    return _restClient
        .getStudentViewList()
        .then((response) {
          if (response.data != null && response.data!.isNotEmpty) {
            studentViews.value = response.data!;
          }
          isStudentViewLoading.value = false;
        })
        .catchError((error) {
          print('获取学员访谈数据失败: $error');
          // 加载失败时使用空列表
          studentViews.value = [];
          isStudentViewLoading.value = false;
        });
  }

  Future<void> fetchCourses() {
    isCourseLoading.value = true;

    return _restClient
        .getCourseList()
        .then((response) {
          if (response.data != null && response.data!.isNotEmpty) {
            courses.value = response.data!;
          }
          isCourseLoading.value = false;
        })
        .catchError((error) {
          print('获取课程数据失败: $error');
          // 加载失败时使用空列表
          courses.value = [];
          isCourseLoading.value = false;
        });
  }

  Future<void> fetchServerIntro() {
    isServerIntroLoading.value = true;

    return _restClient
        .getServerIntro()
        .then((response) {
          if (response.data != null) {
            serverIntro.value = response;
          }
          isServerIntroLoading.value = false;
        })
        .catchError((error) {
          print('获取服务介绍数据失败: $error');
          // 加载失败时设为null
          serverIntro.value = null;
          isServerIntroLoading.value = false;
        });
  }

  // 根据ServiceItem的ID查找对应的HomeServiceItem
  HomeServiceItem? findHomeServiceItemById(int id) {
    return homeServices.firstWhere(
      (item) => item.id == id,
      orElse: () => HomeServiceItem(),
    );
  }

  // 根据ServiceItem的标题查找对应的HomeServiceItem
  HomeServiceItem? findHomeServiceItemByTitle(String title) {
    return homeServices.firstWhere(
      (item) => item.title == title,
      orElse: () => HomeServiceItem(),
    );
  }
}

// 求职服务项目模型
class JobServiceItem {
  final int id;
  final String title;
  final String description;
  final String icon;
  final int color;

  JobServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
