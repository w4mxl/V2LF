import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/TopicList.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.green, fontFamily: 'Ubuntu'),
      home: new DefaultTabController(
          length: 2,
          child: new Scaffold(
            appBar: new AppBar(
                title: new Text("Explore"),
                elevation:
                    defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
                bottom: new TabBar(
                  isScrollable: false,
                  tabs: choices.map((TabData choice) {
                    return new Tab(
                      text: choice.title,
                    );
                  }).toList(),
                )),
            body: new TabBarView(
              children: choices.map((TabData choice) {
                // Todo 添加每个节点的列表数据
                return new TopicListView(tabKey: choice.key);
              }).toList(),
            ),
            drawer: new Drawer(
              child: new Column(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    accountName: new Text("w4mxl"),
                    accountEmail: new Text("mxl1989@gmail.com"),
                    currentAccountPicture: new CircleAvatar(
                      backgroundImage: new NetworkImage(
                          "https://cdn.v2ex.com/gravatar/3896b6baf91ec1933c38f370964647b7?s=73&d=retro"),
                    ),
                  ),
                  new ListTile(
                    leading: new Icon(Icons.explore),
                    title: new Text("Explore"),
                  ),
                  new ListTile(
                    leading: new Icon(Icons.apps),
                    title: new Text("Nodes"),
                  ),
                  new ListTile(
                    leading: new Icon(Icons.notifications),
                    title: new Text("Notifications"),
                  ),
                  new ListTile(
                    leading: new Icon(Icons.favorite),
                    title: new Text("Favorites"),
                  ),
                  new ListTile(
                    leading: new Icon(Icons.settings),
                    title: new Text("Settings"),
                  ),
                  new ListTile(
                    leading: new Icon(Icons.feedback),
                    title: new Text("Feedback"),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

/// A material design [TabBar] tab.
class TabData {
  const TabData({this.title, this.key});
  final String title;
  final String key;
}

const List<TabData> choices = const <TabData>[
//  const TabData(title: '全部', key: 'all'),
  const TabData(title: '最热', key: 'hot'),
//  const TabData(title: '技术', key: 'tech'),
//  const TabData(title: '创意', key: 'creative'),
//  const TabData(title: '好玩', key: 'play'),
//  const TabData(title: 'APPLE',key: 'apple'),
//  const TabData(title: '酷工作',key: 'jobs'),
//  const TabData(title: '交易',key: 'deals'),
//  const TabData(title: '城市',key: 'city'),
//  const TabData(title: '问与答',key: 'qna'),
//  const TabData(title: 'R2',key: 'r2'),
//  const TabData(title: '关注',key: 'members'),
  const TabData(title: '最近', key: 'recent'),
];
