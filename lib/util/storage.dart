import 'package:get_storage/get_storage.dart';

enum StoreKeys { language, loginStatus, token, userInfo }

class GStorage {
  static final GStorage _storage = GStorage._internal();
  final GetStorage _box = GetStorage();

  GStorage._internal();

  factory GStorage() => _storage;

  // 系统语言
  setLanguageCN(bool status) =>
      _box.write(StoreKeys.language.toString(), status);

  bool getLanguageCN() =>
      _box.read<bool>(StoreKeys.language.toString()) ?? true;

  // 登录状态
  setLoginStatus(bool status) =>
      _box.write(StoreKeys.loginStatus.toString(), status);

  bool getLoginStatus() =>
      _box.read<bool>(StoreKeys.loginStatus.toString()) ?? false;

  // setToken, getToken
  setToken(String token) => _box.write(StoreKeys.token.toString(), token);

  String getToken() => _box.read<String>(StoreKeys.token.toString()) ?? "";

  // 用户信息
  setUserInfo(Map info) => _box.write(StoreKeys.userInfo.toString(), info);

  Map getUserInfo() => _box.read<Map>(StoreKeys.userInfo.toString()) ?? {};
}
