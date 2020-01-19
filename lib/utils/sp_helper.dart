import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/tab.dart';
import 'package:flutter_app/states/model_display.dart';
import 'package:flutter_app/states/model_locale.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String SP_LANGUAGE = 'language';
const String SP_THEME_COLOR = 'theme_color';
const String KEY_MAIN_TABS = 'key_main_tabs';

// font
const String SP_FONT_FAMILY = "font_family";

// 正文（和评论）字号大小： smaller normal larger
const String SP_CONTENT_FONT_SIZE = "content_font_size";

const String SP_JINRISHICI_TOKEN = "jinrishici_token";

const String SP_AUTO_AWARD = "auto_award";

// 与登录状态有关
const String SP_USERNAME = "username";
const String SP_AVATAR = "avatar";
const String SP_ONCE = "once";

// theme mode:  dark / light / follow system
const String SP_THEME_MODE = "theme_mode";

// 搜索历史记录
const String SP_SEARCH_HISTORY = "search_history";

// 今日诗词
const String SP_TODAY_POEM = "today_poem";

// 首次进入「新建主题页」
const String SP_FIRST_TIME_NEW_TOPCI = "first_time_new_topic";

// 有未读提醒，存一下数目
const String SP_NOTIFICATION_COUNT = "sp_notification_cout";

class SpHelper {
  // 需要在 main.dart 初始化
  static SharedPreferences sp;

  // T 用于区分存储类型
  static void setObject<T>(String key, Object value) {
    sp.setString(key, value == null ? "" : json.encode(value));
  }

  /// get object
  static T getObject<T>(String key, T f(Map v), {T defValue}) {
    String _data = sp.getString(key);
    Map map = (isEmpty(_data)) ? null : json.decode(_data);
    return map == null ? defValue : f(map);
  }

  // 获取设置好的语言
  static Locale getLocale() {
    String _spLanguage = sp.getString(SP_LANGUAGE);
    switch (_spLanguage) {
      case LOCALE_ZH:
        return Locale('zh', 'CN');
      case LOCALE_EN:
        return Locale('en', '');
      default:
        return null;
    }
  }

  // 获取设置好的主题
  static String getThemeColor() {
    String _spColor = sp.getString(SP_THEME_COLOR);
    if (isEmpty(_spColor)) {
      _spColor = 'blueGrey';
    }
    return _spColor;
  }

  // 获取设置好的外观
  static ThemeMode getThemeMode() {
    String _spThemeMode = sp.getString(SP_THEME_MODE);
    switch (_spThemeMode) {
      case THEME_MODE_LIGHT:
        return ThemeMode.light;
      case THEME_MODE_DARK:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String getFontFamily() {
    var _fontFamily = sp.getString(SP_FONT_FAMILY);
    if (_fontFamily == null) {
      _fontFamily = 'Whitney';
    }
    return _fontFamily;
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
