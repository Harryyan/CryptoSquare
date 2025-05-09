import 'package:flutter/material.dart';
import 'package:cryptosquare/controllers/article_controller.dart';

/// 这是一个示例页面，展示如何导航到文章详情页面
/// 实际应用中，可以将此逻辑集成到论坛页面或其他相关页面
class ArticleListExample extends StatelessWidget {
  const ArticleListExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文章列表示例'), elevation: 0),
      body: ListView.separated(
        itemCount: _mockArticles.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final article = _mockArticles[index];
          return _buildArticleItem(context, article);
        },
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, Map<String, dynamic> article) {
    return InkWell(
      onTap: () {
        // 使用ArticleController导航到文章详情页面
        ArticleController().goToArticleDetail(
          context,
          article['id'].toString(),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article['summary'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      article['image'],
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(article['authorAvatar']),
                      radius: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      article['author'],
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      article['time'],
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.comment, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${article['comments']}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 模拟文章数据
  static final List<Map<String, dynamic>> _mockArticles = [
    {
      'id': '1',
      'title': '加密货币市场分析：比特币突破50,000美元大关',
      'time': '1小时前',
      'comments': 10,
      'image': 'https://via.placeholder.com/150',
      'summary': '比特币近期表现强劲，突破了50,000美元的重要心理关口。这一突破得益于机构投资者的持续进入和市场情绪的改善。',
      'author': '加密分析师',
      'authorAvatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'category': '市场分析',
    },
    {
      'id': '2',
      'title': 'DeFi协议安全漏洞分析与防范措施',
      'time': '3小时前',
      'comments': 25,
      'image': 'https://via.placeholder.com/150',
      'summary': '近期多个DeFi协议遭受黑客攻击，本文分析了常见的安全漏洞类型，并提供了相应的防范措施建议。',
      'author': '区块链安全专家',
      'authorAvatar': 'https://randomuser.me/api/portraits/women/41.jpg',
      'category': '安全',
    },
    {
      'id': '3',
      'title': 'NFT市场趋势：艺术品与游戏资产的融合',
      'time': '昨天',
      'comments': 18,
      'image': 'https://via.placeholder.com/150',
      'summary': 'NFT市场正在经历一场变革，艺术品与游戏资产的边界逐渐模糊，创造了新的价值生态系统。',
      'author': '数字艺术评论家',
      'authorAvatar': 'https://randomuser.me/api/portraits/men/55.jpg',
      'category': 'NFT',
    },
    {
      'id': '4',
      'title': '以太坊2.0进展：从PoW到PoS的转变',
      'time': '2天前',
      'comments': 42,
      'image': 'https://via.placeholder.com/150',
      'summary': '以太坊2.0的开发进展顺利，本文详细介绍了从工作量证明(PoW)到权益证明(PoS)的转变过程及其影响。',
      'author': '以太坊开发者',
      'authorAvatar': 'https://randomuser.me/api/portraits/women/22.jpg',
      'category': '技术',
    },
  ];
}
