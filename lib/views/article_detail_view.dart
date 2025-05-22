import 'dart:io';

import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/views/page_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:get/get.dart';
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
  final UserController userController = Get.find<UserController>();
  ArticleDetailData? _articleData;
  List<ArticleCommentItem>? _comments;
  bool _isLoading = true;
  bool _isLoadingComments = true;

  // 评论相关状态
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  // 回复信息
  ArticleCommentItem? _replyToComment;
  String? _replyToUsername;

  @override
  void initState() {
    super.initState();
    _loadArticleDetail();
    _loadArticleComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
        // 加载文章失败，返回上一页
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 显示错误信息
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('网络错误: ${e.toString()}')));
      // 网络错误，返回上一页
      Navigator.of(context).pop();
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
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(child: Text('暂无评论')),
            // 添加底部间距，确保不被底部评论栏遮挡
            const SizedBox(height: 100),
          ],
        ),
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
        // 添加底部间距，确保最后一条评论不被底部评论栏遮挡
        const SizedBox(height: 100),
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
                        GestureDetector(
                          onTap: () {
                            // 设置回复评论
                            setState(() {
                              _replyToComment = comment;
                              _replyToUsername = comment.user?.userNicename;
                            });
                            _showCommentBottomSheet();
                          },
                          child: Text(
                            '回复',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
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
                                GestureDetector(
                                  onTap: () {
                                    // 设置回复评论
                                    setState(() {
                                      _replyToComment = comment;
                                      _replyToUsername =
                                          reply.user?.userNicename;
                                    });
                                    _showCommentBottomSheet();
                                  },
                                  child: Text(
                                    '回复',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
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
              // 检查用户是否已登录
              if (!userController.isLoggedIn && !GStorage().getLoginStatus()) {
                // 未登录，跳转到登录页面
                Get.to(() => const LoginPage());
                return;
              }

              // 已登录，清除回复信息，直接评论文章
              setState(() {
                _replyToComment = null;
                _replyToUsername = null;
              });
              _showCommentBottomSheet();
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

  // 显示评论输入底部弹窗
  void _showCommentBottomSheet() {
    // 再次检查用户是否已登录（以防用户状态在此期间发生变化）
    if (!userController.isLoggedIn && !GStorage().getLoginStatus()) {
      // 未登录，跳转到登录页面
      Get.to(() => const LoginPage());
      return;
    }

    // 清空输入框
    _commentController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _replyToUsername != null ? '回复评论' : '发表评论',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText:
                        _replyToUsername != null
                            ? '回复@$_replyToUsername：'
                            : '回复：',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2563EB)),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              '发布',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // 提交评论
  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('评论内容不能为空')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final client = RestClient();
      final response = await client.postArticleComment(
        widget.articleId,
        Platform.isAndroid ? "android" : "ios",
        comment,
        _replyToComment?.id, // 如果是回复评论，传入评论ID
        GStorage().getLanguageCN() ? 1 : 0,
      );

      if (response.code == 0) {
        // 评论成功，关闭底部弹窗
        Navigator.pop(context);

        // 重新加载评论列表
        _loadArticleComments();

        // 显示成功提示
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('评论发布成功')));
      } else {
        // 显示错误信息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message ?? '评论发布失败')));
      }
    } catch (e) {
      // 显示错误信息
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('评论发布失败: ${e.toString()}')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
