import 'dart:io';

import 'package:cryptosquare/model/cs_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  Future<CSUserLoginResp> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser == null) {
      return CSUserLoginResp();
    }

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final dio = Dio();
    final response = await dio.post(
      'https://terminal-cn.bitpush.news/api/thirdlogin/google_login',
      data: {
        'accessToken': gAuth.accessToken,
        'idToken': gAuth.idToken,
        'platform': Platform.isAndroid ? 'Android' : 'iOS',
      },
    );

    final result = CSUserLoginResp.fromJson(response.data!);

    return result;
  }

  Future<CSUserLoginResp> siginInWithApple() async {
    try {
      print('开始Apple登录流程');
      
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('Apple凭证获取成功: ${credential.userIdentifier}');
      
      final dio = Dio();
      final response = await dio.post(
        'https://terminal-cn.bitpush.news/api/thirdlogin/apple_login_flutter',
        data: {
          'authorizationCode': credential.authorizationCode,
          'identityToken': credential.identityToken,
          'email': credential.email,
          'familyName': credential.familyName,
          'givenName': credential.givenName,
          'state': credential.state,
          'userIdentifier': credential.userIdentifier,
        },
      );

      print('服务器响应: ${response.statusCode}');
      final result = CSUserLoginResp.fromJson(response.data!);
      print('登录结果: ${result.code}');
      return result;
    } catch (e) {
      print('Apple 登录失败详细错误: $e');
      print('错误类型: ${e.runtimeType}');
      
      // 根据不同的错误类型提供更具体的错误信息
      String errorMessage = 'Apple 登录失败，请稍后重试';
      
      if (e.toString().contains('canceled')) {
        errorMessage = '用户取消了Apple登录';
      } else if (e.toString().contains('network')) {
        errorMessage = '网络连接失败，请检查网络设置';
      } else if (e.toString().contains('invalid')) {
        errorMessage = 'Apple登录配置错误';
      }
      
      // 返回带有错误代码的登录响应，表示登录失败
      return CSUserLoginResp(
        code: 1, // 非零值表示错误
        message: errorMessage,
      );
    }
  }
}
