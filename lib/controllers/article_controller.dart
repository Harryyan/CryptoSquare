import 'package:flutter/material.dart';
import 'package:cryptosquare/views/article_detail_view.dart';

class ArticleController {
  // 单例模式
  static final ArticleController _instance = ArticleController._internal();

  factory ArticleController() {
    return _instance;
  }

  ArticleController._internal();

  // 导航到文章详情页面
  void navigateToArticleDetail(BuildContext context, String articleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailView(articleId: articleId),
      ),
    );
  }
}

// 扩展方法，方便在任何控制器中使用
extension ArticleNavigation on ArticleController {
  // 从论坛页面或其他页面导航到文章详情
  void goToArticleDetail(BuildContext context, String articleId) {
    navigateToArticleDetail(context, articleId);
  }
}
