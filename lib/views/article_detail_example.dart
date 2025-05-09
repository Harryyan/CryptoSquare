import 'package:flutter/material.dart';
import 'package:cryptosquare/views/article_detail_view.dart';

/// 这是一个简单的示例程序，用于直接展示文章详情页面
/// 可以通过此页面快速测试文章详情页面的UI效果
class ArticleDetailExample extends StatelessWidget {
  const ArticleDetailExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ArticleDetailView(articleId: '1'),
    );
  }
}

// 如何运行此示例：
// 1. 在main.dart中导入此文件
// 2. 将runApp(const MyApp())替换为runApp(const ArticleDetailExample())
// 3. 运行应用即可查看文章详情页面效果
// 
// 注意：这只是用于测试UI效果，实际应用中应通过正常的导航方式访问文章详情页面