import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart'; //1 通过intl_translation工具从arb文件生成的代码，所以在第一次运行生成命令之前，此文件不存在

class MyLocalizations {
  static Future<MyLocalizations> load(Locale locale) {
    final String lang = locale.toString();
    String name = '';
    if (lang != null) {
      if (lang.contains('Hans')) {
        name = 'zh_Hans';
      } else if (lang.contains('Hant')) {
        name = 'zh_Hant';
      } else {
        name = 'en';
      }
    }
    final String localeName = name;
    /*final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);*/
    //2 和"messages_all.dart"文件一样，是同时生成的
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return MyLocalizations();
    });
  }

  static MyLocalizations of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  String get login => Intl.message('Login', name: 'login');
  String get languageAuto => Intl.message('Auto', name: 'languageAuto');
  String get titleSetting => Intl.message('Setting', name: 'titleSetting');
  String get titleTheme => Intl.message('Theme', name: 'titleTheme');
  String get titleLanguage => Intl.message('Language', name: 'titleLanguage');
}

//Locale代理类
class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalizationsDelegate();

  //是否支持某个Local
  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  // Flutter会调用此类加载相应的Locale资源类
  @override
  Future<MyLocalizations> load(Locale locale) {
    //3
    return MyLocalizations.load(locale);
  }

  // 当Localizations Widget重新build时，是否调用load重新加载Locale资源.
  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
