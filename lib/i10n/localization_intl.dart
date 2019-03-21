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

  toastLoginSuccess(name) => Intl.message('Welcome back, $name!', name: 'toastLoginSuccess', args: [name]);

  String get languageAuto => Intl.message('Auto', name: 'languageAuto');

  String get titleSetting => Intl.message('Setting', name: 'titleSetting');

  String get titleTheme => Intl.message('Theme', name: 'titleTheme');
  String get titleSystemFont => Intl.message('System Font', name: 'titleSystemFont');

  String get titleLanguage => Intl.message('Language', name: 'titleLanguage');

  String get titlePersonalityHome => Intl.message('Personality Homepage', name: 'titlePersonalityHome');
  String get hintPersonalityHome => Intl.message('Reselect and sort the nodes displayed on the homepage', name: 'hintPersonalityHome');
  String get titleToRate => Intl.message('Rate', name: 'titleToRate');
  String get titleRecommend => Intl.message('Recommend', name: 'titleRecommend');

  // drawer
  String get search => Intl.message('Search', name: 'search');
  String get nodes => Intl.message('Nodes', name: 'nodes');
  String get notifications => Intl.message('Notifications', name: 'notifications');
  String get favorites => Intl.message('Favorites', name: 'favorites');
  String get settings => Intl.message('Settings', name: 'settings');
  String get feedback => Intl.message('Feedback', name: 'feedback');
  String get about => Intl.message('About', name: 'about');

  String get noHistorySearch => Intl.message('No search history', name: 'noHistorySearch');
  String get clearHistorySearch => Intl.message('Clear history', name: 'clearHistorySearch');

  loadingPage(num) => Intl.message('Loading page $num ...', name: 'loadingPage', args: [num]);

  String get noComment => Intl.message('no comment yet', name: 'noComment');
  String get account => Intl.message('Account', name: 'account');
  String get enterAccount => Intl.message('Enter account', name: 'enterAccount');
  String get password => Intl.message('Password', name: 'password');
  String get enterPassword => Intl.message('Enter password', name: 'enterPassword');

  String get captcha => Intl.message('Captcha', name: 'captcha');
  String get enterCaptcha => Intl.message('Enter right captcha', name: 'enterCaptcha');
  String get forgetPassword => Intl.message('Forgot password ?', name: 'forgetPassword');

  String get logoutLong => Intl.message('Log out', name: 'logoutLong');
  String get sureLogout => Intl.message('Are you sure you want to sign out ?', name: 'sureLogout');

  String get logout => Intl.message('Logout', name: 'logout');
  String get cancel => Intl.message('Cancel', name: 'cancel');

  String get reply => Intl.message('Reply', name: 'reply');


  String get replyHint => Intl.message('(u_u)  Please try to make the reply helpful to others', name: 'replyHint');
  String get replySuccess => Intl.message('Reply Success!', name: 'replySuccess');
  String get thank => Intl.message('Thank', name: 'thank');
  String get actionFav => Intl.message('Favorite', name: 'actionFav');


  String get browser => Intl.message('Open from browser', name: 'browser');
  String get copyLink => Intl.message('Copy link', name: 'copyLink');
  String get copyContent => Intl.message('Copy content', name: 'copyContent');
  String get share => Intl.message('Share', name: 'share');

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
