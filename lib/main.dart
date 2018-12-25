import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/drawer_left.dart';
import 'package:flutter_app/components/tab_topic_listview.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
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
      theme: new ThemeData(primarySwatch: Colors.blueGrey, fontFamily: 'Whitney'),
      home: new DefaultTabController(
          length: tabs.length,
          child: new Scaffold(
              body: NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool bodyIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                          pinned: true,
                          floating: true,
                          snap: true,
                          elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
                          bottom: new TabBar(
                            isScrollable: true,
                            tabs: tabs.map((TabData choice) {
                              return new Tab(
                                text: choice.title,
                              );
                            }).toList(),
                          ))
                    ];
                  },
                  body: new TabBarView(
                    children: tabs.map((TabData choice) {
                      return new TopicListView(choice.key);
                    }).toList(),
                  )),
              drawer: new DrawerLeft())),
    );

    Future<bool> loginState() async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      return sharedPreferences.getBool("is_login");
    }
  }
}

class TabData {
  const TabData({this.title, this.key});

  final String title;
  final String key;
}
