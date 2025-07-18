import 'dart:io';

import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/views/page_login.dart';
import 'package:cryptosquare/widget/social_share_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:cryptosquare/rest_service/user_client.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isCollected = false; // 收藏状态
  bool _isCollectLoading = false; // 收藏操作加载状态

  // 存储文章中的图片URL列表，用于分享
  List<String> imgList = [];

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
          // 设置收藏状态
          _isCollected = _articleData?.userext?.isFavorite == 1;
        });

        // 提取HTML内容中的图片URL
        _extractImagesFromHtml(_articleData?.content ?? '');
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
        GStorage().getLanguageCN() ? 0 : 1, // 默认使用中文，可以根据实际需求修改
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
          // 收藏按钮
          IconButton(
            icon:
                _isCollectLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    )
                    : Image.asset(
                      _isCollected
                          ? 'assets/images/star_fill.png'
                          : 'assets/images/star.png',
                      width: 24,
                      height: 24,
                    ),
            onPressed: _toggleCollect,
          ),
          // 分享按钮
          IconButton(
            icon: Image.asset('assets/images/share.png', width: 24, height: 24),
            onPressed: () {
              // 分享功能实现
              _shareArticle();
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

  // 从HTML内容中提取图片URL
  void _extractImagesFromHtml(String htmlContent) {
    // 清空之前的图片列表
    imgList.clear();

    // 使用正则表达式匹配所有<img>标签的src属性
    final RegExp imgRegExp = RegExp(
      r'<img[^>]+src="([^"]+)"[^>]*>',
      caseSensitive: false,
    );
    final matches = imgRegExp.allMatches(htmlContent);

    // 提取所有匹配的图片URL
    for (final match in matches) {
      if (match.groupCount >= 1) {
        final imgUrl = match.group(1);
        if (imgUrl != null && imgUrl.isNotEmpty) {
          imgList.add(imgUrl);
        }
      }
    }

    // 打印提取到的图片URL，用于调试
    print('提取到的图片URL列表: $imgList');
  }

  // 从HTML内容中提取纯文本
  String _extractPlainTextFromHtml(String htmlContent) {
    // 移除所有HTML标签
    String plainText = htmlContent.replaceAll(RegExp(r'<[^>]*>'), '');

    // 移除多余的空白字符
    plainText = plainText.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 解码HTML实体
    plainText = plainText
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // 截取前50个字符作为描述（如果文本长度超过50个字符）
    if (plainText.length > 50) {
      plainText = plainText.substring(0, 50);
    }

    return plainText;
  }

  // 分享文章
  void _shareArticle() {
    String? sharedImg;

    // 从图片列表中选择第一张有效图片
    if (imgList.isEmpty) {
      // 如果没有图片，使用作者头像
      sharedImg ??= _articleData?.extension?.auth?.avatar;
    } else {
      // 遍历图片列表，选择第一张有效图片
      for (var img in imgList) {
        if (img.contains('.png') ||
            img.contains('.jpg') ||
            img.contains('.jpeg') ||
            img.contains('.webp')) {
          sharedImg = img;
          break;
        }
      }
    }

    // 如果仍然没有图片，使用默认头像
    sharedImg ??= "assets/images/avatar.png";

    if (_articleData != null) {
      // 根据用户是否是作者和语言设置构建前缀消息
      final bool isOwner = _articleData?.user == userController.user.id;
      final bool isWeb3 = _articleData?.type == 'web3';
      final bool isLanguageCN = GStorage().getLanguageCN();

      var prefixMessage =
          isOwner
              ? isLanguageCN
                  ? isWeb3
                      ? "我发布了一篇Web3笔记:"
                      : "我发布了一篇笔记"
                  : isWeb3
                  ? "I posted a Web3 Note:"
                  : "I posted a Note:"
              : '';

      // 构建分享链接
      final String shareLink =
          _articleData?.link ??
          "https://cryptosquare.org/bbs/${_articleData?.id}?lng=zh-CN"; // "https://cryptosquare.org/bbs/8033?lng=zh-CN"

      // 显示分享底部弹窗
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SocialShareWidget(
            title: "$prefixMessage${_articleData?.title}",
            desc: _extractPlainTextFromHtml(_articleData!.content ?? ''),
            url: shareLink,
            imgUrl: sharedImg,
          );
        },
      );
    }
  }

  // 预处理HTML内容，修复行间距问题
  String _preprocessHtmlContent(String htmlContent) {
    if (htmlContent.isEmpty) return htmlContent;

    String processedContent = htmlContent;

    // 1. 移除开头和结尾的空白段落（只移除明显的空段落）
    processedContent = processedContent.replaceAll(
      RegExp(r'^(\s*<p[^>]*>\s*<br\s*/?>\s*</p>\s*){2,}'),
      '',
    );
    processedContent = processedContent.replaceAll(
      RegExp(r'(\s*<p[^>]*>\s*<br\s*/?>\s*</p>\s*){2,}$'),
      '',
    );

    // 2. 移除只包含空白内容的段落
    processedContent = processedContent.replaceAll(
      RegExp(r'<p[^>]*>\s*(&nbsp;|\s)*\s*</p>'),
      '',
    );

    // 3. 移除只包含br标签的段落
    processedContent = processedContent.replaceAll(
      RegExp(r'<p[^>]*>\s*<br\s*/?>\s*</p>'),
      '',
    );

    // 4. 处理多个连续的br标签
    // 将3个或以上的br合并为1个br
    processedContent = processedContent.replaceAll(
      RegExp(r'(<br\s*/?>\s*){3,}'),
      '<br/>',
    );
    // 将2个连续的br合并为1个br
    processedContent = processedContent.replaceAll(
      RegExp(r'(<br\s*/?>\s*){2}'),
      '<br/>',
    );

    // 5. 移除段落开头和结尾的br标签
    processedContent = processedContent.replaceAll(
      RegExp(r'<p([^>]*)>\s*<br\s*/?>\s*'),
      '<p\$1>',
    );
    processedContent = processedContent.replaceAll(
      RegExp(r'\s*<br\s*/?>\s*</p>'),
      '</p>',
    );

    // 6. 处理段落之间的多余br标签
    processedContent = processedContent.replaceAll(
      RegExp(r'</p>\s*<br\s*/?>\s*<p'),
      '</p><p',
    );

    // 7. 处理hr标签周围的空白
    // 移除hr标签前后的多余br标签和空白段落
    processedContent = processedContent.replaceAll(
      RegExp(r'<br\s*/?>\s*<hr\s*/?>\s*<br\s*/?>'),
      '<hr/>',
    );
    processedContent = processedContent.replaceAll(
      RegExp(r'</p>\s*<br\s*/?>\s*<hr\s*/?>'),
      '</p><hr/>',
    );
    processedContent = processedContent.replaceAll(
      RegExp(r'<hr\s*/?>\s*<br\s*/?>\s*<p'),
      '<hr/><p',
    );
    processedContent = processedContent.replaceAll(
      RegExp(r'</blockquote>\s*<br\s*/?>\s*<hr\s*/?>'),
      '</blockquote><hr/>',
    );
    processedContent = processedContent.replaceAll(
      RegExp(r'<hr\s*/?>\s*<br\s*/?>\s*<p'),
      '<hr/><p',
    );

    // 8. 移除或修改过大的line-height样式
    processedContent = processedContent.replaceAll(
      RegExp(r'line-height:\s*\d+px;?'),
      '',
    );

    // 9. 替换过大的line-height值（超过32px的）
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'line-height:\s*(\d+)px'),
      (match) {
        int lineHeight = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (lineHeight > 32) {
          return 'line-height: 1.6';
        }
        return match.group(0) ?? '';
      },
    );

    // 10. 处理过大的padding值
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'padding-top:\s*(\d+)px'),
      (match) {
        int padding = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (padding > 16) return 'padding-top: 4px';
        return match.group(0) ?? '';
      },
    );

    processedContent = processedContent.replaceAllMapped(
      RegExp(r'padding-bottom:\s*(\d+)px'),
      (match) {
        int padding = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (padding > 16) return 'padding-bottom: 4px';
        return match.group(0) ?? '';
      },
    );

    // 11. 移除过大的margin值
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'margin-top:\s*(\d+)px'),
      (match) {
        int margin = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (margin > 12) return 'margin-top: 6px';
        return match.group(0) ?? '';
      },
    );

    processedContent = processedContent.replaceAllMapped(
      RegExp(r'margin-bottom:\s*(\d+)px'),
      (match) {
        int margin = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (margin > 12) return 'margin-bottom: 6px';
        return match.group(0) ?? '';
      },
    );

    // 12. 只移除明显不需要的内联样式属性
    List<String> unwantedStyles = [
      'box-sizing[^;]*;?',
      'text-wrap-mode[^;]*;?',
    ];

    for (String style in unwantedStyles) {
      processedContent = processedContent.replaceAll(RegExp(style), '');
    }

    // 13. 清理空的style属性
    processedContent = processedContent.replaceAll(RegExp(r'style="\s*"'), '');

    return processedContent;
  }

  Widget _buildArticleContent() {
    // 获取屏幕宽度并计算图片适合的像素宽度
    final screenWidth = MediaQuery.of(context).size.width;
    // 减去左右padding (16 * 2 = 32)，得到可用像素宽度
    final imageWidthPx = (screenWidth - 32).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      // 使用 SelectionArea 包装 Html 组件，使其内容可选择和复制
      child: SelectionArea(
        child: Html(
          data: _preprocessHtmlContent(
            _articleData?.content ?? '',
          ), // 预处理HTML内容
          style: {
            'body': Style(
              fontSize: FontSize(16.0),
              lineHeight: LineHeight(1.6),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            'h1': Style(
              fontSize: FontSize(20.0),
              fontWeight: FontWeight.bold,
              margin: Margins.only(top: 16, bottom: 8),
              lineHeight: LineHeight(1.4),
            ),
            'h2': Style(
              fontSize: FontSize(20.0),
              fontWeight: FontWeight.bold,
              margin: Margins.only(top: 16, bottom: 8),
              lineHeight: LineHeight(1.4),
            ),
            'h3': Style(
              fontSize: FontSize(18.0),
              fontWeight: FontWeight.bold,
              margin: Margins.only(top: 12, bottom: 6),
              lineHeight: LineHeight(1.4),
            ),
            // 修复p标签的行间距问题，覆盖内联样式
            'p': Style(
              margin: Margins.only(bottom: 8),
              lineHeight: LineHeight(1.6), // 强制设置合理的行间距
              fontSize: FontSize(16.0), // 确保字体大小一致
              padding: HtmlPaddings.zero,
            ),
            // 控制br标签间距
            'br': Style(
              margin: Margins.only(bottom: 2),
              lineHeight: LineHeight(0.5),
            ),
            // 控制hr标签间距
            'hr': Style(
              margin: Margins.only(top: 12, bottom: 12),
              height: Height(1),
              backgroundColor: const Color(0xFFE5E7EB),
            ),
            // 图片样式配置 - 使用计算出的像素宽度（默认单位px）
            'img': Style(
              width: Width(imageWidthPx), // 计算出的像素宽度，默认单位px
              margin: Margins.only(top: 8, bottom: 8),
            ),
            // blockquote样式
            'blockquote': Style(
              margin: Margins.only(left: 12, top: 8, bottom: 8),
              padding: HtmlPaddings.only(left: 12),
              border: const Border(
                left: BorderSide(color: Colors.grey, width: 3),
              ),
              backgroundColor: const Color(0xFFF5F5F5),
              fontStyle: FontStyle.italic,
            ),
            // 为有序列表添加样式
            'ol': Style(
              padding: HtmlPaddings.only(left: 20), // 为数字标识留出空间
              margin: Margins.only(bottom: 12),
              listStylePosition: ListStylePosition.outside, // 数字在内容外侧
              display: Display.block,
            ),
            'ul': Style(
              // 清除 ul 默认内边距和外边距
              padding: HtmlPaddings.only(left: 20),
              margin: Margins.only(bottom: 12),
              // 把 • 放到行外，保持一致性
              listStylePosition: ListStylePosition.outside,
              display: Display.block,
            ),
            'li': Style(
              // 为li元素设置适当的边距
              padding: HtmlPaddings.zero,
              margin: Margins.only(bottom: 6),
              lineHeight: LineHeight(1.6), // 为li也设置合理的行间距
              display: Display.listItem, // 确保作为列表项显示
            ),
            // 为strong标签添加样式
            'strong': Style(fontWeight: FontWeight.bold),
            'b': Style(fontWeight: FontWeight.bold),
            // 为span标签添加样式，防止特殊样式干扰
            'span': Style(lineHeight: LineHeight(1.6)),
          },
          onLinkTap: (url, attributes, element) {
            if (url != null) {
              _handleLinkTap(url);
            }
          },
        ),
      ),
    );
  }

  Widget _buildArticleTags() {
    final tags = _articleData?.extension?.tag;
    if (tags == null || tags.isEmpty) {
      return const SizedBox.shrink();
    }

    // 过滤：只保留 value 字段不为 null 且去掉空白后长度 > 0 的标签
    final nonEmptyTags =
        tags.where((tag) {
          // 假设 tag 是一个 Map 或者一个有 value 属性的对象
          final rawValue =
              tag is Map ? tag['value'] : (tag.value); // 如果是自定义类，使用 tag.value
          if (rawValue == null) return false;
          final str = rawValue.toString().trim();
          return str.isNotEmpty;
        }).toList();

    if (nonEmptyTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            nonEmptyTags.map((tag) {
              final rawValue = tag is Map ? tag['value'] : (tag.value);
              final text = rawValue.toString().trim();

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
                  text,
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
            '发布评论可得2积分',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Spacer(flex: 6),
          ElevatedButton.icon(
            onPressed: () {
              // 检查用户是否已登录
              if (!userController.isLoggedIn && !GStorage().getLoginStatus()) {
                // 未登录，显示居中对话框提示
                Get.dialog(
                  AlertDialog(
                    title: const Text('提示'),
                    content: const Text('请先登录后再发布评论'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // 用户点击取消，关闭对话框
                          Get.back();
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // 用户点击去登录，关闭对话框后跳转到登录页面
                          Get.back();
                          // 跳转到登录页面
                          Get.to(() => const LoginPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('去登录'),
                      ),
                    ],
                  ),
                  barrierDismissible: true, // 允许用户点击外部关闭对话框
                );
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
      // 未登录，显示居中对话框提示
      Get.dialog(
        AlertDialog(
          title: const Text('提示'),
          content: const Text('请先登录后再发布评论'),
          actions: [
            TextButton(
              onPressed: () {
                // 用户点击取消，关闭对话框
                Get.back();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                // 用户点击去登录，关闭对话框后跳转到登录页面
                Get.back();
                // 跳转到登录页面
                Get.to(() => const LoginPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('去登录'),
            ),
          ],
        ),
        barrierDismissible: true, // 允许用户点击外部关闭对话框
      );
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
        await _loadArticleComments();

        // 更新评论数量：当_comments不为null时，使用实际评论数量更新_articleData
        if (_comments != null && _articleData != null) {
          setState(() {
            // 计算顶级评论数量（不包括回复）
            final topLevelComments =
                _comments!
                    .where(
                      (comment) =>
                          comment.parentComment == null ||
                          comment.parentComment == 0,
                    )
                    .toList();

            // 计算总评论数量（包括回复）
            int totalComments = topLevelComments.length;
            for (final comment in topLevelComments) {
              totalComments += (comment.reply?.length ?? 0);
            }

            // 更新文章数据中的评论数量
            _articleData = ArticleDetailData(
              id: _articleData!.id,
              title: _articleData!.title,
              content: _articleData!.content,
              user: _articleData!.user,
              status: _articleData!.status,
              type: _articleData!.type,
              createdAt: _articleData!.createdAt,
              updatedAt: _articleData!.updatedAt,
              lang: _articleData!.lang,
              lastView: _articleData!.lastView,
              lastViewUser: _articleData!.lastViewUser,
              replyNums: totalComments, // 更新评论数量
              replyUser: _articleData!.replyUser,
              ding: _articleData!.ding,
              cai: _articleData!.cai,
              replyTime: _articleData!.replyTime,
              catId: _articleData!.catId,
              origin: _articleData!.origin,
              originLink: _articleData!.originLink,
              createTime: _articleData!.createTime,
              profile: _articleData!.profile,
              hasTag: _articleData!.hasTag,
              sh5: _articleData!.sh5,
              startTime: _articleData!.startTime,
              endTime: _articleData!.endTime,
              isTop: _articleData!.isTop,
              isHot: _articleData!.isHot,
              contact: _articleData!.contact,
              address: _articleData!.address,
              trackId: _articleData!.trackId,
              extension: _articleData!.extension,
              userext: _articleData!.userext,
              comments: _articleData!.comments,
              catInfo: _articleData!.catInfo,
              link: _articleData!.link,
              relNews: _articleData!.relNews,
            );
          });
        }

        // 显示成功提示
        Get.dialog(
          AlertDialog(
            title: const Text('提示'),
            content: const Text('评论发布成功,已获得2积分奖励'),
          ),
          barrierDismissible: true, // 允许点击外部关闭
        );

        // 1秒后自动关闭对话框
        Future.delayed(const Duration(seconds: 1), () {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
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

  // 处理收藏/取消收藏
  Future<void> _toggleCollect() async {
    // 检查用户是否登录
    if (!userController.isLoggedIn) {
      // 未登录，提示用户登录
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先登录后再收藏')));

      // 跳转到登录页面
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const LoginPage()));
      return;
    }

    // 防止重复点击
    if (_isCollectLoading) return;

    setState(() {
      _isCollectLoading = true;
    });

    try {
      final userClient = UserRestClient();
      final response = await userClient.doAction(
        widget.articleId,
        'eye', // 收藏操作的action参数为eye
      );

      if (response.code == 0 && response.data != null) {
        // 根据返回值更新收藏状态
        setState(() {
          _isCollected = response.data!.value == 1;
          _isCollectLoading = false;
        });

        // 显示操作结果
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isCollected ? '收藏成功' : '取消收藏成功')),
        );
      } else {
        setState(() {
          _isCollectLoading = false;
        });
        // 显示错误信息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message ?? '操作失败')));
      }
    } catch (e) {
      setState(() {
        _isCollectLoading = false;
      });
      // 显示错误信息
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('网络错误: ${e.toString()}')));
    }
  }

  // 处理链接点击事件
  Future<void> _handleLinkTap(String url) async {
    try {
      // 检查URL是否是http或https协议
      if (url.startsWith('http://') || url.startsWith('https://')) {
        final uri = Uri.parse(url);
        // 检查是否可以启动该URL
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // 使用外部浏览器打开
          );
        } else {
          // 无法打开链接时显示提示
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('无法打开链接: $url')));
        }
      } else {
        // 不是http(s)链接时显示提示
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('不支持的链接类型: $url')));
      }
    } catch (e) {
      // 发生错误时显示提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('打开链接时发生错误: ${e.toString()}')));
    }
  }
}
