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

  /// 退出登录
  void _logout() {
    // 显示确认对话框
    Get.dialog(
      AlertDialog(
        title: Text(I18nKeyword.tip.tr),
        content: Text(I18nKeyword.logoutConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(I18nKeyword.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              // 清除登录状态
              GStorage().setLoginStatus(false);

              // 更新UserController
              userController.logout();

              // 关闭对话框
              Get.back();

              // 返回上一页
              Get.back();
            },
            child: Text(I18nKeyword.confirm.tr),
          ),
        ],
      ),
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

        Get.snackbar(
          I18nKeyword.tip.tr,
          I18nKeyword.profileUpdated.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
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
      appBar: AppBar(
        title: Text(I18nKeyword.editProfile.tr),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
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
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            I18nKeyword.avatar.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Stack(
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
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _selectAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
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
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            I18nKeyword.nickname.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _nameController,
            maxLength: 11, // 限制昵称最大长度为11个字符
            decoration: InputDecoration(
              hintText: I18nKeyword.inputNickname.tr,
              counterText: '', // 隐藏字符计数器
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              suffixIcon: Icon(Icons.edit, color: AppTheme.primaryColor),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: _saveUserInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  I18nKeyword.save.tr,
                  style: const TextStyle(fontSize: 16),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: SizedBox(
          width: 200,
          height: 45,
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              I18nKeyword.logout.tr,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
