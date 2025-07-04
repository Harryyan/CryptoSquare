import 'package:cryptosquare/controllers/job_controller.dart';
import 'package:cryptosquare/controllers/home_controller.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'package:cryptosquare/views/page_login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/util/language_management.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cryptosquare/widget/social_share_widget.dart';
import 'package:flutter/services.dart';

class JobDetailView extends GetView<JobController> {
  final String title;
  final String company;
  final String salary;
  final String publishTime;
  final List<String> tags;
  final String description;

  // RestClient实例
  final RestClient _restClient = RestClient();

  JobDetailView({
    Key? key,
    required this.title,
    required this.company,
    required this.salary,
    required this.publishTime,
    required this.tags,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('岗位详情'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset('assets/images/share.png', width: 24, height: 24),
            onPressed: () {
              _shareJob();
            },
          ),
        ],
      ),
      body: Obx(
        () =>
            controller.currentJobDetail.value == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildJobHeader(),
                            // 添加灰色背景区域作为明显的分隔
                            Container(
                              height: 12,
                              color: const Color(0xFFF5F5F5),
                            ),
                            _buildJobDescription(),
                          ],
                        ),
                      ),
                    ),
                    _buildApplyButton(),
                  ],
                ),
      ),
    );
  }

  // 岗位头部信息
  Widget _buildJobHeader() {
    // 使用API返回的数据，如果没有则使用构造函数传入的数据
    final jobDetail = controller.currentJobDetail.value;
    
    // 处理title，从"xxx|xxx|xxx"格式中提取第二个部分
    String displayTitle = jobDetail?.jobTitle ?? title;
    if (displayTitle.contains('|')) {
      final titleParts = displayTitle.split('|');
      if (titleParts.length >= 2) {
        displayTitle = titleParts[1].trim(); // 取第二个部分并去除空格
      }
    }
    
    final displayCompany = jobDetail?.jobCompany ?? company;

    // 处理薪资显示
    String displaySalary = salary;
    if (jobDetail != null &&
        jobDetail.minSalary != null &&
        jobDetail.maxSalary != null) {
      final minSalary = jobDetail.minSalary!;
      final maxSalary = jobDetail.maxSalary!;

      // 如果薪资为0，显示面议
      if (minSalary == 0 && maxSalary == 0) {
        displaySalary = '面议';
      } else {
        // 根据货币类型显示对应的符号
        String currencySymbol = '¥';
        if (jobDetail.jobSalaryCurrency?.toLowerCase() == 'usd') {
          currencySymbol = '\$';
        } else if (jobDetail.jobSalaryCurrency?.toLowerCase() == 'rmb') {
          currencySymbol = '¥';
        }

        // 根据app语言设置显示单位
        String unitDisplay = jobDetail.jobSalaryUnit ?? 'K';
        if (unitDisplay.toLowerCase() == 'month') {
          // 根据当前语言设置显示月份
          unitDisplay = LanguageManagement.language() == 1 ? '/月' : '/month';
        }

        // 添加千位分隔符并在减号两侧添加空格，与首页列表项保持一致
        final formattedMinSalary = minSalary.toString().replaceAllMapped(
          RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[0]},',
        );
        final formattedMaxSalary = maxSalary.toString().replaceAllMapped(
          RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[0]},',
        );
        displaySalary =
            '$currencySymbol$formattedMinSalary - $formattedMaxSalary$unitDisplay';
      }
    }

    // 构建属性标签列表
    List<String> propertyTags = [];
    
    if (jobDetail != null) {
      // 添加工作类型
      if (jobDetail.jobType?.isNotEmpty == true) {
        propertyTags.add(jobDetail.jobType!);
      }
      
      // 添加办公模式
      if (jobDetail.officeMode != null) {
        if (jobDetail.officeMode == 1) {
          propertyTags.add('远程');
        } else if (jobDetail.officeMode == 0) {
          propertyTags.add('实地');
        }
      }
      
      // 添加语言要求
      if (jobDetail.jobLang != null && jobDetail.jobLang == 1) {
        propertyTags.add('英语');
      }
    }

    // 格式化时间显示
    String formattedTime = publishTime;
    
    // 内部方法：尝试使用createTime
    void tryUseCreateTime() {
      try {
        // 从Unix时间戳创建UTC时间，避免时区问题
        final DateTime postTimeUtc = DateTime.fromMillisecondsSinceEpoch(
          jobDetail!.createTime! * 1000, 
          isUtc: true
        );
        final DateTime nowUtc = DateTime.now().toUtc();
        final Duration difference = nowUtc.difference(postTimeUtc);

        // 小于1小时
        if (difference.inHours < 1) {
          final minutes = difference.inMinutes;
          // 防止显示负数分钟
          if (minutes <= 0) {
            formattedTime = '刚刚';
          } else {
            formattedTime = '$minutes分钟前';
          }
        }
        // 小于24小时
        else if (difference.inHours < 24) {
          formattedTime = '${difference.inHours}小时前';
        }
        // 小于7天
        else if (difference.inDays < 7) {
          formattedTime = '${difference.inDays}天前';
        }
        // 超过7天，转换为本地时间显示
        else {
          final localTime = postTimeUtc.toLocal();
          formattedTime = '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        // createTime解析也失败时，保持原始值
        formattedTime = publishTime;
      }
    }
    
    // 首先尝试使用传入的publishTime（来自首页，与首页显示保持一致）
    if (publishTime.isNotEmpty && publishTime != '发布时间') {
      try {
        // 使用与JobPost.getFormattedTime()相同的逻辑处理publishTime
        DateTime postTime;
        if (publishTime.contains('T')) {
          // ISO 8601格式，如果没有时区信息，则作为UTC处理
          if (publishTime.endsWith('Z') || publishTime.contains('+') || publishTime.contains('-')) {
            postTime = DateTime.parse(publishTime);
          } else {
            // 如果没有时区信息，添加Z后缀作为UTC时间处理
            postTime = DateTime.parse(publishTime + 'Z');
          }
        } else {
          // 非ISO格式，尝试直接解析
          postTime = DateTime.parse(publishTime);
        }
        
        // 确保都转换为UTC进行计算
        final DateTime postTimeUtc = postTime.toUtc();
        final DateTime nowUtc = DateTime.now().toUtc();
        final Duration difference = nowUtc.difference(postTimeUtc);

        // 小于1小时
        if (difference.inHours < 1) {
          final minutes = difference.inMinutes;
          // 防止显示负数分钟
          if (minutes <= 0) {
            formattedTime = '刚刚';
          } else {
            formattedTime = '$minutes分钟前';
          }
        }
        // 小于24小时
        else if (difference.inHours < 24) {
          formattedTime = '${difference.inHours}小时前';
        }
        // 小于7天
        else if (difference.inDays < 7) {
          formattedTime = '${difference.inDays}天前';
        }
        // 超过7天，转换为本地时间显示
        else {
          final localTime = postTimeUtc.toLocal();
          formattedTime = '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        // publishTime解析失败，尝试使用API返回的createTime
        print('解析publishTime失败: $e，尝试使用createTime');
        tryUseCreateTime();
      }
    } else if (jobDetail?.createTime != null) {
      // 如果没有有效的publishTime，使用API返回的createTime
      tryUseCreateTime();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 职位名称和收藏按钮
          Row(
            children: [
              Expanded(
                child: Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _toggleJobFavorite(),
                child: Obx(() {
                  final isCollected = controller.currentJobDetail.value?.jobIsCollect == 1;
                  return Image.asset(
                    isCollected
                        ? 'assets/images/star_fill.png'
                        : 'assets/images/star.png',
                    width: 24,
                    height: 24,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 公司名称
          Text(
            displayCompany,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          // 属性标签（工作类型、办公模式、语言要求）
          if (propertyTags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: propertyTags.map((tag) => _buildPropertyTag(tag)).toList(),
            ),

          const SizedBox(height: 12),
          // 添加分隔线
          const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
          // 薪资和发布时间
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displaySalary,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              Text(
                formattedTime,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 属性标签
  Widget _buildPropertyTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.tagBackgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 12, color: AppTheme.tagTextColor),
      ),
    );
  }

  // 预处理HTML内容，清理多余的空白和样式
  String _preprocessJobDescHtml(String htmlContent) {
    if (htmlContent.isEmpty) return htmlContent;

    String processedContent = htmlContent;

    // 1. 移除开头和结尾的空白段落（只移除明显的空段落）
    processedContent = processedContent.replaceAll(RegExp(r'^(\s*<p[^>]*>\s*<br\s*/?>\s*</p>\s*){2,}'), '');
    processedContent = processedContent.replaceAll(RegExp(r'(\s*<p[^>]*>\s*<br\s*/?>\s*</p>\s*){2,}$'), '');

    // 2. 移除只包含空白内容的段落（但保留正常的空行）
    processedContent = processedContent.replaceAll(RegExp(r'<p[^>]*>\s*(&nbsp;|\s)*\s*</p>'), '');

    // 3. 适度清理内联样式中的过大padding（只处理明显过大的）
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'padding-top:\s*(\d+)px'),
      (match) {
        int padding = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (padding > 16) return 'padding-top: 8px';
        return match.group(0) ?? '';
      },
    );

    processedContent = processedContent.replaceAllMapped(
      RegExp(r'padding-bottom:\s*(\d+)px'),
      (match) {
        int padding = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (padding > 16) return 'padding-bottom: 8px';
        return match.group(0) ?? '';
      },
    );

    // 4. 适度清理过大的margin值
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'margin-bottom:\s*(\d+)px'),
      (match) {
        int margin = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (margin > 16) return 'margin-bottom: 12px';
        return match.group(0) ?? '';
      },
    );

    // 5. 清理过大的line-height值
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'line-height:\s*(\d+)px'),
      (match) {
        int lineHeight = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (lineHeight > 32) return 'line-height: 1.8';
        return match.group(0) ?? '';
      },
    );

    // 6. 只移除明显不需要的内联样式属性
    List<String> unwantedStyles = [
      'box-sizing[^;]*;?',
      'text-wrap-mode[^;]*;?',
    ];
    
    for (String style in unwantedStyles) {
      processedContent = processedContent.replaceAll(RegExp(style), '');
    }

    // 7. 清理空的style属性
    processedContent = processedContent.replaceAll(RegExp(r'style="\s*"'), '');

    // 8. 合并过多的连续<br>标签（3个或以上合并为2个）
    processedContent = processedContent.replaceAll(RegExp(r'(<br\s*/?>\s*){3,}'), '<br/><br/>');

    return processedContent;
  }

  // 岗位描述
  Widget _buildJobDescription() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  '岗位描述',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 使用flutter_html渲染预处理后的HTML内容
          SelectionArea(
            child: Html(
              data: _preprocessJobDescHtml(
                controller.currentJobDetail.value?.jobDesc ?? description,
              ),
              style: {
                "body": Style(
                  fontSize: FontSize(15),
                  lineHeight: LineHeight(1.6),
                  color: Colors.black87,
                ),
                "p": Style(
                  margin: Margins.only(bottom: 12),
                  lineHeight: LineHeight(1.6),
                ),
                "br": Style(
                  margin: Margins.only(bottom: 6),
                ),
                "span": Style(
                  lineHeight: LineHeight(1.6),
                ),
                // 只覆盖明显有问题的样式
                "strong": Style(
                  fontWeight: FontWeight.bold,
                ),
              },
            ),
          ),
        ],
      ),
    );
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

  // 分享岗位
  void _shareJob() {
    final jobDetail = controller.currentJobDetail.value;

    if (jobDetail != null) {
      // 构建分享链接
      final String shareLink =
          "https://cryptosquare.org/jobs/${jobDetail.jobKey}?lng=zh-CN";

      // 显示分享底部弹窗
      showModalBottomSheet(
        context: Get.context!,
        builder: (context) {
          return SocialShareWidget(
            title: jobDetail.jobTitle,
            desc: _extractPlainTextFromHtml(jobDetail.jobDesc ?? ''),
            url: shareLink,
            imgUrl: "https://images.bitpush.news/2024/csimgs/logo.jpg",
          );
        },
      );
    }
  }

  // HR联系方式按钮区域
  Widget _buildApplyButton() {
    final UserController userController = Get.find<UserController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左侧 - 预计消耗积分 (仅在未购买时显示)
          if (!(controller.currentJobDetail.value?.apply?.isBuyed == true))
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/coin-icon.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '预计消耗${controller.currentJobDetail.value?.apply?.score ?? 5}积分',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          if (!(controller.currentJobDetail.value?.apply?.isBuyed == true))
            const SizedBox(width: 12),
          // 右侧 - 查看HR联系方式按钮 (当已购买时占据整行)
          Expanded(
            flex:
                controller.currentJobDetail.value?.apply?.isBuyed == true
                    ? 4
                    : 2,
            child: Obx(() {
              final jobDetail = controller.currentJobDetail.value;
              final apply = jobDetail?.apply;
              final bool isBuyed = apply?.isBuyed ?? false;
              final String applyVal = apply?.applyVal ?? '';

              // 根据isBuyed状态决定按钮文字
              String buttonText = '查看HR联系方式';
              if (isBuyed) {
                if (applyVal.toLowerCase().contains('http')) {
                  buttonText = '点击链接查看';
                } else if (applyVal.contains('@')) {
                  buttonText = applyVal;
                } else {
                  buttonText = applyVal.isNotEmpty ? applyVal : '查看HR联系方式';
                }
              }

              // 如果是邮箱，使用GestureDetector包装以支持长按复制
              if (isBuyed && applyVal.contains('@')) {
                return GestureDetector(
                  onLongPress: () {
                    // 复制邮箱到剪贴板
                    Clipboard.setData(ClipboardData(text: applyVal));
                    Get.snackbar(
                      '成功',
                      '邮箱已复制到剪贴板',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppTheme.primaryColor,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  child: ElevatedButton(
                    onPressed: () {
                      // 点击时也复制邮箱
                      Clipboard.setData(ClipboardData(text: applyVal));
                      Get.snackbar(
                        '成功',
                        '邮箱已复制到剪贴板',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.primaryColor,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy, size: 18, color: Colors.white),
                      ],
                    ),
                  ),
                );
              }

              // 其他情况使用原来的按钮
              return ElevatedButton(
                onPressed: () {
                  // 检查用户是否登录
                  if (!userController.isLoggedIn) {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('提示'),
                        content: const Text('请先登录后再查看HR联系方式'),
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
                              backgroundColor: AppTheme.primaryColor,
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

                  // 已登录，根据isBuyed状态处理
                  if (isBuyed) {
                    // 已购买，如果是链接则打开外部浏览器
                    if (applyVal.toLowerCase().contains('http')) {
                      // 使用url_launcher打开链接
                      launchUrl(
                        Uri.parse(applyVal),
                        mode: LaunchMode.externalApplication,
                      );

                      // 同时打印链接用于调试
                      print('打开链接: $applyVal');
                    }
                    // 如果是邮箱或其他信息，已经在按钮文字中显示了
                  } else {
                    // 未购买，先显示积分扣除确认对话框
                    if (jobDetail?.jobKey != null) {
                      _showScoreDeductionDialog(jobDetail!);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 显示积分扣除确认对话框
  void _showScoreDeductionDialog(JobDetailData job) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认扣除积分'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('查看HR联系方式需要扣除 ${job.apply?.score ?? 5} 积分'),
            const SizedBox(height: 8),
            const Text('您确定要继续吗？', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
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
              // 用户点击确认，关闭对话框后执行扣分逻辑
              Get.back();
              
              // 执行原有的扣分逻辑
              _restClient.applyJobCharge(job.jobKey!).then((response) {
                if (response.code == 0) {
                  // 扣分成功，重新加载页面显示联系方式
                  controller.fetchJobDetail(job.jobKey!);
                  Get.dialog(
                    AlertDialog(
                      title: const Text('成功'),
                      content: const Text('已成功获取HR联系方式'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                    barrierDismissible: true,
                  );
                } else {
                  // 扣分失败，提示用户
                  Get.snackbar(
                    '提示',
                    response.message ?? '获取HR联系方式失败，请稍后再试',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                  );
                }
              }).catchError((error) {
                Get.snackbar(
                  '错误',
                  '网络错误，请稍后再试',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认'),
          ),
        ],
      ),
      barrierDismissible: false, // 防止用户点击外部关闭对话框
    );
  }

  // 切换岗位收藏状态
  void _toggleJobFavorite() {
    final jobDetail = controller.currentJobDetail.value;
    if (jobDetail?.jobKey == null) return;

    // 检查用户是否已登录
    final UserController userController = Get.find<UserController>();
    if (!userController.isLoggedIn) {
      Get.dialog(
        AlertDialog(
          title: const Text('提示'),
          content: const Text('请先登录后再收藏岗位'),
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
                backgroundColor: AppTheme.primaryColor,
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

    // 调用收藏接口
    _restClient.collectJob(jobDetail!.jobKey!).then((response) {
      if (response.code == 0 && response.data != null) {
        // 根据返回的value值确定收藏状态
        final bool isCollected = response.data?.value == 1;
        
        // 更新当前jobDetail的收藏状态
        final updatedJobDetail = JobDetailData(
          id: jobDetail.id,
          jobTitle: jobDetail.jobTitle,
          jobPosition: jobDetail.jobPosition,
          jobType: jobDetail.jobType,
          userId: jobDetail.userId,
          createTime: jobDetail.createTime,
          status: jobDetail.status,
          lang: jobDetail.lang,
          jobStatus: jobDetail.jobStatus,
          officeMode: jobDetail.officeMode,
          jobDesc: jobDetail.jobDesc,
          jobWelfare: jobDetail.jobWelfare,
          jobEdu: jobDetail.jobEdu,
          minSalary: jobDetail.minSalary,
          maxSalary: jobDetail.maxSalary,
          jobLang: jobDetail.jobLang,
          tags: jobDetail.tags,
          isHot: jobDetail.isHot,
          jobSalaryCurrency: jobDetail.jobSalaryCurrency,
          jobSalaryUnit: jobDetail.jobSalaryUnit,
          jobSalaryType: jobDetail.jobSalaryType,
          jobCompany: jobDetail.jobCompany,
          jobKey: jobDetail.jobKey,
          isTop: jobDetail.isTop,
          jobLocation: jobDetail.jobLocation,
          lastView: jobDetail.lastView,
          lastViewUser: jobDetail.lastViewUser,
          replyNums: jobDetail.replyNums,
          replyUser: jobDetail.replyUser,
          ding: jobDetail.ding,
          cai: jobDetail.cai,
          replyTime: jobDetail.replyTime,
          apply: jobDetail.apply,
          jobIsCollect: isCollected ? 1 : 0,
          jobIsLike: jobDetail.jobIsLike,
        );
        
        controller.currentJobDetail.value = updatedJobDetail;
        
        // 同步更新首页HomeController中的job收藏状态
        try {
          final homeController = Get.find<HomeController>();
          final homeJobIndex = homeController.jobs.indexWhere((job) => job.jobKey == jobDetail.jobKey);
          if (homeJobIndex != -1) {
            final homeJob = homeController.jobs[homeJobIndex];
            homeController.jobs[homeJobIndex] = JobPost(
              id: homeJob.id,
              title: homeJob.title,
              company: homeJob.company,
              location: homeJob.location,
              salary: homeJob.salary,
              timeAgo: homeJob.timeAgo,
              createdAt: homeJob.createdAt,
              tags: homeJob.tags,
              jobKey: homeJob.jobKey,
              isFavorite: isCollected,
            );
          }
        } catch (e) {
          print('更新首页收藏状态失败: $e');
        }
        
        // 同步更新JobController中的job收藏状态
        try {
          final jobController = Get.find<JobController>();
          final jobIndex = jobController.jobs.indexWhere((job) => job.jobKey == jobDetail.jobKey);
          if (jobIndex != -1) {
            final job = jobController.jobs[jobIndex];
            final updatedJob = JobData(
              slug: job.slug,
              id: job.id,
              jobKey: job.jobKey,
              jobTitle: job.jobTitle,
              jobPosition: job.jobPosition,
              createdAt: job.createdAt,
              tags: job.tags,
              jobCompany: job.jobCompany,
              jobSalaryType: job.jobSalaryType,
              jobSalaryUnit: job.jobSalaryUnit,
              jobSalaryCurrency: job.jobSalaryCurrency,
              minSalary: job.minSalary,
              maxSalary: job.maxSalary,
              jobIsCollect: isCollected ? 1 : 0,
            );
            jobController.jobs[jobIndex] = updatedJob;
            jobController.jobs.refresh();
          }
        } catch (e) {
          print('更新工作列表收藏状态失败: $e');
        }
        
        // 显示自动消失的中心弹窗
        Get.dialog(
          AlertDialog(
            title: const Text('提示'),
            content: Text(isCollected ? '收藏成功' : '取消收藏成功'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          barrierDismissible: false,
        );

        // 1.2秒后自动关闭
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      } else {
        // 显示失败提示
        Get.snackbar(
          '提示',
          response.message ?? '操作失败，请稍后再试',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      }
    }).catchError((error) {
      // 显示错误提示
      Get.snackbar(
        '错误',
        '网络错误，请稍后再试',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    });
  }
}

// 扩展JobController，添加导航到岗位详情页的方法
extension JobDetailNavigation on JobController {
  void navigateToJobDetail(JobData job) async {
    // 清空当前岗位详情，以显示加载状态
    currentJobDetail.value = null;

    // 导航到岗位详情页面
    Get.to(
      () => JobDetailView(
        title: job.jobTitle ?? "",
        company: job.jobCompany ?? "",
        salary: () {
          // 获取货币符号
          String currencySymbol = '¥';
          if (job.jobSalaryCurrency?.toLowerCase() == 'usd') {
            currencySymbol = '\$';
          } else if (job.jobSalaryCurrency?.toLowerCase() == 'rmb') {
            currencySymbol = '¥';
          }

          // 添加千位分隔符
          final minSalary = job.minSalary ?? 0;
          final maxSalary = job.maxSalary ?? 0;
          final formattedMinSalary = minSalary.toString().replaceAllMapped(
            RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[0]},',
          );
          final formattedMaxSalary = maxSalary.toString().replaceAllMapped(
            RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[0]},',
          );

          // 获取单位
          String unitDisplay = job.jobSalaryUnit ?? 'K';
          if (unitDisplay.toLowerCase() == 'month') {
            unitDisplay = LanguageManagement.language() == 1 ? '/月' : '/month';
          }

          return '$currencySymbol$formattedMinSalary - $formattedMaxSalary$unitDisplay';
        }(),
        publishTime: job.createdAt ?? "",
        tags: job.tags?.split(',') ?? [],
        description: '', // 初始为空，将通过API获取
      ),
    );

    try {
      // 直接使用传入的jobKey调用API获取详细信息
      await fetchJobDetail(job.jobKey ?? "");

      // 如果获取失败，显示错误提示
      if (currentJobDetail.value == null) {
        Get.snackbar(
          '提示',
          '获取岗位详情失败，请稍后重试',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey[800],
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        '提示',
        '获取岗位详情失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
