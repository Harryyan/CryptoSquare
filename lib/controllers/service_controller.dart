import 'package:get/get.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:dio/dio.dart';

class ServiceController extends GetxController {
  final RestClient _restClient = RestClient();
  final RxList<HomeServiceItem> homeServices = <HomeServiceItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isNetworkError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeServices();
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
          return Future.value();
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
