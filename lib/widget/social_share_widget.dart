import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

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
    List<Widget> itemWidgets = [
      GFIconButton(
        color: Colors.transparent,
        onPressed: () {
          ShareParamsBean bean = ShareParamsBean(
            contentType: LaShareContentTypes.webpage,
            platform: SharePlatforms.facebook,
            webUrl: '${desc ?? ''}\n$url',
            title: title,
            text: desc,
          );
          _share(bean, context);
          Navigator.of(context).pop();
          // appId: "1491275361339092
        },
        icon: Image.asset("assets/icon/facebook-share.png"),
      ),
      GFIconButton(
        color: Colors.transparent,
        onPressed: () {
          ShareParamsBean bean = ShareParamsBean(
            contentType: LaShareContentTypes.webpage,
            platform: SharePlatforms.twitter,
            webUrl: '${desc ?? ''}\n$url',
            title: title,
            text: desc,
          );
          _share(bean, context);
          Navigator.of(context).pop();
        },
        icon: Image.asset("assets/icon/twitter-share.png"),
      ),
      GFIconButton(
        color: Colors.transparent,
        onPressed: () async {
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
        },
        icon: Image.asset("assets/icon/wechat-share.png"),
      ),
      GFIconButton(
        color: Colors.transparent,
        onPressed: () async {
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
        },
        icon: Image.asset("assets/icon/session-share.png"),
      ),
      GFIconButton(
        color: Colors.transparent,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: url ?? ""));
          GFToast.showToast(
            'Share link copy success.'.tr,
            context,
            toastPosition: GFToastPosition.CENTER,
          );
          Navigator.of(context).pop();
        },
        icon: SizedBox(
          child: Icon(Icons.copy_sharp, size: 40, color: Colors.white),
        ),
      ),
      GFIconButton(
        color: Colors.transparent,
        onPressed: () async {
          String body = (title ?? desc ?? "") + ("\n${url ?? ""}");
          Share.share(body);
          Navigator.pop(context);
        },
        icon: SizedBox(
          child: Icon(Icons.more_horiz, size: 40, color: Colors.white),
        ),
      ), //Image.asset("assets/icon/sns-share.png")),
    ];

    return SizedBox(
      height: 144,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: GFItemsCarousel(
              itemHeight: 82,
              rowCount: 6,
              children: itemWidgets,
            ),
          ),
          const SizedBox(height: 54),
        ],
      ),
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
      () {
        GFToast.showToast(
          'share faild'.tr,
          context,
          toastPosition: GFToastPosition.CENTER,
        );
        print('share faild');
      },
    );
  }
}
