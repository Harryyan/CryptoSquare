import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'dart:convert';

class PostCreateView extends StatefulWidget {
  final bool isEditMode;
  final String? articleId;
  final String initialTitle;
  final String initialContent;
  final int initialCategoryId;
  final String initialTags;

  const PostCreateView({
    Key? key,
    this.isEditMode = false,
    this.articleId,
    this.initialTitle = '',
    this.initialContent = '',
    this.initialCategoryId = 0,
    this.initialTags = '',
  }) : super(key: key);

  @override
  _PostCreateViewState createState() => _PostCreateViewState();
}

class _PostCreateViewState extends State<PostCreateView> {
  // 控制器
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final QuillController _contentController = QuillController.basic();

  // 将QuillController的内容转换为HTML
  String convertDeltaToHtml() {
    // 获取Delta格式的JSON数据并进行类型转换
    final List<dynamic> rawDeltaJson =
        _contentController.document.toDelta().toJson();
    final List<Map<String, dynamic>> deltaJson =
        rawDeltaJson.map((item) => item as Map<String, dynamic>).toList();

    // 创建转换器
    final converter = QuillDeltaToHtmlConverter(
      deltaJson,
      ConverterOptions.forEmail(), // 使用邮件格式，也可以使用默认选项：ConverterOptions()
    );

    // 转换为HTML
    final html = converter.convert();
    return html;
  }

  // 分类数据
  final RxList<BBSCategoryData> categories = <BBSCategoryData>[].obs;
  final RxBool isLoading = true.obs;
  BBSCategoryData? selectedCategory;

  // RestClient实例
  late RestClient _restClient;

