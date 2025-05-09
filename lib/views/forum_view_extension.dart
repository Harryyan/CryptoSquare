import 'package:flutter/material.dart';
import 'package:cryptosquare/controllers/article_controller.dart';

// 这个扩展文件用于添加论坛页面的文章点击导航功能
// 可以在forum_view.dart中导入此文件，并使用扩展方法

extension ForumViewExtension on Widget {
  // 包装论坛文章项，添加点击导航到文章详情的功能
  Widget withArticleNavigation(BuildContext context, String articleId) {
    return GestureDetector(
      onTap: () {
        // 使用ArticleController导航到文章详情页面
        ArticleController().goToArticleDetail(context, articleId);
      },
      child: this,
    );
  }
}

// 使用示例：
// 在forum_view.dart中：
// import 'package:cryptosquare/views/forum_view_extension.dart';
//
// 然后将文章项包装起来：
// _buildArticleItem(article).withArticleNavigation(context, article['id'].toString());
