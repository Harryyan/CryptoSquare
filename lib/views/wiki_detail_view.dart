import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cryptosquare/theme/app_theme.dart';

class WikiDetailView extends StatelessWidget {
  final String wikiName;

  const WikiDetailView({Key? key, required this.wikiName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(wikiName),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTags(),
            ),

            const SizedBox(height: 32),

            // 投资人/机构
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInvestorsSection(),
            ),

            const SizedBox(height: 32),

            // 团队成员
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTeamMembersSection(),
            ),

            const SizedBox(height: 32),

            // 投资项目
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInvestmentsSection(),
            ),

            const SizedBox(height: 32),

            // 社交链接
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSocialLinks(),
            ),

            const SizedBox(height: 24),

            // 网址
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildWebsite(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 顶部Header：Logo + 标题 + 副标题
  Widget _buildHeader() {
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
            child: Center(
              child: Text(
                'STARKWARE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
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
                  wikiName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '区块链隐私解决方案提供商',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    String description = '';
    if (wikiName == 'StarkWare') {
      description = '''区块链隐私解决方案提供商 StarkWare，总部位于以色列内坦亚 Netanya，公司两位联合创始人 Eli Ben-Sasson 和 Alessandro Chiesa 也是 ZCash 创始人。其主要目标是进一步推广以色列理工学院研发的 zk-Starks 突破性区块链隐私解决方案。其延续了零知识证明协议保护区块链上的信息隐私，一方面可以支持将海量数据压缩成为更小的样本，另一方面也比量子计算更高效、透明和安全。一大优势就是在证明隐私信息的同时，确保计算完整性且无需耗费大量算力。

投资方包括 Pantera、Floodgate、Polychain Capital、MetaStable、Naval Ravikant、ZCash、比特大陆，以及以太坊联合创始人 Vitalik Buterin 等。''';
    } else {
      description = '关于 $wikiName 的详细信息...';
    }

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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTagButton('Coinbase'),
        _buildTagButton('匿名隐私'),
        _buildTagButton('Rollup'),
      ],
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
        ..._getInvestors().map((item) => _buildInvestorItem(item)),
      ],
    );
  }

  Widget _buildInvestorItem(InvestorItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: item.url != null
            ? () async {
                final uri = Uri.parse(item.url!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo占位符
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.logoUrl!,
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
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: item.url != null
                          ? AppTheme.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  if (item.url != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.url!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  if (item.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description!,
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
        ..._getTeamMembers().map((member) => _buildTeamMemberItem(member)),
      ],
    );
  }

  Widget _buildTeamMemberItem(TeamMember member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像占位符
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(28),
            ),
            child: member.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      member.avatarUrl!,
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
                  member.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (member.title != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.title!,
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
        ..._getInvestments().map((item) => _buildInvestmentItem(item)),
      ],
    );
  }

  Widget _buildInvestmentItem(InvestmentItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: item.url != null
            ? () async {
                final uri = Uri.parse(item.url!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo占位符
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.logoUrl!,
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
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: item.url != null
                          ? AppTheme.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  if (item.url != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.url!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  if (item.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description!,
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
          children: [
            _buildSocialButton(
              'Linkedin',
              Icons.business,
              'https://www.linkedin.com/company/starkware',
            ),
            _buildSocialButton(
              'Medium',
              Icons.article,
              'https://medium.com/starkware',
            ),
            _buildSocialButton(
              'Twitter',
              Icons.chat_bubble_outline,
              'https://twitter.com/starkwareltd',
            ),
            _buildSocialButton(
              'Github',
              Icons.code,
              'https://github.com/starkware-libs',
            ),
          ],
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
            const url = 'https://www.starkware.co/';
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: const Text(
            'https://www.starkware.co/',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // Hardcode 数据方法
  List<InvestorItem> _getInvestors() {
    return [
      InvestorItem(
        name: 'Zcash',
        description: '首个使用零知识证明的区块链系统，隐藏链上交易相关信息。',
        url: 'https://z.cash/',
      ),
      InvestorItem(
        name: 'Pantera Capital',
        description: 'Dan Morehead 创办，专注于区块链的早期投资。',
        url: 'https://panteracapital.com/firm/',
      ),
      InvestorItem(
        name: 'Polychain Capital',
        description: '通过积极管理区块链资产的投资组合，带给投资者丰厚回报。',
        url: 'http://polychain.capital',
      ),
      InvestorItem(
        name: 'MetaStable',
        description: 'Naval Ravikant 参与创办的加密数字对冲基金。',
        url: 'http://www.metastablecapital.com/',
      ),
      InvestorItem(
        name: 'Paradigm',
        description: 'Coinbase 联合创始人 Fred Ehrsam 组建的加密投资基金。',
        url: 'https://paradigm.xyz/',
      ),
      InvestorItem(
        name: 'Coinbase Ventures',
        description: '隶属于 Coinbase 的风险投资基金。',
        url: 'https://ventures.coinbase.com/',
      ),
      InvestorItem(
        name: '比特大陆',
        description: '加密货币挖矿领域无可争议的世界领导者。',
        url: 'https://www.bitmain.com/',
      ),
    ];
  }

  List<TeamMember> _getTeamMembers() {
    return [
      TeamMember(
        name: 'Louis Guthmann',
        title: 'StarkWare 产品经理',
      ),
      TeamMember(
        name: 'Michael Riabzev',
        title: 'StarkWare 联合创始人兼首席架构师',
      ),
      TeamMember(
        name: 'Uri Kolodny',
        title: 'Co-Founder & CEO of StarkWare',
      ),
    ];
  }

  List<InvestmentItem> _getInvestments() {
    return [
      InvestmentItem(
        name: 'dYdX',
        description: '去中心化数字资产衍生品交易平台。',
        url: 'https://dydx.exchange/',
      ),
      InvestmentItem(
        name: 'STARKEx',
        description: '支持可扩展的非托管交易。',
        url: 'https://starkware.co/product/starkex/',
      ),
      InvestmentItem(
        name: 'XMTP',
        description: 'web3加密通信协议与网络。',
        url: 'https://xmtp.com',
      ),
      InvestmentItem(
        name: 'StarkNet',
        description: '无需许可的去中心化 ZK-Rollup',
        url: 'https://starknet.io/',
      ),
      InvestmentItem(
        name: 'zkLend',
        description: 'Layer 2 DeFi 协议。',
        url: 'https://zklend.com/',
      ),
      InvestmentItem(
        name: 'StarkGate',
        description: 'StarkNet大桥。',
        url: 'https://starkgate.starknet.io/',
      ),
    ];
  }
}

// 数据模型
class InvestorItem {
  final String name;
  final String? description;
  final String? url;
  final String? logoUrl;

  InvestorItem({
    required this.name,
    this.description,
    this.url,
    this.logoUrl,
  });
}

class TeamMember {
  final String name;
  final String? title;
  final String? avatarUrl;

  TeamMember({
    required this.name,
    this.title,
    this.avatarUrl,
  });
}

class InvestmentItem {
  final String name;
  final String? description;
  final String? url;
  final String? logoUrl;

  InvestmentItem({
    required this.name,
    this.description,
    this.url,
    this.logoUrl,
  });
}
