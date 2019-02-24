import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:path_provider/path_provider.dart';

const List<String> poems = [
  '晚食以当肉，安步以当车',
  '月上柳梢头，人约黄昏后',
  '春悄悄，夜迢迢',
  '露从今夜白，月是故乡明',
  '君不见走马川行雪海边',
  '问君何能尔，心远地自偏',
  '白发催年老，青阳逼岁除',
  '风不定，人初静',
  '朝而往，暮而归',
  '夕阳无限好，只是近黄昏',
  '一竿风月，一蓑烟雨',
  '潮生理棹，潮平系缆'
];

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
