import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cryptosquare/util/language_management.dart';

class WebViewTermAndCondition extends StatefulWidget {
  const WebViewTermAndCondition({super.key});

  @override
  State<WebViewTermAndCondition> createState() =>
      _WebViewTermAndConditionState();
}

class _WebViewTermAndConditionState extends State<WebViewTermAndCondition> {
  WebViewController? _webViewController;
  final RxInt webViewProgress = 0.obs; // WebView加载进度
  final RxBool isNetworkAvailable = true.obs; // 网络连接状态

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  // 初始化WebView控制器
  void _initWebViewController() {
    // 根据当前语言设置加载不同的URL
    final bool isChinese = LanguageManagement.isCN;
    final String termsUrl =
        isChinese
            ? 'https://cryptosquare.org/terms'
            : 'https://cryptosquare.org/terms?lng=en-US';

    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                // 页面开始加载时重置进度
                webViewProgress.value = 0;
              },
              onProgress: (int progress) {
                // 更新加载进度
                webViewProgress.value = progress;
              },
              onPageFinished: (String url) {
                // 页面加载完成
                webViewProgress.value = 100;
              },
              onWebResourceError: (WebResourceError error) {
                // 发生错误时标记网络不可用
                isNetworkAvailable.value = false;
              },
            ),
          )
          ..loadRequest(Uri.parse(termsUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageManagement.isCN ? '服务条款' : 'Terms and Conditions',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 加载进度条，仅在加载过程中显示
          Obx(
            () =>
                webViewProgress.value < 100 && webViewProgress.value > 0
                    ? LinearProgressIndicator(
                      value: webViewProgress.value / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2563EB),
                      ),
                      minHeight: 3,
                    )
                    : const SizedBox.shrink(),
          ),
          // WebView组件
          Expanded(
            child:
                _webViewController == null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: const Color(0xFF2563EB),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            LanguageManagement.isCN ? '正在加载...' : 'Loading...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : Stack(
                      children: [
                        WebViewWidget(controller: _webViewController!),
                        // 错误视图 - 当发生网络错误时显示
                        Obx(
                          () =>
                              !isNetworkAvailable.value
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.wifi_off_rounded,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          LanguageManagement.isCN
                                              ? '网络请求失败'
                                              : 'Network Request Failed',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          LanguageManagement.isCN
                                              ? '请检查您的网络连接，然后重试'
                                              : 'Please check your network connection and try again',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton(
                                          onPressed: () {
                                            // 重试加载
                                            isNetworkAvailable.value = true;
                                            _webViewController?.reload();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2563EB,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Text(
                                            LanguageManagement.isCN
                                                ? '重试'
                                                : 'Retry',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : const SizedBox.shrink(),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
