import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/drawer_left.dart';
import 'package:flutter_app/components/listview_tab_topic.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/language.dart';
import 'package:flutter_app/model/tab.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:flutter_app/utils/chinese_localization.dart';
import 'package:flutter_app/utils/constants.dart';
import 'package:flutter_app/utils/events.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

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
    _initAsync();

    //监听设置中的变动
    eventBus.on<MyEventSettingChange>().listen((event) {
      _loadLocale();
    });

    //监听自定义主页Tab的变动
    eventBus.on<MyEventTabsChange>().listen((event) {
      _loadCustomTabs();
    });
  }

  void _initAsync() async {
    SpHelper.sp = await SharedPreferences.getInstance();

    _loadLocale();
    _loadCustomTabs();
  }

  void _loadLocale() {
    LanguageModel model = SpHelper.getLanguageModel();
    String _colorKey = SpHelper.getThemeColor();
    String _spFont = SpHelper.sp.getString(SP_FONT_FAMILY);

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
      theme: new ThemeData(primarySwatch: ColorT.appMainColor, fontFamily: _fontFamily),
      home: WillPopScope(
        child: new Scaffold(
            appBar: AppBar(
              title: new TabBar(
                controller: _tabController,
                isScrollable: true,
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
                return new TopicListView(choice.key);
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
