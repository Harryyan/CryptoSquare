import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cryptosquare/auth_service/auth_service.dart';
import 'package:cryptosquare/components/countdown_button.dart';
import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:cryptosquare/rest_service/user_client.dart';
import 'package:cryptosquare/util/event_bus.dart';
import 'package:cryptosquare/util/storage.dart';

import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:country_picker/country_picker.dart';
import 'package:getwidget/components/tabs/gf_segment_tabs.dart';
import 'package:cryptosquare/views/country_code_page.dart';

import '../widget/linked_label_checkbox.dart';
import '../widget/square_tile.dart';

class LoginDetailModel {
  String userNameHash = ''; // 用户名key 随机
  String passwordHash = ''; // 用户密码key 随机
  String codeHash = ''; // 验证码key 随机
  String once = ''; // 用户标识id 随机
  String captchaImg = ''; // 验证码图片 随机
  Uint8List? captchaImgBytes;
  String next = '/';

  String userNameValue = '';
  String passwordValue = '';
  String codeValue = '';

  bool twoFa = false;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey _formKey = GlobalKey<FormState>();

  var codeImg = '';
  late String? _userName;
  late String? _password;
  late String? _code;

  String? _emailErrorText;
  String? _phoneErrorText;

  late LoginDetailModel loginKey = LoginDetailModel();
  final FocusNode userNameTextFieldNode = FocusNode();
  final FocusNode passwordTextFieldNode = FocusNode();
  final FocusNode captchaTextFieldNode = FocusNode();
  bool passwordVisible = true; // 默认隐藏密码
  bool checkboxValue = false;

  // late SessionStatus _session;
  late Uri _uri;

  late final TabController controller;
  @override
  void initState() {
    super.initState();

    controller = TabController(length: 2, vsync: this);
    getSignKey();

    // 使用country_picker包初始化国家代码
    selectedCountryCode = "+86 CN";

    controller.addListener(() {
      (_formKey.currentState as FormState).reset();

      _userNameController.text = '';
      _passwordController.text = '';

      cdButtonKey.currentState?.reset();

      setState(() {});
    });
  }

  bool isValidEmail(String email) {
    String pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regex = RegExp(pattern);
    bool result = regex.hasMatch(email);
    return result;
  }

  String selectedCountryCode = '';
  String keepOnlyNumbers(String input) {
    RegExp regex = RegExp(r'\D'); // 匹配非数字字符
    return input.replaceAll(regex, ''); // 使用空字符串替换非数字字符
  }

  Future<LoginDetailModel> getSignKey() async {
    return LoginDetailModel();
  }

  void onCountryCodeSelected(String? countryCode) {
    setState(() {
      selectedCountryCode = countryCode ?? "";
    });
  }

