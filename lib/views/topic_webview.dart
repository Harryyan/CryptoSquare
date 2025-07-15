import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TopicWebView extends StatefulWidget {
  final String title;
  final String path;

  const TopicWebView({Key? key, required this.title, required this.path})
    : super(key: key);

  @override
  State<TopicWebView> createState() => _TopicWebViewState();
}

class _TopicWebViewState extends State<TopicWebView> {
  WebViewController? _webViewController;
  final RxInt webViewProgress = 0.obs;
  final RxBool isNetworkAvailable = true.obs;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    try {
      // 构建URL，根据path参数决定加载哪个页面
      String url;
      if (widget.path == '5313' || widget.path == '5981') {
        // 特定的topicId，加载特定的页面
        url = 'https://cryptosquare.org/topic/${widget.path}';
      } else {
        // 其他情况，构建标准的论坛文章URL
        url = 'https://cryptosquare.org/bbs/topic/${widget.path}';
      }

      _webViewController =
          WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (String url) {
                  webViewProgress.value = 0;
                },
                onProgress: (int progress) {
                  webViewProgress.value = progress;
                },
                onPageFinished: (String url) {
                  webViewProgress.value = 100;
                },
                onWebResourceError: (WebResourceError error) {
                  isNetworkAvailable.value = false;
                },
              ),
            )
            ..loadRequest(Uri.parse(url));
    } catch (e) {
      print('WebView初始化错误: $e');
      isNetworkAvailable.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (!isNetworkAvailable.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('网络连接错误，请检查网络设置', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return Stack(
          children: [
            if (_webViewController != null)
              WebViewWidget(controller: _webViewController!),
            if (webViewProgress.value < 100)
              Container(
                height: 3,
                child: LinearProgressIndicator(
                  value: webViewProgress.value / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6366F1),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
