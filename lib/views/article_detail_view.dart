import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';

class ArticleDetailView extends StatefulWidget {
  final String articleId;

  const ArticleDetailView({Key? key, required this.articleId})
    : super(key: key);

  @override
  State<ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<ArticleDetailView> {
  ArticleDetailData? _articleData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticleDetail();
  }

  Future<void> _loadArticleDetail() async {
    setState(() {
      _isLoading = true;
    });

    // 这里应该调用API获取文章详情，现在使用模拟数据
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _articleData = _getMockArticleData();
      _isLoading = false;
    });
  }

  // 模拟文章数据
  ArticleDetailData _getMockArticleData() {
    return ArticleDetailData(
      id: 1,
      title: '加密货币市场分析：比特币突破50,000美元大关',
      content: '''
      <h2>市场概览</h2>
      <p>比特币近期表现强劲，突破了50,000美元的重要心理关口。这一突破得益于机构投资者的持续进入和市场情绪的改善。</p>
      <p>以太坊同样表现不俗，随着ETH 2.0的推进，其价格也有所上涨。</p>
      <h2>技术分析</h2>
      <p>从技术面来看，比特币突破了多条移动平均线，显示出强劲的上升动能。短期内可能会有回调，但中长期趋势依然向好。</p>
      <p>交易量的增加也印证了这一趋势的可持续性。</p>
      <h2>风险提示</h2>
      <p>尽管市场前景看好，投资者仍需注意以下风险：</p>
      <ul>
        <li>监管政策的不确定性</li>
        <li>市场波动性较大</li>
        <li>技术安全风险</li>
      </ul>
      ''',
      createdAt: '2023-05-15 08:30:00',
      extension: ArticleExtension(
        tag: ['比特币', '市场分析', '加密货币', '投资建议'].map((e) => e as dynamic).toList(),
        auth: ArticleAuthInfo(
          nickname: '加密分析师',
          avatar: 'https://randomuser.me/api/portraits/men/32.jpg',
          isOnline: true,
          userId: 101,
        ),
      ),
      comments: [
        ArticleComment(
          id: 1,
          content: '非常感谢分享，这篇分析很有见地！',
          userId: 201,
          createdAt: '2023-05-15 09:15:00',
          parentComment: 0,
          user: ArticleCommentUser(
            id: 201,
            userNicename: '币圈新手',
            userUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
          ),
        ),
        ArticleComment(
          id: 2,
          content: '我认为比特币还会继续上涨，机构资金正在不断流入。',
          userId: 202,
          createdAt: '2023-05-15 10:30:00',
          parentComment: 0,
          user: ArticleCommentUser(
            id: 202,
            userNicename: '区块链爱好者',
            userUrl: 'https://randomuser.me/api/portraits/men/41.jpg',
          ),
        ),
        ArticleComment(
          id: 3,
          content: '我同意你的观点，尤其是关于机构资金流入的分析。',
          userId: 203,
          createdAt: '2023-05-15 11:45:00',
          parentComment: 2, // 回复ID为2的评论
          user: ArticleCommentUser(
            id: 203,
            userNicename: '投资分析师',
            userUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
          ),
        ),
        ArticleComment(
          id: 4,
          content: '监管风险不容忽视，最近有些国家正在加强对加密货币的监管。',
          userId: 204,
          createdAt: '2023-05-15 13:20:00',
          parentComment: 0,
          user: ArticleCommentUser(
            id: 204,
            userNicename: '风险控制专家',
            userUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18nKeyword.articleTitle.tr),
        elevation: 0,
        actions: [
          IconButton(
            icon: Image.asset('assets/images/share.png', width: 24, height: 24),
            onPressed: () {
              // 分享功能实现
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildArticleDetail(),
    );
  }

  Widget _buildArticleDetail() {
    if (_articleData == null) {
      return const Center(child: Text('无法加载文章内容'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildArticleHeader(),
          _buildArticleContent(),
          _buildArticleTags(),
          _buildArticleStats(),
          Divider(color: Color(0x99F2F5F9), height: 32, thickness: 8),
          _buildCommentsSection(),
        ],
      ),
    );
  }

  Widget _buildArticleHeader() {
    final auth = _articleData?.extension?.auth;
    final createdAt = _articleData?.createdAt;
    String formattedDate = '';

    if (createdAt != null) {
      try {
        final dateTime = DateTime.parse(createdAt);
        formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
      } catch (e) {
        formattedDate = createdAt;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _articleData?.title ?? '',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  auth?.avatar ?? 'https://via.placeholder.com/40',
                ),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth?.nickname ?? '未知作者',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Html(
        data: _articleData?.content ?? '',
        style: {
          'body': Style(fontSize: FontSize(16.0), lineHeight: LineHeight(1.6)),
          'h2': Style(
            fontSize: FontSize(20.0),
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 16, bottom: 8),
          ),
          'p': Style(margin: Margins.only(bottom: 12)),
          'ul': Style(
            // 清除 ul 默认内边距和外边距
            padding: HtmlPaddings.zero,
            margin: Margins.zero,
            // 把 • 放到行内，避免额外的缩进
            listStylePosition: ListStylePosition.inside,
          ),
          'li': Style(
            // 清除 li 默认内边距
            padding: HtmlPaddings.zero,
            // 保留下边距
            margin: Margins.only(bottom: 8),
            listStylePosition: ListStylePosition.inside,
          ),
        },
      ),
    );
  }

  Widget _buildArticleTags() {
    final tags = _articleData?.extension?.tag;
    if (tags == null || tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tag.toString(),
                  style: TextStyle(color: Colors.grey[800], fontSize: 12),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildArticleStats() {
    return const SizedBox.shrink(); // 移除统计信息显示
  }

  Widget _buildCommentsSection() {
    final comments = _articleData?.comments;
    if (comments == null || comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('暂无评论')),
      );
    }

    // 过滤出顶级评论（没有父评论的评论）
    final topLevelComments =
        comments
            .where(
              (comment) =>
                  comment.parentComment == null || comment.parentComment == 0,
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                '评论',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '(${comments.length})',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        // 添加评论区标题和第一条评论之间的分割线
        Divider(color: const Color(0xFFE6EDF5), height: 1, thickness: 1),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topLevelComments.length,
          itemBuilder: (context, index) {
            final comment = topLevelComments[index];
            return _buildCommentItem(comment, comments);
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(
    ArticleComment comment,
    List<ArticleComment> allComments,
  ) {
    // 查找此评论的回复（子评论）
    final replies =
        allComments
            .where((reply) => reply.parentComment == comment.id)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  comment.user?.userUrl ?? 'https://via.placeholder.com/40',
                ),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comment.user?.userNicename ?? '匿名用户',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatCommentTime(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(comment.content ?? ''),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/comment_icon.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '回复',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 渲染回复评论
        if (replies.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 56),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: replies.length,
              itemBuilder: (context, index) {
                final reply = replies[index];
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          reply.user?.userUrl ??
                              'https://via.placeholder.com/30',
                        ),
                        radius: 15,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  reply.user?.userNicename ?? '匿名用户',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  _formatCommentTime(reply.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "@${comment.user?.userNicename ?? '匿名用户'} ",
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: reply.content ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _formatCommentTime(String? timeStr) {
    if (timeStr == null) return '';

    try {
      final dateTime = DateTime.parse(timeStr);
      return DateFormat('MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return timeStr;
    }
  }
}
