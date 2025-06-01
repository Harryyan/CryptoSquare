import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';

import 'package:cryptosquare/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';
import 'package:social_share_plus/social_share.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/getwidget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as IMG;
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialShareWidget extends StatelessWidget {
  const SocialShareWidget({
    super.key,
    this.title,
    this.desc,
    this.url,
    this.imgUrl,
  });
  final String? title;
  final String? desc;
  final String? url;
  final String? imgUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top handle indicator
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Share platforms grid
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              children: [
                // First row: WeChat, WeChat Moments, X
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareItem(
                      context,
                      "assets/images/wechat-share.png",
                      "微信",
                      () async => await _shareToWeChat(context),
                    ),
                    _buildShareItem(
                      context,
                      "assets/images/session-share.png", 
                      "朋友圈",
                      () async => await _shareToWeChatMoments(context),
                    ),
                    _buildShareItem(
                      context,
                      "assets/images/twitter-share.png",
                      "X",
                      () async => await _shareToTwitter(context),
                    ),
                  ],
                ),
                
                SizedBox(height: 40),
                
                // Second row: Facebook, Copy Link, More
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareItem(
                      context,
                      "assets/images/facebook-share.png",
                      "facebook",
                      () async => await _shareToFacebook(context),
                    ),
                    _buildShareItem(
                      context,
                      "assets/images/copy-share.png",
                      "拷贝链接",
                      () => _copyLink(context),
                    ),
                    _buildShareItem(
                      context,
                      null, // Use icon instead of image
                      "更多",
                      () => _shareToMore(context),
                      icon: Icons.more_horiz,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Cancel button
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "取消",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildShareItem(
    BuildContext context,
    String? imagePath,
    String label,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: imagePath != null
                  ? Image.asset(
                      imagePath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      icon ?? Icons.share,
                      size: 32,
                      color: Colors.grey[600],
                    ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToWeChat(BuildContext context) async {
    String shareDesc = desc ?? "";
    if (shareDesc.length > 100) {
      shareDesc = shareDesc.substring(0, 100);
    }
    if (imgUrl != null) {
      Uint8List bytes =
          (await NetworkAssetBundle(
        Uri.parse(imgUrl!),
      ).load(imgUrl!)).buffer.asUint8List();
      IMG.Image? img = IMG.decodeImage(bytes);
      Directory documentDirectory =
          await getApplicationDocumentsDirectory();

      IMG.Image resized = IMG.copyResizeCropSquare(
        img!,
        size: 100,
        interpolation: IMG.Interpolation.cubic,
      );
      Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));

      String postfix = "imagetest.png";

      if (imgUrl!.endsWith("png")) {
        postfix = "imagetest.png";
      } else if (imgUrl!.endsWith("jpg")) {
        postfix = "imagetest.jpg";
      } else if (imgUrl!.endsWith("jpeg")) {
        postfix = "imagetest.jpeg";
      } else if (imgUrl!.endsWith("gif")) {
        postfix = "imagetest.gif";
      }

      File file = File(join(documentDirectory.path, postfix));
      file.writeAsBytesSync(resizedImg);

      ShareParamsBean bean = ShareParamsBean(
        contentType: LaShareContentTypes.webpage,
        platform: SharePlatforms.wechatSession,
        webUrl: url,
        title: title,
        imageFilePath: file.path,
        text: shareDesc,
      );
      // ignore: use_build_context_synchronously
      _share(bean, context);
    } else {
      ShareParamsBean bean = ShareParamsBean(
        contentType: LaShareContentTypes.webpage,
        platform: SharePlatforms.wechatSession,
        webUrl: url,
        imageFilePath: "assets/images/avatar.png",
        title: title,
        text: shareDesc,
      );
      _share(bean, context);
    }

    Navigator.of(context).pop();
  }

  Future<void> _shareToWeChatMoments(BuildContext context) async {
    if (imgUrl != null) {
      Uint8List bytes =
          (await NetworkAssetBundle(
        Uri.parse(imgUrl!),
      ).load(imgUrl!)).buffer.asUint8List();
      IMG.Image? img = IMG.decodeImage(bytes);
      IMG.Image resized = IMG.copyResizeCropSquare(
        img!,
        size: 100,
        interpolation: IMG.Interpolation.cubic,
      );
      Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));
      Directory documentDirectory =
          await getApplicationDocumentsDirectory();
      File file = File(
        join(
          documentDirectory.path,
          imgUrl!.endsWith("png") ? 'imagetest.png' : 'imagetest.jpeg',
        ),
      );
      file.writeAsBytesSync(resizedImg);

      ShareParamsBean bean = ShareParamsBean(
        contentType: LaShareContentTypes.webpage,
        platform: SharePlatforms.wechatTimeline,
        webUrl: url,
        title: title,
        imageFilePath: file.path,
        text: desc,
      );
      _share(bean, context);
    } else {
      ShareParamsBean bean = ShareParamsBean(
        contentType: LaShareContentTypes.webpage,
        platform: SharePlatforms.wechatTimeline,
        webUrl: url,
        imageFilePath: "assets/images/avatar.png",
        title: title,
        text: desc,
      );
      _share(bean, context);
    }
    Navigator.of(context).pop();
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: url ?? ""));
    GFToast.showToast(
      'Share link copy success.'.tr,
      context,
      toastPosition: GFToastPosition.CENTER,
    );
    Navigator.of(context).pop();
  }

  void _shareToMore(BuildContext context) async {
    String body = (title ?? desc ?? "") + ("\n${url ?? ""}");
    Share.share(body);
    Navigator.pop(context);
  }

  Future<void> _shareToFacebook(BuildContext context) async {
    try {
      if (Platform.isIOS) {
        await _shareToBrowser('facebook', context);
      } else {
        bool isInstalled = await SharePlugin.isClientInstalled(SharePlatforms.facebook);
        
        if (isInstalled) {
          ShareParamsBean bean = ShareParamsBean(
            contentType: LaShareContentTypes.webpage,
            platform: SharePlatforms.facebook,
            webUrl: url,
            title: title,
            text: desc,
          );
          
          _shareWithTimeout(bean, context);
        } else {
          await _shareToBrowser('facebook', context);
        }
      }
    } catch (e) {
      print('Facebook share error: $e');
      await _shareToBrowser('facebook', context);
    }
    Navigator.of(context).pop();
  }

  Future<void> _shareToTwitter(BuildContext context) async {
    try {
      if (Platform.isIOS) {
        await _shareToBrowser('twitter', context);
      } else {
        bool isInstalled = await SharePlugin.isClientInstalled(SharePlatforms.twitter);
        
        if (isInstalled) {
          ShareParamsBean bean = ShareParamsBean(
            contentType: LaShareContentTypes.webpage,
            platform: SharePlatforms.twitter,
            webUrl: url,
            title: title,
            text: desc,
          );
          
          _shareWithTimeout(bean, context);
        } else {
          await _shareToBrowser('twitter', context);
        }
      }
    } catch (e) {
      print('Twitter share error: $e');
      await _shareToBrowser('twitter', context);
    }
    Navigator.of(context).pop();
  }

  Future<void> _shareToBrowser(String platform, BuildContext context) async {
    String shareUrl = '';
    String shareText = '${title ?? ''} ${desc ?? ''} ${url ?? ''}';
    
    if (platform == 'facebook') {
      shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url ?? '')}';
    } else if (platform == 'twitter') {
      shareUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(shareText)}';
    }
    
    if (shareUrl.isNotEmpty) {
      try {
        if (await canLaunchUrl(Uri.parse(shareUrl))) {
          await launchUrl(Uri.parse(shareUrl), mode: LaunchMode.externalApplication);
          
          String platformName = platform == 'facebook' ? 'Facebook' : 'X (Twitter)';
          GFToast.showToast(
            GStorage().getLanguageCN() 
                ? '正在通过浏览器分享到$platformName' 
                : 'Sharing to $platformName via browser',
            context,
            toastPosition: GFToastPosition.CENTER,
          );
        } else {
          throw 'Could not launch $shareUrl';
        }
      } catch (e) {
        print('Browser share error: $e');
        GFToast.showToast(
          GStorage().getLanguageCN() 
              ? '分享失败，请稍后重试' 
              : 'Share failed, please try again',
          context,
          toastPosition: GFToastPosition.CENTER,
        );
      }
    }
  }

  void _shareWithTimeout(ShareParamsBean bean, BuildContext context) {
    bool hasResponded = false;
    
    Timer(Duration(seconds: 5), () {
      if (!hasResponded) {
        hasResponded = true;
        GFToast.showToast(
          'share timeout, please check if app is installed'.tr,
          context,
          toastPosition: GFToastPosition.CENTER,
        );
      }
    });
    
    SharePlugin.share(
      bean,
      (platformId) {
        if (!hasResponded) {
          hasResponded = true;
          GFToast.showToast(
            GStorage().getLanguageCN()
                ? '分享平台尚未安装'
                : 'Sharing platform is not yet installed',
            context,
            toastPosition: GFToastPosition.CENTER,
          );
        }
      },
      () {
        if (!hasResponded) {
          hasResponded = true;
          GFToast.showToast(
            'share success'.tr,
            context,
            toastPosition: GFToastPosition.CENTER,
          );
          print('share success');
        }
      },
      (errorCode, errorMessage) {
        if (!hasResponded) {
          hasResponded = true;
          GFToast.showToast(
            'share faild'.tr,
            context,
            toastPosition: GFToastPosition.CENTER,
          );
          print('share failed: $errorCode - $errorMessage');
        }
      },
    );
  }

  _share(ShareParamsBean bean, BuildContext context) {
    SharePlugin.share(
      bean,
      (platformId) {
        GFToast.showToast(
          GStorage().getLanguageCN()
              ? '分享平台尚未安装'
              : 'Sharing platform is not yet installed',
          context,
          toastPosition: GFToastPosition.CENTER,
        );
      },
      () {
        GFToast.showToast(
          'share success'.tr,
          context,
          toastPosition: GFToastPosition.CENTER,
        );
        print('share success');
      },
      (errorCode, errorMessage) {
        GFToast.showToast(
          'share faild'.tr,
          context,
          toastPosition: GFToastPosition.CENTER,
        );
        print('share failed: $errorCode - $errorMessage');
      },
    );
  }
}
