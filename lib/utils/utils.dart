import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static String getLanguageName(BuildContext context, String languageCode, String scriptCode) {
    if (languageCode.isEmpty && scriptCode.isEmpty) {
      return MyLocalizations.of(context).languageAuto;
    } else if (languageCode == 'en') {
      return 'English';
    } else if (scriptCode == 'Hans') {
      return '简体中文';
    } else {
      return '繁體中文';
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
}
