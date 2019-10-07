import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:ovprogresshud/progresshud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static String getLanguageName(BuildContext context, String languageCode) {
    if (languageCode.isEmpty) {
      return S.of(context).languageAuto;
    } else if (languageCode == 'en') {
      return 'English';
    } else
      return '简体中文';
  }

  static Future<String> getCookiePath() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path + "/v2lf_cookie";
    Directory dir = new Directory(tempPath);
    bool b = await dir.exists();
    if (!b) {
      dir.createSync(recursive: true);
    }
    return tempPath;
  }

  // 外链跳转
  static launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, statusBarBrightness: Platform.isIOS ? Brightness.light : null);
    } else {
      Progresshud.showErrorWithStatus('Could not launch $url');
    }
  }

  // 头像转成大图
  static String avatarLarge(String avatar) {
    // 获取到的是24*24大小，改成73*73
    //cdn.v2ex.com/gravatar/3896b6baf91ec1933c38f370964647b7?s=24&d=retro%0A
    //cdn.v2ex.com/avatar/d8fe/ee94/193847_normal.png?m=1477551256
    var regExp1 = RegExp(r's=24');
    var regExp2 = RegExp(r'normal');
    if (avatar.contains(regExp1)) {
      avatar = avatar.replaceFirst(regExp1, 's=73');
    } else if (avatar.contains(regExp2)) {
      avatar = avatar.replaceFirst(regExp2, 'large');
    }

    return avatar;
  }
}
