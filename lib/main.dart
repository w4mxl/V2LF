import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/components/drawer_left.dart';
import 'package:flutter_app/components/listview_tab_topic.dart';
import 'package:flutter_app/models/tab.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/network/http.dart';
import 'package:flutter_app/pages/page_notifications.dart';
import 'package:flutter_app/states/model_display.dart';
import 'package:flutter_app/states/model_locale.dart';
import 'package:flutter_app/utils/constants.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/listview_tab_all.dart';
import 'generated/i18n.dart';
import 'utils/event_bus.dart';

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 配置 dio
  // add interceptors
  String cookiePath = await Utils.getCookiePath();
  PersistCookieJar cookieJar =
      new PersistCookieJar(dir: cookiePath); // 持久化 cookie
  dio.interceptors
    ..add(CookieManager(cookieJar))
    ..add(LogInterceptor())
    ..add(DioCacheManager(CacheConfig(baseUrl: Strings.v2exHost)).interceptor);
  (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
  dio.options.connectTimeout = 12000;
  dio.options.receiveTimeout = 12000;
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

  runApp(MyApp());

  // 在 Android 上设置沉浸式状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  final navigatorKey = GlobalKey<NavigatorState>();

  DateTime _lastPressedAt; //上次点击时间

  List<TabModel> tabs = TABS;

  // 定义底部导航 Tab
  TabController _tabController;

  // 本地消息推送
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);
    _init();

    //监听自定义主页Tab的变动
    eventBus.on(MyEventTabsChange, (arg) {
      _loadCustomTabs();
    });

    //监听是否有未读消息需要通知
    eventBus.on(MyEventHasNewNotification, (unreadNumber) async {
      // 展示本地通知
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'notify', '有未读消息通知', 'v2ex平台的未读消息',
          importance: Importance.Max,
          priority: Priority.High,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, 'V2LF 提醒您',
          '您有$unreadNumber条 V2EX 的未读消息，点击查看', platformChannelSpecifics,
          payload: '');
    });
  }

  _init() {
    _loadCustomTabs();
    _initializeNotify();
    // 如果sp中存有用户ID，去验证登录状态是否过期 -> 领取每日奖励
    DioWeb.verifyLoginStatus();
    // 初始化获取设备系统版本号，设置页用到
    Utils.deviceInfo();
  }

  _loadCustomTabs() {
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

  _initializeNotify() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('ic_stat_v');
    var ios = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    SpHelper.sp.setString(SP_NOTIFICATION_COUNT, '');

    await navigatorKey.currentState.push(
      MaterialPageRoute(builder: (context) => NotificationPage()),
    );
  }

  //当整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    _tabController.dispose();
    eventBus.off(MyEventTabsChange);
    eventBus.off(MyEventHasNewNotification);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DisplayModel()),
        ChangeNotifierProvider.value(value: LocaleModel())
      ],
      child: Consumer2<DisplayModel, LocaleModel>(
        builder: (context, displayModel, localeModel, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            locale: localeModel.locale,
            localizationsDelegates: [
              S.delegate,
              // 为 Cupertino Components 库提供了本地化的字符串和其他值
              GlobalCupertinoLocalizations.delegate,
              // 为 Material Components 库提供了本地化的字符串和其他值
              GlobalMaterialLocalizations.delegate,
              // 定义 widget 默认的文本方向，从左到右或从右到左
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            theme: displayModel.themeDate(),
            darkTheme: displayModel.themeDate(darkTheme: true),
            themeMode: displayModel.themeMode,
            home: WillPopScope(
              child: new Scaffold(
                  appBar: AppBar(
                    title: new TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: tabs.map((TabModel choice) {
                        return new Tab(
                          text: choice.title,
                        );
                      }).toList(),
                    ),
                    elevation: defaultTargetPlatform == TargetPlatform.android
                        ? 5.0
                        : 0.0,
                  ),
                  body: new TabBarView(
                    controller: _tabController,
                    children: tabs.map((TabModel choice) {
                      return choice.key == 'all'
                          ? TabAllListView('all')
                          : TopicListView(choice.key);
                    }).toList(),
                  ),
                  drawer: new DrawerLeft()),
              onWillPop: () async {
                if (_lastPressedAt == null ||
                    DateTime.now().difference(_lastPressedAt) >
                        Duration(seconds: 1)) {
                  // 1秒内连续按两次返回键退出
                  // 两次点击间隔超过1秒则重新计时
                  _lastPressedAt = DateTime.now();
                  return false;
                }
                return true;
              },
            ),
          );
        },
      ),
    );
  }
}
