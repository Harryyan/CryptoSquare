import 'package:cryptosquare/util/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManagement {
  static bool isLogin = false;
  static bool isCN = true;

  static int language() {
    // 1 中文 0 英文
    return GStorage().getLanguageCN() ? 1 : 0;
  }

  static Future initialization() async {
    final Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    final SharedPreferences prefs = await prefs0;
    LanguageManagement.isCN = prefs.getBool('app_lang') ?? true;
  }

  static Future<bool> changeLang({required bool isCN}) async {
    final Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    late Future<bool> isCN0;

    final SharedPreferences prefs = await prefs0;
    isCN0 = prefs.setBool('app_lang', isCN).then((bool success) {
      return isCN;
    });
    LanguageManagement.isCN = isCN;

    return isCN0;
  }
}
