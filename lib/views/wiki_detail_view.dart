import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:cryptosquare/model/wiki_list.dart';
import 'package:cryptosquare/util/storage.dart';
import 'dart:io';

class WikiDetailView extends StatefulWidget {
  final String slug;

  const WikiDetailView({Key? key, required this.slug}) : super(key: key);

  @override
  State<WikiDetailView> createState() => _WikiDetailViewState();
}

class _WikiDetailViewState extends State<WikiDetailView> {
  final RestClient _restClient = RestClient();
  WikiDetailData? _wikiData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWikiDetail();
  }

  Future<void> _loadWikiDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 获取平台信息
      String platform = 'ios';
      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        platform = 'pc';
      }

      // 获取语言设置
      int lang = GStorage().getLanguageCN() ? 1 : 0;

      // 调用API获取Wiki详情
      final response = await _restClient.getWikiDetail(
        widget.slug,
        lang,
        platform,
      );

      if (response.code == 0 && response.data != null) {
        setState(() {
          _wikiData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.message ?? '加载失败';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载失败: $e';
      });
      print('加载Wiki详情失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_wikiData?.name ?? '加载中...'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadWikiDetail,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _wikiData == null
                  ? const Center(child: Text('暂无数据'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 顶部：Logo + 标题 + 副标题
                          _buildHeader(),

                          const SizedBox(height: 24),

                          // 描述
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildDescription(),
                          ),

                          const SizedBox(height: 24),

                          // 标签按钮
                          if (_wikiData!.tags != null &&
                              _wikiData!.tags!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildTags(),
                            ),

                          if (_wikiData!.tags != null &&
                              _wikiData!.tags!.isNotEmpty)
                            const SizedBox(height: 32),

                          // 投资人/机构
                          if (_wikiData!.investors != null &&
                              _wikiData!.investors!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildInvestorsSection(),
                            ),

                          if (_wikiData!.investors != null &&
                              _wikiData!.investors!.isNotEmpty)
                            const SizedBox(height: 32),

                          // 团队成员
                          if (_wikiData!.members != null &&
                              _wikiData!.members!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildTeamMembersSection(),
                            ),

                          if (_wikiData!.members != null &&
                              _wikiData!.members!.isNotEmpty)
                            const SizedBox(height: 32),

                          // 投资项目
                          if (_wikiData!.portfolio != null &&
                              _wikiData!.portfolio!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildInvestmentsSection(),
                            ),

                          if (_wikiData!.portfolio != null &&
                              _wikiData!.portfolio!.isNotEmpty)
                            const SizedBox(height: 32),

                          // 社交链接
                          if (_wikiData!.social != null &&
                              _hasSocialLinks(_wikiData!.social!))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildSocialLinks(),
                            ),

                          if (_wikiData!.social != null &&
                              _hasSocialLinks(_wikiData!.social!))
                            const SizedBox(height: 24),

                          // 网址
                          if (_wikiData!.webSite != null &&
                              _wikiData!.webSite!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildWebsite(),
                            ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }

  bool _hasSocialLinks(SocialLinks social) {
    return (social.twitter != null && social.twitter!.isNotEmpty) ||
        (social.medium != null && social.medium!.isNotEmpty) ||
        (social.linkedin != null && social.linkedin!.isNotEmpty) ||
        (social.github != null && social.github!.isNotEmpty) ||
        (social.telegram != null && social.telegram!.isNotEmpty) ||
        (social.youtube != null && social.youtube!.isNotEmpty) ||
        (social.reddit != null && social.reddit!.isNotEmpty);
  }

  // 顶部Header：Logo + 标题 + 副标题
  Widget _buildHeader() {
    final logoUrl = _wikiData?.logoUrl ?? _wikiData?.img;
    final name = _wikiData?.name ?? '';
    final intro = _wikiData?.intro ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A), // 深蓝色
              borderRadius: BorderRadius.circular(8),
            ),
            child: logoUrl != null && logoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      logoUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1E3A8A),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'W',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'W',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          // 标题和副标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (intro.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    intro,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final description = _wikiData?.description ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '描述',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // 标签按钮
  Widget _buildTags() {
    final tags = _wikiData?.tags ?? [];
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _buildTagButton(tag.name ?? '')).toList(),
    );
  }

  Widget _buildTagButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  // 投资人/机构部分
  Widget _buildInvestorsSection() {
    final investors = _wikiData?.investors ?? [];
    if (investors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '投资人/机构',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...investors.map((item) => _buildInvestorItem(item)),
      ],
    );
  }

  Widget _buildInvestorItem(InvestorDetailItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: item.webSite != null && item.webSite!.isNotEmpty
            ? () async {
                final uri = Uri.parse(item.webSite!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.img != null && item.img!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.img!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.business,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.business,
                      color: Colors.grey[400],
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            // 名称、URL和描述
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: item.webSite != null && item.webSite!.isNotEmpty
                          ? AppTheme.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  if (item.webSite != null && item.webSite!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.webSite!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  if (item.intro != null && item.intro!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.intro!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 团队成员部分
  Widget _buildTeamMembersSection() {
    final members = _wikiData?.members ?? [];
    if (members.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '团队成员',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...members.map((member) => _buildTeamMemberItem(member)),
      ],
    );
  }

  Widget _buildTeamMemberItem(MemberDetailItem member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(28),
            ),
            child: member.img != null && member.img!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      member.img!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: 28,
                          ),
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.grey[400],
                    size: 28,
                  ),
          ),
          const SizedBox(width: 12),
          // 姓名和职位
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (member.intro != null && member.intro!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.intro!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 投资项目部分
  Widget _buildInvestmentsSection() {
    final portfolio = _wikiData?.portfolio ?? [];
    if (portfolio.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '投资项目',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...portfolio.map((item) => _buildInvestmentItem(item)),
      ],
    );
  }

  Widget _buildInvestmentItem(PortfolioItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: item.webSite != null && item.webSite!.isNotEmpty
            ? () async {
                final uri = Uri.parse(item.webSite!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.img != null && item.img!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.img!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.business_center,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.business_center,
                      color: Colors.grey[400],
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            // 名称、URL和描述
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: item.webSite != null && item.webSite!.isNotEmpty
                          ? AppTheme.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  if (item.webSite != null && item.webSite!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.webSite!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  if (item.intro != null && item.intro!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.intro!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 社交链接 - 椭圆形按钮，带图标和文字
  Widget _buildSocialLinks() {
    final social = _wikiData?.social;
    if (social == null) return const SizedBox.shrink();

    final socialButtons = <Widget>[];

    if (social.linkedin != null && social.linkedin!.isNotEmpty) {
      socialButtons.add(_buildSocialButton(
        'Linkedin',
        Icons.business,
        social.linkedin!,
      ));
    }
    if (social.medium != null && social.medium!.isNotEmpty) {
      socialButtons.add(_buildSocialButton(
        'Medium',
        Icons.article,
        social.medium!,
      ));
    }
    if (social.twitter != null && social.twitter!.isNotEmpty) {
      socialButtons.add(_buildSocialButton(
        'Twitter',
        Icons.chat_bubble_outline,
        social.twitter!,
      ));
    }
    if (social.github != null && social.github!.isNotEmpty) {
      socialButtons.add(_buildSocialButton(
        'Github',
        Icons.code,
        social.github!,
      ));
    }
    if (social.telegram != null && social.telegram!.isNotEmpty) {
      socialButtons.add(_buildSocialButton(
        'Telegram',
        Icons.send,
        social.telegram!,
      ));
    }
    if (social.youtube != null && social.youtube!.isNotEmpty) {
      socialButtons.add(_buildSocialButton(
        'Youtube',
        Icons.play_circle_outline,
        social.youtube!,
      ));
    }
    if (social.reddit != null && social.reddit!.isNotEmpty) {
      socialButtons.add(_buildSocialButton(
        'Reddit',
        Icons.forum,
        social.reddit!,
      ));
    }

    if (socialButtons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '社交',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: socialButtons,
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 网址
  Widget _buildWebsite() {
    final webSite = _wikiData?.webSite;
    if (webSite == null || webSite.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '网址',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final uri = Uri.parse(webSite);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Text(
            webSite,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
