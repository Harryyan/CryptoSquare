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
    final credential = await SignInWithApple.getAppleIDCredential(
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: "com.bitpush.csapp",
        redirectUri: Uri.parse(
          "https://www.cryptosquare.org/mcn/api/thirdlogin/apple_login_flutter",
        ),
      ),
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

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

    final result = CSUserLoginResp.fromJson(response.data!);

    return result;
  }
}
