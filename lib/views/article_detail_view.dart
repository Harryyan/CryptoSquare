import 'dart:io';

import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class ArticleDetailView extends StatefulWidget {
  final String articleId;

  const ArticleDetailView({Key? key, required this.articleId})
    : super(key: key);

  @override
  State<ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<ArticleDetailView> {
  ArticleDetailData? _articleData;
  List<ArticleCommentItem>? _comments;
  bool _isLoading = true;
  bool _isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    _loadArticleDetail();
    _loadArticleComments();
  }

  Future<void> _loadArticleDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 调用API获取文章详情
      final client = RestClient();
      final response = await client.getArticleDetail(
        widget.articleId,
        GStorage().getLanguageCN() ? 1 : 0, // 默认使用中文，可以根据实际需求修改
        Platform.isAndroid ? "android" : "ios", // 平台标识
      );

      if (response.code == 0 && response.data != null) {
        setState(() {
          _articleData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // 显示错误信息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message ?? '获取文章详情失败')));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 显示错误信息
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('网络错误: ${e.toString()}')));
    }
  }

  Future<void> _loadArticleComments() async {
    setState(() {
      _isLoadingComments = true;
    });

    try {
      // 调用API获取文章评论
      final client = RestClient();
      final response = await client.getArticleComments(
        widget.articleId,
        GStorage().getLanguageCN() ? 1 : 0, // 默认使用中文，可以根据实际需求修改
        Platform.isAndroid ? "android" : "ios", // 平台标识
      );

      if (response.code == 0 && response.data != null) {
        setState(() {
          _comments = response.data;
          _isLoadingComments = false;
        });
      } else {
        setState(() {
          _isLoadingComments = false;
        });
        // 显示错误信息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message ?? '获取评论失败')));
      }
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
      // 显示错误信息
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('获取评论失败: ${e.toString()}')));
    }
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
      bottomSheet: _buildBottomCommentBar(),
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
    if (_isLoadingComments) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final comments = _comments;
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
                '(${_articleData?.replyNums ?? 0})',
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
    ArticleCommentItem comment,
    List<ArticleCommentItem> allComments,
  ) {
    // 使用评论的reply字段获取回复
    final List<ArticleCommentReply> replies = comment.reply ?? [];

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
                      children: [
                        Text(
                          comment.user?.userNicename ?? '匿名用户',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '|',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                              children: [
                                Text(
                                  reply.user?.userNicename ?? '匿名用户',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '|',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/comment_icon.png',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '回复',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
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

  // 底部评论栏
  Widget _buildBottomCommentBar() {
    return Container(
      height: 80,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 18, // 底部padding增加安全区域高度
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/images/coin-icon.png', width: 24, height: 24),
          const SizedBox(width: 8),
          Text(
            '贡献内容可获4积分',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Spacer(flex: 6),
          ElevatedButton.icon(
            onPressed: () {
              // 跳转到发布评论页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => Scaffold(
                        appBar: AppBar(title: const Text('发布评论')),
                        body: const Center(child: Text('评论发布页面')),
                      ),
                ),
              );
            },
            icon: Image.asset(
              'assets/images/write.png',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
            label: const Text('发布评论', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
