import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/search_delegate.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/jinrishici.dart';
import 'package:flutter_app/network/api_network.dart';
import 'package:flutter_app/network/dio_singleton.dart';
import 'package:flutter_app/page_favourite_topics.dart';
import 'package:flutter_app/page_login.dart';
import 'package:flutter_app/page_nodes.dart';
import 'package:flutter_app/page_notifications.dart';
import 'package:flutter_app/page_setting.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DrawerLeft extends StatefulWidget {
  @override
  _DrawerLeftState createState() => _DrawerLeftState();
}

class _DrawerLeftState extends State<DrawerLeft> {
  String userName = "", avatar = "";
  Poem poemOne;

  @override
  void initState() {
    super.initState();
    checkLoginState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle aboutTextStyle = themeData.textTheme.body2;
    final TextStyle linkStyle = themeData.textTheme.body2.copyWith(color: themeData.accentColor);

    return SizedBox(
      width: 260.0,
      child: new Drawer(
        child: SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountName: GestureDetector(
                  onTap: () {
                    if (userName.isEmpty) {
                      var future = Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
                      future.then((value) {
                        setState(() {
                          checkLoginState();
                        });
                      });
                    } else {
                      // todo -> 个人中心页面
                      _launchURL(DioSingleton.v2exHost + '/member/' + userName);
                    }
                  },
                  child: Text(
                    userName.isNotEmpty ? userName : "      " + MyLocalizations.of(context).login,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                accountEmail: GestureDetector(
                  onTap: () {
                    if (poemOne != null) {
                      // 显示诗词dialog
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => SimpleDialog(
                                children: <Widget>[
                                  Center(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          poemOne.data.origin.title,
                                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          '[' + poemOne.data.origin.dynasty + "] " + poemOne.data.origin.author,
                                          style: TextStyle(color: ColorT.appMainColor[700]),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            children: poemOne.data.origin.content
                                                .map((value) => Text(
                                                      value
                                                          .replaceAll('。', '。\n')
                                                          .replaceAll('，', '，\n')
                                                          .replaceAll('？', '？\n')
                                                          .replaceAll('！', '！\n'),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontSize: 16.0),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ));
                    }
                  },
                  child: Text(poemOne != null ? poemOne.data.content : ""),
                ), // 随机一句短诗词 poems[Random().nextInt(poems.length - 1)]
                currentAccountPicture: new GestureDetector(
                  onTap: () {
                    if (userName.isEmpty) {
                      //未登录
                      var future = Navigator.push(context, new MaterialPageRoute(builder: (context) => new LoginPage()));
                      future.then((value) {
                        setState(() {
                          checkLoginState();
                        });
                      });
                    } else {
                      // todo -> 个人中心页面
                      _launchURL(DioSingleton.v2exHost + '/member/' + userName);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: avatar.isNotEmpty
                              ? CachedNetworkImageProvider("https:" + avatar,)
                              : new AssetImage("assets/images/ic_person.png"),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(36.0)), // currentAccountPicture 宽高是72
                        border: Border.all(
                          color: Colors.white,
                          width: 1.0,
                        )),
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
                leading: new Icon(Icons.search),
                title: new Text('Search'),
                onTap: () {
                  Navigator.pop(context);
                  showSearch(context: context, delegate: MySearchDelegate());
                },
              ),
              new ListTile(
                leading: new Icon(Icons.apps),
                title: new Text(MyLocalizations.of(context).nodes),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new NodesPage()));
                },
              ),
              new ListTile(
                enabled: userName.isNotEmpty, // 登录后打开
                leading: new Icon(Icons.notifications),
                title: new Text(MyLocalizations.of(context).notifications),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new NotificationTopics()));
                },
              ),
              new ListTile(
                enabled: userName.isNotEmpty, // 登录后打开
                leading: new Icon(Icons.favorite),
                title: new Text(MyLocalizations.of(context).favorites),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new FavTopics()));
                },
              ),
              new Divider(),
              new ListTile(
                leading: new Icon(Icons.settings),
                title: new Text(MyLocalizations.of(context).settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new SettingPage()));
                },
              ),
              new ListTile(
                leading: new Icon(Icons.feedback),
                title: new Text(MyLocalizations.of(context).feedback),
                onTap: () {
                  _launchURL("mailto:mxl1989@gmail.com?subject=V2LF%20Feedback&body=New%20feedback");
                },
              ),
              new AboutListTile(
                icon: new Icon(Icons.info),
                child: new Text(MyLocalizations.of(context).about),
                applicationName: "V2LF",
                applicationVersion: "v0.4.5",
                applicationLegalese: '© 2019 Wml',
                applicationIcon: new Image.asset(
                  "assets/images/icon/ic_launcher.png",
                  width: 64.0,
                  height: 64.0,
                ),
                aboutBoxChildren: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: RichText(
                        text: TextSpan(
                      children: [
                        TextSpan(
                            style: aboutTextStyle,
                            text:
                                "V2LF is a v2ex unofficial app.'V2LF' means 'way to love flutter'.\n\nTo see the progress for this project, please visit the "),
                        _LinkTextSpan(
                          style: linkStyle,
                          url: 'https://trello.com/b/YPOJsfQx/v2lf',
                          text: 'v2lf roadmap',
                        ),
                        TextSpan(
                          style: aboutTextStyle,
                          text: '.\n\n¯\\_(ツ)_/¯',
                        ),
                      ],
                    )),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  checkLoginState() {
    var spUsername = SpHelper.sp.getString(SP_USERNAME);
    if (spUsername != null && spUsername.length > 0) {
      userName = spUsername;
      avatar = SpHelper.sp.getString(SP_AVATAR);
      getOnePoem();
    }
  }

  Future getOnePoem() async {
    var poem = await NetworkApi.getPoem();
    if (!mounted) return;
    setState(() {
      if (poem != null) poemOne = poem;
    });
  }
}

class _LinkTextSpan extends TextSpan {
  _LinkTextSpan({TextStyle style, String url, String text})
      : super(
            style: style,
            text: text ?? url,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch(url);
              });
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    if (url.startsWith('mailto')) {
      await launch(url);
    } else {
      await launch(url, forceWebView: true,statusBarBrightness: Brightness.light);
    }
  } else {
    Fluttertoast.showToast(msg: '您似乎没在手机上安装邮件客户端 ?', gravity: ToastGravity.CENTER);
  }
}
