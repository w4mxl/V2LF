import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/drawer_left.dart';
import 'package:flutter_app/components/listview_tab_topic.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/language.dart';
import 'package:flutter_app/model/tab.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:flutter_app/utils/chinese_localization.dart';
import 'package:flutter_app/utils/constants.dart';
import 'package:flutter_app/utils/events.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/network/http.dart';

import 'components/listview_tab_all.dart'; // make dio as global top-level variable

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() async {
  // 配置 dio
  // add interceptors
  String cookiePath = await Utils.getCookiePath();
  PersistCookieJar cookieJar = new PersistCookieJar(dir: cookiePath); // 持久化 cookie
  dio.interceptors..add(CookieManager(cookieJar))..add(LogInterceptor());
  (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
  dio.options.connectTimeout = 15000;
  dio.options.receiveTimeout = 15000;
  dio.options.baseUrl = Strings.v2exHost;
  dio.options.headers = {
    'user-agent': Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
        : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
  };
  dio.options.validateStatus = (int status) {
    return status >= 200 && status < 300 || status == 304 || status == 302;
  };

  // 实例 sp
  SpHelper.sp = await SharedPreferences.getInstance();

  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  DateTime _lastPressedAt; //上次点击时间

  Locale _locale;
  String _fontFamily = 'Whitney';

  List<TabModel> tabs = TABS;

  // 定义底部导航 Tab
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);
    _init();

    //监听设置中的变动
    eventBus.on<MyEventSettingChange>().listen((event) {
      _loadLocale();
    });

    //监听自定义主页Tab的变动
    eventBus.on<MyEventTabsChange>().listen((event) {
      _loadCustomTabs();
    });
  }

  void _init() {
    _loadLocale();
    _loadCustomTabs();
    // 如果sp中存有用户ID，去验证登录状态是否过期 -> 领取每日奖励
    DioWeb.verifyLoginStatus();
  }

  void _loadLocale() {
    LanguageModel model = SpHelper.getLanguageModel();
    String _colorKey = SpHelper.getThemeColor();
    String _spFont = SpHelper.sp.getString(SP_FONT_FAMILY);
    bool _spIsDark = SpHelper.sp.getBool(SP_IS_DARK);

    if (!mounted) return;
    setState(() {
      if (model != null) {
        _locale = Locale.fromSubtags(languageCode: model.languageCode, scriptCode: model.scriptCode);
      } else {
        _locale = null;
      }

      if (themeColorMap[_colorKey] != null) {
        ColorT.appMainColor = themeColorMap[_colorKey];
      }

      if (_spFont != null && _spFont == 'System') {
        _fontFamily = null;
      } else {
        _fontFamily = 'Whitney';
      }

      if (_spIsDark != null) {
        ColorT.isDark = _spIsDark;
      }
    });
  }

  void _loadCustomTabs() {
    List<TabModel> allTabs = SpHelper.getMainTabs();

    if (allTabs != null) {
      List<TabModel> mainTabs = [];

      for (var tab in allTabs) {
        if (tab.checked) {
          // 过滤选中的
          mainTabs.add(tab);
        }
      }

      setState(() {
        tabs.clear();
        tabs.addAll(mainTabs);
        _tabController = TabController(length: tabs.length, vsync: this);
      });
    }
  }

  //当整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: [
        const MyLocalizationsDelegate(),
        ChineseCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate, // 为Material Components库提供了本地化的字符串和其他值
        GlobalWidgetsLocalizations.delegate, // 定义widget默认的文本方向，从左到右或从右到左
      ],
      // Full Chinese support for CN, TW, and HK
      supportedLocales: [
        const Locale.fromSubtags(languageCode: 'zh'), // generic Chinese 'zh'
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), // generic simplified Chinese 'zh_Hans'
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), // generic traditional Chinese 'zh_Hant'
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'), // 'zh_Hans_CN'
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'), // 'zh_Hant_TW'
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'), // 'zh_Hant_HK'
        const Locale('en', ''),
      ],
      theme: new ThemeData(
          brightness: ColorT.isDark ? Brightness.dark : Brightness.light,
          primarySwatch: ColorT.appMainColor,
          fontFamily: _fontFamily),
      home: WillPopScope(
        child: new Scaffold(
            appBar: AppBar(
              title: new TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                tabs: tabs.map((TabModel choice) {
                  return new Tab(
                    text: choice.title,
                  );
                }).toList(),
              ),
              elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
            ),
            body: new TabBarView(
              controller: _tabController,
              children: tabs.map((TabModel choice) {
                return choice.key == 'all' ? TabAllListView('all') : TopicListView(choice.key);
              }).toList(),
            ),
            drawer: new DrawerLeft()),
        onWillPop: () async {
          if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
            // 1秒内连续按两次返回键退出
            // 两次点击间隔超过1秒则重新计时
            _lastPressedAt = DateTime.now();
            return false;
          }
          return true;
        },
      ),
    );
  }
}
