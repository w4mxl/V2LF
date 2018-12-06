import 'package:flutter/material.dart';
import 'package:flutter_app/nodes_page.dart';

class DrawerLeft extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
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
            title: new Text("浏览"),
          ),
          new ListTile(
            leading: new Icon(Icons.apps),
            title: new Text("节点"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => new NodesPage()));
            },
          ),
          new ListTile(
            leading: new Icon(Icons.notifications),
            title: new Text("通知"),
          ),
          new ListTile(
            leading: new Icon(Icons.favorite),
            title: new Text("收藏"),
          ),
          new ListTile(
            leading: new Icon(Icons.settings),
            title: new Text("设置"),
          ),
          new ListTile(
            leading: new Icon(Icons.feedback),
            title: new Text("反馈"),
          )
        ],
      ),
    );
  }
}
