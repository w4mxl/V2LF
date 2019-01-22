import 'package:fluintl/fluintl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/drawer_left.dart';
import 'package:flutter_app/components/tab_topic_listview.dart';
import 'package:flutter_app/model/language.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:flutter_app/resources/strings.dart';
import 'package:flutter_app/utils/constants.dart';
import 'package:flutter_app/utils/eventbus.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  Color _themeColor = ColorT.app_main;

  @override
  void initState() {
    super.initState();
    setLocalizedValues(localizedValues); //配置多语言资源
    _initAsync();
  }

  void _initAsync() async {
    SpHelper.sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    _loadLocale();
  }

  void _loadLocale() async {
    LanguageModel model = SpHelper.getLanguageModel();
    String _colorKey = SpHelper.getThemeColor();
    setState(() {
      if (model != null) {
        _locale = new Locale(model.languageCode, model.countryCode);
      } else {
        _locale = null;
      }

      if (themeColorMap[_colorKey] != null) _themeColor = themeColorMap[_colorKey];
    });
  }

  @override
  Widget build(BuildContext context) {
    //监听登录事件
    bus.on(EVENT_NAME_SETTING, (arg) {
      _loadLocale();
    });

    const List<TabData> tabs = const <TabData>[
      const TabData(title: '技术', key: 'tech'),
      const TabData(title: '创意', key: 'creative'),
      const TabData(title: '好玩', key: 'play'),
      const TabData(title: 'APPLE', key: 'apple'),
      const TabData(title: '酷工作', key: 'jobs'),
      const TabData(title: '交易', key: 'deals'),
      const TabData(title: '城市', key: 'city'),
      const TabData(title: '问与答', key: 'qna'),
      const TabData(title: '最热', key: 'hot'),
      const TabData(title: '全部', key: 'all'),
      const TabData(title: 'R2', key: 'r2'),
      /*const TabData(title: '关注', key: 'members'),
  const TabData(title: '最近', key: 'recent'),*/
    ];

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        CustomLocalizations.delegate
      ],
      supportedLocales: CustomLocalizations.supportedLocales,
      theme: new ThemeData(primarySwatch: Colors.blueGrey, fontFamily: 'Whitney'),
      home: new DefaultTabController(
          length: tabs.length,
          child: new Scaffold(
              appBar: AppBar(
                title: new TabBar(
                  isScrollable: true,
                  tabs: tabs.map((TabData choice) {
                    return new Tab(
                      text: choice.title,
                    );
                  }).toList(),
                ),
                elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
              ),
              body: new TabBarView(
                children: tabs.map((TabData choice) {
                  return new TopicListView(choice.key);
                }).toList(),
              ),
              drawer: new DrawerLeft())),
    );

    /*Future<bool> loginState() async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      return sharedPreferences.getBool("is_login");
    }*/
  }
}

class TabData {
  const TabData({this.title, this.key});

  final String title;
  final String key;
}