  @override
  void initState() {
    super.initState();
    _restClient = RestClient();
    _loadCategories();

    // 如果是编辑模式，初始化编辑器内容
    if (widget.isEditMode) {
      _titleController.text = widget.initialTitle;
      _tagsController.text = widget.initialTags;

      // 将HTML内容转换为Delta格式并设置到编辑器中
      if (widget.initialContent.isNotEmpty) {
        try {
          print('原始HTML内容: ${widget.initialContent}');

          // 使用flutter_quill_delta_from_html库将HTML转换为Delta格式
          // 预处理HTML内容，确保换行和段落标签被正确处理
          String processedHtml = widget.initialContent;

          // 如果HTML内容为空或只包含基本标签，添加一个默认段落
          if (processedHtml.isEmpty ||
              processedHtml == '<p><br></p>' ||
              processedHtml == '<p></p>') {
            processedHtml = '<p>内容为空</p>';
          }

          // 确保所有段落标签正确闭合
          // 查找所有未闭合的<p>标签
          final RegExp pTagRegex = RegExp(
            r'<p[^>]*>(?!.*?</p>).*?$',
            multiLine: true,
          );
          processedHtml = processedHtml.replaceAllMapped(pTagRegex, (match) {
            return '${match.group(0)}</p>';
          });

          // 确保换行标签格式一致
          processedHtml = processedHtml.replaceAll('<br>', '<br/>');

          // 处理可能的嵌套段落问题
          processedHtml = processedHtml.replaceAll('</p><p>', '</p>\n<p>');

          dev.log('预处理后的HTML内容: $processedHtml');
          final delta = HtmlToDelta().convert(processedHtml);
          dev.log('转换后的Delta类型: ${delta.runtimeType}');
          dev.log('转换后的Delta内容: $delta');

          // 根据delta的类型选择合适的方法创建Document
          if (delta is Delta) {
            // 将Delta对象转换为Document对象
            dev.log('使用Document.fromDelta方法');
            _contentController.document = Document.fromDelta(delta);
          } else if (delta is List) {
            // 如果是List类型，使用fromJson方法
            dev.log('使用Document.fromJson方法');
            _contentController.document = Document.fromJson(delta as List);
          } else {
            dev.log('转换HTML到Delta失败: delta类型为 ${delta.runtimeType}，无法处理');

            // 尝试将delta转换为JSON，然后使用Document.fromJson
            try {
              dev.log('尝试将delta转换为JSON');
              final jsonData = jsonEncode(delta);
              final jsonList = jsonDecode(jsonData) as List;
              _contentController.document = Document.fromJson(jsonList);
            } catch (e) {
              dev.log('转换delta到JSON失败: $e');

              // 如果上述方法都失败，尝试使用基本的文本插入
              try {
                dev.log('尝试使用基本文本插入并保留格式');
                // 创建一个新的Document对象
                final document = Document();

                // 处理HTML内容，尝试保留基本格式
                String html = widget.initialContent;

                // 处理段落和换行
                html = html.replaceAll(RegExp(r'<p[^>]*>'), '');
                html = html.replaceAll('</p>', '\n\n');
                html = html.replaceAll('<br>', '\n');
                html = html.replaceAll('<br/>', '\n');
                html = html.replaceAll('<br />', '\n');

                // 提取加粗文本并应用样式
                final boldRegex = RegExp(
                  r'<strong>(.*?)</strong>|<b>(.*?)</b>',
                );
                String processedText = html;

                // 处理加粗标签
                processedText = processedText.replaceAllMapped(boldRegex, (
                  match,
                ) {
                  final boldText = match.group(1) ?? match.group(2) ?? '';
                  return boldText; // 先移除标签，稍后会应用样式
                });

                // 处理斜体标签
                final italicRegex = RegExp(r'<em>(.*?)</em>|<i>(.*?)</i>');
                processedText = processedText.replaceAllMapped(italicRegex, (
                  match,
                ) {
                  final italicText = match.group(1) ?? match.group(2) ?? '';
                  return italicText; // 先移除标签，稍后会应用样式
                });

                // 移除其他HTML标签
                processedText = processedText.replaceAll(
                  RegExp(r'<[^>]*>'),
                  '',
                );

                // 处理连续的换行符
                processedText = processedText.replaceAll(
                  RegExp(r'\n{3,}'),
                  '\n\n',
                );

                // 移除首尾空白
                processedText = processedText.trim();

                // 插入处理后的文本
                document.insert(0, processedText);

                // 尝试应用基本样式（这里只是一个简化的示例）
                // 实际应用中，你需要更精确地定位样式位置
                try {
                  // 如果原始HTML包含加粗标签，为整个文档添加加粗样式
                  if (html.contains('<strong>') || html.contains('<b>')) {
                    document.format(0, processedText.length, Attribute.bold);
                  }

                  // 如果原始HTML包含斜体标签，为整个文档添加斜体样式
                  if (html.contains('<em>') || html.contains('<i>')) {
                    document.format(0, processedText.length, Attribute.italic);
                  }
                } catch (e) {
                  dev.log('应用样式失败: $e');
                }
                _contentController.document = document;
              } catch (e) {
                dev.log('使用基本文本插入失败: $e');
              }
            }
          }
        } catch (e) {
          dev.log('转换HTML到Delta失败: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 加载分类数据
  Future<void> _loadCategories() async {
    try {
      isLoading.value = true;
      final response = await _restClient.category(1); // 1表示中文，0表示英文
      if (response.code == 0 && response.data != null) {
        // 直接使用response.data，它已经是List<BBSCategoryData>类型
        categories.value = response.data!;
        if (categories.isNotEmpty) {
          selectedCategory = categories.first;
        }
      }
    } catch (e) {
      dev.log('加载分类失败: $e');
      Get.snackbar('错误', '加载分类失败，请稍后重试');
    } finally {
      isLoading.value = false;
    }
  }

  // 发布或更新帖子
  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty) {
      Get.snackbar('提示', '请输入帖子标题');
      return;
    }
    if (selectedCategory == null) {
      Get.snackbar('提示', '请选择帖子分类');
      return;
    }
    // 将Delta格式转换为HTML
    final String content = convertDeltaToHtml();
    if (content.isEmpty || content == '[]' || content == '<p><br></p>') {
      Get.snackbar('提示', '请输入帖子内容');
      return;
    }

    try {
      PostCreateResp response;

      if (widget.isEditMode && widget.articleId != null) {
        // 编辑模式，调用updatePost接口
        response = await _restClient.updatePost(
          widget.articleId!,
          _titleController.text,
          _tagsController.text,
          selectedCategory!.id!,
          0, // 0表示中文，1表示英文
          '', // origin
          '', // originLink
          content,
        );
      } else {
        // 创建模式，调用createPost接口
        response = await _restClient.createPost(
          _titleController.text,
          _tagsController.text,
          selectedCategory!.id!,
          0, // 0表示中文，1表示英文
          '', // origin
          '', // originLink
          content,
        );
      }

      if (response.code == 0) {
        Get.back(result: true);
        Get.snackbar('成功', widget.isEditMode ? '帖子更新成功' : '帖子发布成功');
      } else {
        Get.snackbar(
          '错误',
          response.message ?? (widget.isEditMode ? '更新失败，请稍后重试' : '发布失败，请稍后重试'),
        );
      }
    } catch (e) {
      print('${widget.isEditMode ? "更新" : "发布"}帖子失败: $e');
      Get.snackbar('错误', widget.isEditMode ? '更新失败，请稍后重试' : '发布失败，请稍后重试');
    }
  }

  // // 发布帖子
  // Future<void> _submitPost() async {
  //   if (_titleController.text.isEmpty) {
  //     Get.snackbar('提示', '请输入帖子标题');
  //     return;
  //   }

  //   if (selectedCategory == null) {
  //     Get.snackbar('提示', '请选择帖子分类');
  //     return;
  //   }

  //   // 将Delta格式转换为HTML
  //   final String content = convertDeltaToHtml();
  //   if (content.isEmpty || content == '<p><br></p>') {
  //     Get.snackbar('提示', '请输入帖子内容');
  //     return;
  //   }

  //   try {
  //     final response = await _restClient.createPost(
  //       _titleController.text,
  //       _tagsController.text,
  //       selectedCategory!.id!,
  //       0, // 0表示中文，1表示英文
  //       '', // origin
  //       '', // originLink
  //       content,
  //     );

  //     if (response.code == 0) {
  //       Get.back(result: true);
  //       Get.snackbar('成功', '帖子发布成功');
  //     } else {
  //       Get.snackbar('错误', response.message ?? '发布失败，请稍后重试');
  //     }
  //   } catch (e) {
  //     print('发布帖子失败: $e');
  //     Get.snackbar('错误', '发布失败，请稍后重试');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? '编辑帖子' : '发布帖子'),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: Text(
              widget.isEditMode ? '更新' : '发布',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 帖子分类选择
              const Text('选择分类', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BBSCategoryData>(
                    // value: selectedCategory,
                    hint: Text('请选择分类'),
                    isExpanded: true,
                    items:
                        categories.map((category) {
                          return DropdownMenuItem<BBSCategoryData>(
                            value: category,
                            child: Text(category.name ?? '未知分类'),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    value:
                        widget.isEditMode && widget.initialCategoryId > 0
                            ? categories.firstWhere(
                              (cat) => cat.id == widget.initialCategoryId,
                              orElse: () => categories.first,
                            )
                            : selectedCategory,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 帖子标题
              const Text('帖子标题', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '请输入标题',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              // 主题标签
              const Text('主题标签', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _tagsController,
                decoration: InputDecoration(
                  hintText: '请输入标签，多个标签用逗号分隔',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 帖子内容 - 富文本编辑器
              const Text('帖子内容', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 800,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    QuillSimpleToolbar(
                      controller: _contentController,
                      config: QuillSimpleToolbarConfig(),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: QuillEditor.basic(
                          controller: _contentController,
                          config: const QuillEditorConfig(
                            autoFocus: false,
                            enableInteractiveSelection: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
