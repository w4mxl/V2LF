import 'dart:convert';

import 'package:flutter_app/model/language.dart';
import 'package:flutter_app/utils/constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';

class SpHelper {
  // 需要在 main.dart 初始化
  static SharedPreferences sp;

  // 获取设置好的语言
  static LanguageModel getLanguageModel() {
    String _saveLanguage = sp.getString(Constants.KEY_LANGUAGE);
    if (_saveLanguage.isNotEmpty) {
      Map userMap = json.decode(_saveLanguage);
      return LanguageModel.fromJson(userMap);
    }
    return null;
  }

  // 获取设置好的主题
  static String getThemeColor() {
    String _colorKey = sp.getString(Constants.KEY_THEME_COLOR);
    if (_colorKey.isEmpty) {
      _colorKey = 'gray';
    }
    return _colorKey;
  }
}
