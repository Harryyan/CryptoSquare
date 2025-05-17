import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';
import 'dart:convert';

class PostCreateView extends StatefulWidget {
  const PostCreateView({Key? key}) : super(key: key);

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
      print('加载分类失败: $e');
      Get.snackbar('错误', '加载分类失败，请稍后重试');
    } finally {
      isLoading.value = false;
    }
  }

  // 发布帖子
  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty) {
      Get.snackbar('提示', '请输入帖子标题');
    }
    if (selectedCategory == null) {
      Get.snackbar('提示', '请选择帖子分类');
    }
    // 将Delta格式转换为HTML
    final String content = convertDeltaToHtml();
    if (content.isEmpty || content == '[]') {
      Get.snackbar('提示', '请输入帖子内容');
    }

    try {
      final response = await _restClient.createPost(
        _titleController.text,
        _tagsController.text,
        selectedCategory!.id!,
        0,
        '',
        '',
        content,
      );
      if (response.code == 0) {
        Get.back(result: true);
        Get.snackbar('成功', '帖子发布成功');
      } else {
        Get.snackbar('错误', response.message ?? '发布失败，请稍后重试');
      }
    } catch (e) {
      Get.snackbar('错误', '发布失败，请稍后重试');
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
        title: const Text('发布动态'),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text(
              '发布',
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
                    value: selectedCategory,
                    hint: const Text('请选择分类'),
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
