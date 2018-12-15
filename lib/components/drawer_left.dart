import 'package:flutter/material.dart';
import 'package:flutter_app/page_nodes.dart';

class DrawerLeft extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new Column(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text("w4mxl"),
            accountEmail: new Text("mxl1989@gmail.com"),
            currentAccountPicture: new GestureDetector(
              onTap: () => print("显示个人主页web"), // todo
              child: new CircleAvatar(
                backgroundImage:
                    new NetworkImage("https://cdn.v2ex.com/gravatar/3896b6baf91ec1933c38f370964647b7?s=73&d=retro"),
              ),
            ),
            // todo 这里可以根据一天的不同时间显示不同的background，增加美观
            /*decoration: new BoxDecoration(
                image: new DecorationImage(
                    fit: BoxFit.cover, image: new NetworkImage("https://i.loli.net/2018/12/06/5c08c7b804e89.png"))),*/
          ),
          // todo 目前没必要，这里后面考虑要不要有
          /*new ListTile(
            leading: new Icon(Icons.explore),
            title: new Text("浏览"),
            onTap: () {
              Navigator.pop(context);
            },
          ),*/
          new ListTile(
            leading: new Icon(Icons.apps),
            title: new Text("节点"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new NodesPage()));
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
          new Divider(),
          new ListTile(
            leading: new Icon(Icons.settings),
            title: new Text("设置"),
          ),
          new ListTile(
            leading: new Icon(Icons.feedback),
            title: new Text("反馈"),
          ),
          new AboutListTile(
            icon: new Icon(Icons.info),
            child: new Text("关于"),
            applicationName: "V2lf",
            applicationVersion: "0.0.1",
            applicationIcon: new Image.asset(
              "images/ic_launcher.png",
              width: 64.0,
              height: 64.0,
            ),
            aboutBoxChildren: <Widget>[
              new Text("Another v2ex unoffical app in flutter.And 'V2lf' means 'way to love flutter'."),
              new Text(""),
              new Text(" ；）")
            ],
          )
        ],
      ),
    );
  }
}
