import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:cryptosquare/rest_service/user_client.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final UserController userController = Get.find<UserController>();

  // 用户信息
  final RxString userName = ''.obs;
  final RxString userAvatar = ''.obs;
  // 本地头像文件路径
  final RxString localAvatarPath = ''.obs;

  // 文本编辑控制器
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _nameController = TextEditingController(text: userName.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 从GStorage加载用户信息
  void _loadUserInfo() {
    // 获取用户信息
    Map userInfo = GStorage().getUserInfo();

    // 更新用户信息
    userName.value = userInfo['userName'] ?? '';
    // 只加载http(s)开头的avatar URL到userAvatar
    String avatarValue = userInfo['avatar'] ?? '';
    if (avatarValue.startsWith('http')) {
      userAvatar.value = avatarValue;
    }
  }

  /// 提交用户信息
  void submit() async {
    try {
      // 获取当前用户信息
      Map userInfo = GStorage().getUserInfo();

      // 准备参数
      File? imageFile;
      String imageName = "profile";

      // 使用localAvatarPath而不是userAvatar来获取本地文件
      if (localAvatarPath.value.isNotEmpty) {
        imageFile = File(localAvatarPath.value);
        imageName = basename(localAvatarPath.value);
      }

      // 获取当前语言设置（默认为0）
      int currentLang = 1;

      SmartDialog.showLoading(
        msg: GStorage().getLanguageCN() ? "更新中..." : "Updating...",
      );

      // 调用上传头像接口
      final userClient = UserRestClient();
      final result = await userClient.uploadAvatar(
        imageFile,
        imageName,
        _nameController.text,
        currentLang,
      );

      // 只有当上传成功时才更新头像URL
      if (result.code == 0) {
        // 更新用户信息
        userInfo['userName'] = _nameController.text;

        // 从服务器返回的数据中获取真正的avatar URL
        if (result.data?.avatar != null && result.data!.avatar!.isNotEmpty) {
          userAvatar.value = result.data!.avatar!; // 更新到Rx变量
          userInfo['avatar'] = result.data!.avatar;
        }

        // // 清空本地文件路径
        // localAvatarPath.value = '';

        // 保存到存储
        GStorage().setUserInfo(userInfo);

        // 更新UserController
        userController.login(
          User(
            id: userInfo['userID'] ?? 0,
            name: _nameController.text,
            avatarUrl: userInfo['avatar'] ?? '',
            isLoggedIn: true,
          ),
        );
      }

      SmartDialog.dismiss();

      // 显示保存成功提示
      Get.snackbar(
        I18nKeyword.tip.tr,
        I18nKeyword.profileUpdated.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // 显示错误提示
      Get.snackbar(
        I18nKeyword.networkError.tr,
        I18nKeyword.avatarUploadInDev.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 选择头像
  void _selectAvatar() async {
    // 请求相册权限
    final ImagePicker picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // 存储本地文件路径，而不是直接更新userAvatar
        localAvatarPath.value = pickedFile.path;
        setState(() {}); // 触发UI更新
      }
    } catch (e) {
      Get.snackbar(
        I18nKeyword.networkError.tr,
        I18nKeyword.avatarUploadInDev.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(I18nKeyword.editProfile.tr),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 20),
            _buildNameSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 头像部分
  Widget _buildAvatarSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      margin: const EdgeInsets.only(top: 0),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: _selectAvatar,
                child: Obx(() {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child:
                          localAvatarPath.value.isNotEmpty
                              // 如果有本地选择的图片，优先显示本地图片
                              ? Image.file(
                                File(localAvatarPath.value),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                              )
                              // 否则检查是否有网络头像
                              : userAvatar.value.isNotEmpty
                              ? Image.network(
                                userAvatar.value,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                              )
                              // 如果都没有，显示默认图标
                              : const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                    ),
                  );
                }),
              ),
              Positioned(
                right: 5,
                bottom: 5,
                child: GestureDetector(
                  onTap: _selectAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white, // 设置背景颜色为绿色，与头像背景颜色一致
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 昵称部分
  Widget _buildNameSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              "昵称",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            maxLength: 11, // 限制昵称最大长度为11个字符
            decoration: InputDecoration(
              hintText: I18nKeyword.inputNickname.tr,
              counterStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              filled: false,
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  I18nKeyword.submit.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<File> _fileFromImageUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, 'avatar.jpg'));
    file.writeAsBytesSync(response.bodyBytes);

    return file;
  }
}
