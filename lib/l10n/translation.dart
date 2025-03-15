import 'package:cryptosquare/l10n/l10n_keywords.dart';
import 'package:get/get.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': {
      I18nKeyword.language: 'English',
      I18nKeyword.appTitle: 'Web3 KOL观点和新闻快报!',
      I18nKeyword.flashNews: '快讯',
      I18nKeyword.homePage: '首页',
      I18nKeyword.addKOL: '添加KOL',
      I18nKeyword.hotSearch: '热搜',
      I18nKeyword.loadMore: '加载更多...',
      I18nKeyword.subscribe: '订阅',
      I18nKeyword.subscribeSuccess: '订阅成功',
      I18nKeyword.cancelSubscription: '取消订阅',
      I18nKeyword.searchPlaceholder: '搜索你感兴趣的内容',
      I18nKeyword.networkError: "网络请求失败",
      I18nKeyword.retry: "重试",
      I18nKeyword.networkErrorDetail: "请检查您的网络连接，然后重试",
    },
    'en_US': {
      I18nKeyword.language: '简体中文',
      I18nKeyword.appTitle: 'Web3 KOL Insights and News!',
      I18nKeyword.flashNews: 'Express',
      I18nKeyword.homePage: 'Home',
      I18nKeyword.addKOL: 'Add KOL',
      I18nKeyword.hotSearch: 'Hot',
      I18nKeyword.subscribe: 'Subscribe',
      I18nKeyword.loadMore: 'Load more...',
      I18nKeyword.subscribeSuccess: 'Subscribed successfully',
      I18nKeyword.cancelSubscription: 'Unsubscribe',
      I18nKeyword.searchPlaceholder: 'Search the content that interests you',
      I18nKeyword.networkError: "Network Request Failed",
      I18nKeyword.retry: "Retry",
      I18nKeyword.networkErrorDetail:
          "Please check your network connection and try again",
    },
  };
}
