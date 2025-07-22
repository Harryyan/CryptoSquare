import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: analytics);

  // 登录事件
  static Future<void> logLogin(String loginMethod) async {
    await analytics.logLogin(loginMethod: loginMethod);
  }

  // 注册事件
  static Future<void> logSignUp(String signUpMethod) async {
    await analytics.logSignUp(signUpMethod: signUpMethod);
  }

  // 页面查看事件
  static Future<void> logScreenView(
    String screenName,
    String screenClass,
  ) async {
    await analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // 文章查看事件
  static Future<void> logViewItem(
    String itemId,
    String itemName,
    String itemCategory,
  ) async {
    await logCustomEvent('view_item', {
      'item_id': itemId,
      'item_name': itemName,
      'item_category': itemCategory,
    });
  }

  // 搜索事件
  static Future<void> logSearch(String searchTerm) async {
    await analytics.logSearch(searchTerm: searchTerm);
  }

  // 分享事件
  static Future<void> logShare(String contentType, String itemId) async {
    await analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: contentType,
    );
  }

  // 自定义事件
  static Future<void> logCustomEvent(
    String eventName,
    Map<String, Object>? parameters,
  ) async {
    await analytics.logEvent(name: eventName, parameters: parameters);
  }

  // 设置用户属性
  static Future<void> setUserProperty(String name, String? value) async {
    await analytics.setUserProperty(name: name, value: value);
  }

  // 设置用户ID
  static Future<void> setUserId(String? userId) async {
    await analytics.setUserId(id: userId);
  }

  // 论坛相关事件
  static Future<void> logForumPostView(String postId, String postTitle) async {
    await logCustomEvent('forum_post_view', {
      'post_id': postId,
      'post_title': postTitle,
    });
  }

  // 工作相关事件
  static Future<void> logJobView(String jobId, String jobTitle) async {
    await logCustomEvent('job_view', {'job_id': jobId, 'job_title': jobTitle});
  }

  // 服务相关事件
  static Future<void> logServiceView(String serviceName) async {
    await logCustomEvent('service_view', {'service_name': serviceName});
  }

  // 深度链接事件
  static Future<void> logDeepLinkOpen(String linkType, String linkId) async {
    await logCustomEvent('deep_link_open', {
      'link_type': linkType,
      'link_id': linkId,
    });
  }
}
