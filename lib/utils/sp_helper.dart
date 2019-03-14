import 'dart:convert';

import 'package:flutter_app/model/language.dart';
import 'package:flutter_app/model/tab.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String KEY_LANGUAGE = 'key_language';
const String KEY_THEME_COLOR = 'key_theme_color';
const String KEY_MAIN_TABS = 'key_main_tabs';

// font
const String SP_FONT_FAMILY = "font_family";

const String SP_JINRISHICI_TOKEN = "jinrishici_token";

// 与登录状态有关
const String SP_USERNAME = "username";
const String SP_AVATAR = "avatar";

class SpHelper {
  // 需要在 main.dart 初始化
  static SharedPreferences sp;

  // T 用于区分存储类型
  static void putObject<T>(String key, Object value) {
    switch (T) {
      case int:
        sp.setInt(key, value);
        break;
      case double:
        sp.setDouble(key, value);
        break;
      case bool:
        sp.setBool(key, value);
        break;
      case String:
        sp.setString(key, value);
        break;
      case List:
        sp.setStringList(key, value);
        break;
      default:
        sp.setString(key, value == null ? "" : json.encode(value));
        break;
    }
  }

  // 获取设置好的语言
  static LanguageModel getLanguageModel() {
    String _saveLanguage = sp.getString(KEY_LANGUAGE);
    if (isNotEmpty(_saveLanguage)) {
      Map userMap = json.decode(_saveLanguage);
      return LanguageModel.fromJson(userMap);
    }
    return null;
  }

  // 获取设置好的主题
  static String getThemeColor() {
    String _colorKey = sp.getString(KEY_THEME_COLOR);
    if (isEmpty(_colorKey)) {
      _colorKey = 'gray';
    }
    return _colorKey;
  }

  // 获取自定义的主页Tabs
  static List<TabModel> getMainTabs() {
    String _mainTabs = sp.getString(KEY_MAIN_TABS);
//    String _mainTabs = '[{"title":"技术","key":"tech","checked":true},{"title":"创意","key":"creative","checked":false},{"title":"好玩","key":"play","checked":false},{"title":"APPLE","key":"apple","checked":false},{"title":"酷工作","key":"jobs","checked":false},{"title":"交易","key":"deals","checked":false},{"title":"城市","key":"city","checked":false},{"title":"问与答","key":"qna","checked":false},{"title":"最热","key":"hot","checked":false},{"title":"全部","key":"all","checked":false},{"title":"R2","key":"r2","checked":false}]';
    if (isNotEmpty(_mainTabs)) {
      List<TabModel> list = [];
      List<dynamic> linkMap = json.decode(_mainTabs);
      for (var map in linkMap) {
        list.add(TabModel.fromJson(map));
      }
      return list;
    }
    return null;
  }
}
