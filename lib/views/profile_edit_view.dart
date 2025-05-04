import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/controllers/user_controller.dart';
import 'package:cryptosquare/theme/app_theme.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/models/app_models.dart';
import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

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
    userAvatar.value = userInfo['avatar'] ?? '';
  }

  /// 保存用户信息
  void _saveUserInfo() {
    // 获取当前用户信息
    Map userInfo = GStorage().getUserInfo();

    // 更新用户名
    userInfo['userName'] = _nameController.text;

    // 保存到存储
    GStorage().setUserInfo(userInfo);

    // 更新UserController
    userController.login(
      User(
        id: userInfo['userID'] ?? 0,
        name: _nameController.text,
        avatarUrl: userAvatar.value,
        isLoggedIn: true,
      ),
    );

    // 显示保存成功提示
    Get.snackbar(
      I18nKeyword.tip.tr,
      I18nKeyword.profileUpdated.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 选择头像
  void _selectAvatar() async {
    // 请求相册权限
    final ImagePicker picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // 这里应该上传图片到服务器，获取URL
        // 暂时使用本地文件路径作为演示
        userAvatar.value = pickedFile.path;

        // 获取当前用户信息并更新头像
        // Map userInfo = GStorage().getUserInfo();
        // userInfo['avatar'] = pickedFile.path;
        // GStorage().setUserInfo(userInfo);

        // Get.snackbar(
        //   I18nKeyword.tip.tr,
        //   I18nKeyword.profileUpdated.tr,
        //   snackPosition: SnackPosition.BOTTOM,
        // );
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
            _buildLogoutButton(),
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
                          userAvatar.value.isNotEmpty
                              ? userAvatar.value.startsWith('http')
                                  ? Image.network(
                                    userAvatar.value,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                  )
                                  : Image.file(
                                    File(userAvatar.value),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                  )
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
                onPressed: _saveUserInfo,
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

  /// 退出登录按钮
  Widget _buildLogoutButton() {
    // 移除退出登录按钮，因为截图中没有显示
    return const SizedBox.shrink();
  }
}
