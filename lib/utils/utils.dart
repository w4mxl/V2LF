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
    } else if (languageCode == 'zh') {
      return '简体中文';
    }
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
}