  // 使用country_picker包，不再需要dataList

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(result: {'loginStatus': 'cancel'}),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Form(
              key: _formKey, //设置globalKey，用于后面获取FormState
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Text(
                    I18nKeyword.signInUpTitle.tr,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    I18nKeyword.signInUpType.tr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  GFSegmentTabs(
                    border: Border.all(color: Colors.transparent),
                    length: 2,
                    indicatorWeight: 0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Text(I18nKeyword.email.tr),
                      Text(I18nKeyword.phone.tr),
                    ],
                    tabController: controller,
                  ),

                  const SizedBox(height: 50),
                  Container(
                    // height: 70,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: TextFormField(
                      inputFormatters:
                          controller.index == 1
                              ? [FilteringTextInputFormatter.digitsOnly]
                              : [],
                      controller: _userNameController,
                      focusNode: userNameTextFieldNode,
                      decoration: InputDecoration(
                        labelText:
                            controller.index == 0
                                ? I18nKeyword.email.tr
                                : I18nKeyword.phoneNumber.tr,
                        errorText:
                            controller.index == 0
                                ? _emailErrorText
                                : _phoneErrorText,
                        prefixIcon:
                            controller.index == 0
                                ? null
                                : GestureDetector(
                                  onTap: () async {
                                    final result = await Get.to(
                                      () => const CountryCodePage(),
                                    );
                                    if (result != null && result is Country) {
                                      onCountryCodeSelected(
                                        "+${result.phoneCode} ${result.countryCode}",
                                      );
                                    }
                                  },

                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(selectedCountryCode),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      // 校验用户名
                      validator: (v) {
                        return v!.trim().isNotEmpty
                            ? null
                            : controller.index == 0
                            ? I18nKeyword.emailEmpty.tr
                            : I18nKeyword.phoneEmpty.tr;
                      },
                      onSaved: (val) {
                        _userName = val;
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: Stack(
                      children: [
                        TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.text,
                          focusNode: captchaTextFieldNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            labelText: I18nKeyword.verifyCode.tr,
                            suffixIcon: CountdownButton(
                              key: cdButtonKey,
                              onPressed: () async {
                                bool isEmail = isValidEmail(
                                  _userNameController.text,
                                );

                                if (_userNameController.text.isEmpty) {
                                  setState(() {
                                    if (controller.index == 0) {
                                      _emailErrorText =
                                          I18nKeyword.emailEmpty.tr;
                                    } else {
                                      _phoneErrorText =
                                          I18nKeyword.phoneEmpty.tr;
                                    }
                                  });

                                  return;
                                } else if (controller.index == 0 && !isEmail) {
                                  setState(() {
                                    if (controller.index == 0) {
                                      _emailErrorText =
                                          I18nKeyword.emailInvalid.tr;
                                    }
                                  });

                                  return;
                                }

                                if (controller.index == 0 && isEmail) {
                                  setState(() {
                                    _emailErrorText = null;
                                  });

                                  eventBus.emit('isUserNameValid', 'true');
                                } else if (controller.index == 1 &&
                                    _userNameController.text.isNotEmpty) {
                                  setState(() {
                                    _phoneErrorText = null;
                                  });

                                  eventBus.emit('isUserNameValid', 'true');
                                }

                                try {
                                  var result =
                                      isEmail
                                          ? await UserRestClient().emailVerify(
                                            _userNameController.text,
                                          )
                                          : await UserRestClient().phoneVerify(
                                            keepOnlyNumbers(
                                              selectedCountryCode +
                                                  _userNameController.text,
                                            ),
                                            GStorage().getLanguageCN() ? 1 : 0,
                                          );

                                  // 确保在UI线程上显示Toast
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result.code == 0
                                                ? I18nKeyword.codeSent.tr
                                                : "${result.message}",
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  });
                                } catch (e) {
                                  // 处理异常情况
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("发送验证码失败，请稍后重试"),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  });
                                  print("验证码发送错误: $e");
                                }
                              },
                            ),
                          ),
                          validator: (v) {
                            return v!.trim().isNotEmpty
                                ? null
                                : I18nKeyword.codeShouldNotEmpty.tr;
                          },
                          onSaved: (val) {
                            _code = val;
                          },
                        ),
                        if (loginKey.captchaImg != '') ...[
                          Positioned(
                            right: 6,
                            top: 6,
                            height: 52,
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    getSignKey();
                                  });
                                },
                                child: Image.memory(
                                  loginKey.captchaImgBytes!,
                                  height: 52.0,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: LinkedLabelCheckbox(
                      label:
                          GStorage().getLanguageCN()
                              ? '我同意Cryposquare的服务条款'
                              : 'I agree with the Cryposquare Terms and Conditions',
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      value: checkboxValue,
                      onChanged: (bool newValue) {
                        setState(() {
                          checkboxValue = newValue;
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 94,
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(
                        I18nKeyword.signInUpTitle.tr,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onPressed: () async {
                        if ((_formKey.currentState as FormState).validate()) {
                          GStorage().setToken('');
                          //验证通过提交数据
                          (_formKey.currentState as FormState).save();
                          loginKey.userNameValue = _userNameController.text;
                          // loginKey.passwordValue = _password!;
                          loginKey.codeValue = _code!;
                          // 键盘收起
                          captchaTextFieldNode.unfocus();
                          bool isEmail = isValidEmail(_userNameController.text);

                          if (!checkboxValue) {
                            SmartDialog.show(
                              builder: (context) {
                                return Container(
                                  height: GStorage().getLanguageCN() ? 80 : 120,
                                  width: 200,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      240,
                                      239,
                                      239,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    GStorage().getLanguageCN()
                                        ? '您需要同意Cryposquare的服务条款才能登录账户'
                                        : 'You need to agree to Cryposquare\'s terms of service to log in to your account.',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 49, 49, 49),
                                    ),
                                  ),
                                );
                              },
                            );

                            return;
                          }

                          var result =
                              isEmail
                                  ? await UserRestClient().emailLogin(
                                    _userNameController.text,
                                    loginKey.codeValue,
                                    null,
                                  )
                                  : await UserRestClient().phoneLogin(
                                    keepOnlyNumbers(
                                      selectedCountryCode +
                                          _userNameController.text,
                                    ),
                                    loginKey.codeValue,
                                    null,
                                  );

                          if (result.code == 0) {
                            // 登录成功
                            GStorage().setLoginStatus(true);
                            GStorage().setToken(result.data?.secret ?? "");
                            log(result.data?.secret ?? "");

                            var profile = await UserRestClient().userProfile();
                            GStorage().setUserInfo({
                              "avatar": result.data?.avatar,
                              "userName": result.data?.nickname,
                              "userID": result.data?.iD,
                              "score": profile.data?.score,
                            });
                            eventBus.emit('loginSuccessful', null);
                            Get.back(result: {'loginStatus': 'success'});
                          } else {
                            // 登录失败
                            setState(() {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      GStorage().getLanguageCN()
                                          ? '登录失败'
                                          : 'Login Failed',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                              // _passwordController.value =
                              //     const TextEditingValue(text: '');
                              _codeController.value = const TextEditingValue(
                                text: '',
                              );
                            });
                            Timer(const Duration(milliseconds: 500), () {
                              getSignKey();
                            });
                          }
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            I18nKeyword.otherLogin.tr,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  // google + apple sign in buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // google button
                      SquareTile(
                        imagePath: 'assets/images/google.png',
                        onTap: () async {
                          if (!checkboxValue) {
                            SmartDialog.show(
                              builder: (context) {
                                return Container(
                                  height: GStorage().getLanguageCN() ? 80 : 120,
                                  width: 200,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      240,
                                      239,
                                      239,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    GStorage().getLanguageCN()
                                        ? '您需要同意Cryposquare的服务条款才能登录账户'
                                        : 'You need to agree to Cryposquare\'s terms of service to log in to your account.',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 49, 49, 49),
                                    ),
                                  ),
                                );
                              },
                            );

                            return;
                          }

                          var result = await AuthService().signInWithGoogle();

                          if (result.code == 0) {
                            // 登录成功
                            var profile = await UserRestClient().userProfile();
                            GStorage().setLoginStatus(true);
                            GStorage().setToken(result.data?.secret ?? "");
                            GStorage().setUserInfo({
                              "avatar": result.data?.avatar,
                              "userName": result.data?.nickname,
                              "userID": result.data?.iD,
                              "score": profile.data?.score,
                            });
                            Get.back(result: {'loginStatus': 'success'});
                          } else {
                            // 登录失败
                            setState(() {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      GStorage().getLanguageCN()
                                          ? '登录失败'
                                          : 'Login Failed',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                              // _passwordController.value =
                              //     const TextEditingValue(text: '');
                              _codeController.value = const TextEditingValue(
                                text: '',
                              );
                            });
                            Timer(const Duration(milliseconds: 500), () {
                              getSignKey();
                            });
                          }
                        },
                      ),

                      Visibility(
                        visible: Platform.isIOS,
                        child: const SizedBox(width: 25),
                      ),

                      Visibility(
                        visible: Platform.isIOS,
                        child: SquareTile(
                          imagePath: 'assets/images/apple.png',
                          onTap: () async {
                            if (!checkboxValue) {
                              SmartDialog.show(
                                builder: (context) {
                                  return Container(
                                    height:
                                        GStorage().getLanguageCN() ? 80 : 120,
                                    width: 200,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 240, 239, 239),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      GStorage().getLanguageCN()
                                          ? '您需要同意Cryposquare的服务条款才能登录账户'
                                          : 'You need to agree to Cryposquare\'s terms of service to log in to your account.',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 49, 49, 49),
                                      ),
                                    ),
                                  );
                                },
                              );

                              return;
                            }

                            var result = await AuthService().siginInWithApple();
                            if (result.code == 0) {
                              // 登录成功
                              var profile =
                                  await UserRestClient().userProfile();
                              GStorage().setLoginStatus(true);
                              GStorage().setToken(result.data?.secret ?? "");
                              GStorage().setUserInfo({
                                "avatar": result.data?.avatar,
                                "userName": result.data?.userLogin,
                                "userID": result.data?.iD,
                                "score": profile.data?.score,
                              });
                              Get.back(result: {'loginStatus': 'success'});
                            } else {
                              // 登录失败
                              setState(() {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        GStorage().getLanguageCN()
                                            ? '登录失败'
                                            : 'Login Failed',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                                // _passwordController.value =
                                //     const TextEditingValue(text: '');
                                _codeController.value = const TextEditingValue(
                                  text: '',
                                );
                              });
                              Timer(const Duration(milliseconds: 500), () {
                                getSignKey();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
