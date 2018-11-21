import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.green),
      home: new DefaultTabController(
          length: 13,
          child: new Scaffold(
            appBar: new AppBar(
                title: new Text("Explore"),
                elevation:
                    defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
                bottom: new TabBar(
                  isScrollable: true,
                  tabs: choices.map((Choice choice) {
                    return new Tab(
                      text: choice.title,
                    );
                  }).toList(),
                )),
            body: new TabBarView(
              children: choices.map((Choice choice) {
                print("init" + choice.title);
                return new Text(choice.title);
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
class Choice {
  const Choice({this.title});

  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: '技术'),
  const Choice(title: '创意'),
  const Choice(title: '好玩'),
  const Choice(title: 'APPLE'),
  const Choice(title: '酷工作'),
  const Choice(title: '交易'),
  const Choice(title: '城市'),
  const Choice(title: '问与答'),
  const Choice(title: '最热'),
  const Choice(title: '全部'),
  const Choice(title: 'R2'),
  const Choice(title: '最近'),
  const Choice(title: '关注'),
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Explore"),
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
      ),
      body: new Center(),
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
    );
  }
}
