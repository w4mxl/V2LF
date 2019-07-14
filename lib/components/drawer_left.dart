import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/search_delegate.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/model/jinrishici.dart';
import 'package:flutter_app/network/api_network.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_favourite.dart';
import 'package:flutter_app/pages/page_history_hot_category.dart';
import 'package:flutter_app/pages/page_login.dart';
import 'package:flutter_app/pages/page_new_topic.dart';
import 'package:flutter_app/pages/page_nodes.dart';
import 'package:flutter_app/pages/page_notifications.dart';
import 'package:flutter_app/pages/page_recent_read_topics.dart';
import 'package:flutter_app/pages/page_setting.dart';
import 'package:flutter_app/theme/theme_data.dart';
import 'package:flutter_app/utils/google_now_images.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerLeft extends StatefulWidget {
  @override
  _DrawerLeftState createState() => _DrawerLeftState();
}

class _DrawerLeftState extends State<DrawerLeft> {
  String userName = "", avatar = "", notificationCount = "";
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
      child: new Drawer(
        child: SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountName: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      child: userName.isEmpty
                          ? Container(
                              child: Text(
                                S.of(context).login,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              width: 72,
                              alignment: Alignment.bottomCenter,
                            )
                          : Opacity(
                              opacity: 0.9,
                              child: Container(
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                color: Colors.grey,
                                padding: EdgeInsets.all(2),
                              ),
                            ),
                      onTap: () {
                        if (userName.isEmpty) {
                          var future = Navigator.push(context,
                              new MaterialPageRoute(builder: (context) => new LoginPage(), fullscreenDialog: true));
                          future.then((value) {
                            // 直接close登录页则value为null；登录成功 value 为 true
                            if (value != null && value) {
                              setState(() {
                                checkLoginState();
                              });
                              //尝试领取每日奖励
                              checkDailyAward();
                            }
                          });
                        } else {
                          // todo -> 个人中心页面
                          _launchURL(Strings.v2exHost + '/member/' + userName);
                        }
                      },
                    ),
                  ],
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
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4, right: 4),
                                          child: Text(
                                            poemOne.data.origin.title,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          '[' + poemOne.data.origin.dynasty + "] " + poemOne.data.origin.author,
                                          style: TextStyle(
                                              color:
                                                  MyTheme.isDark ? MyTheme.appMainColor[300] : MyTheme.appMainColor[700]),
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
                  child: Opacity(
                    child: Container(
                      child: Text(
                        poemOne != null ? poemOne.data.content : "",
                        style: TextStyle(fontSize: 13),
                      ),
                      color: Colors.grey,
                      padding: EdgeInsets.all(2),
                    ),
                    opacity: 0.8,
                  ),
                ), // 随机一句短诗词 poems[Random().nextInt(poems.length - 1)]
                currentAccountPicture: new GestureDetector(
                  onTap: () {
                    if (userName.isEmpty) {
                      //未登录
                      var future = Navigator.push(
                          context, new MaterialPageRoute(builder: (context) => new LoginPage(), fullscreenDialog: true));
                      future.then((value) {
                        // 直接close登录页则value为null；登录成功 value 为 true
                        if (value != null && value) {
                          setState(() {
                            checkLoginState();
                          });
                          //尝试领取每日奖励
                          checkDailyAward();
                        }
                      });
                    } else {
                      // todo -> 个人中心页面
                      _launchURL(Strings.v2exHost + '/member/' + userName);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: avatar.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  "https:" + avatar,
                                )
                              : new AssetImage("assets/images/ic_person.png"),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(36.0)), // currentAccountPicture 宽高是72
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        )),
                  ),
                ),
                // 这里可以根据一天的不同时间显示不同的background，增加美观
                decoration: new BoxDecoration(
                  color: MyTheme.appMainColor,
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: new NetworkImage(GoogleNowImg.allLocation[GoogleNowImg.getRandomLocationIndex()]
                          [GoogleNowImg.getCurrentTimeIndex()])),
                ),
              ),
              new ListTile(
                leading: new Icon(Icons.whatshot),
                title: new Text(S.of(context).history),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new HistoryHotCategory()));
                },
              ),
              new ListTile(
                leading: new Icon(Icons.history),
                title: new Text(S.of(context).recentRead),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RecentReadTopicsPage()));
                },
              ),
              new Divider(
                height: 0,
              ),
              new ListTile(
                enabled: userName.isNotEmpty,
                // 登录后打开
                leading: new Icon(Icons.notifications),
                title: new Text(S.of(context).notifications),
                trailing: Text(notificationCount),
                onTap: () {
                  SpHelper.sp.setString(SP_NOTIFICATION_COUNT, '');
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new NotificationPage()));
                },
              ),
              new ListTile(
                enabled: userName.isNotEmpty, // 登录后打开
                leading: new Icon(Icons.star),
                title: new Text(S.of(context).favorites),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new FavouritePage()));
                },
              ),
              new ListTile(
                leading: new Icon(Icons.apps),
                title: new Text(S.of(context).nodes),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new NodesPage()));
                },
              ),
              new ListTile(
                leading: new Icon(Icons.search),
                title: new Text(S.of(context).search),
                onTap: () {
                  Navigator.pop(context);
                  showSearch(context: context, delegate: SearchSov2exDelegate());
                },
              ),
              new Divider(
                height: 0,
              ),
              new ListTile(
                leading: new Icon(Icons.add),
                title: new Text(S.of(context).create),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context, new MaterialPageRoute(builder: (context) => new NewTopicPage(), fullscreenDialog: true));
                },
              ),
              new Divider(
                height: 0,
              ),
              new ListTile(
                leading: new Icon(Icons.settings),
                title: new Text(S.of(context).settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new SettingPage()));
                },
              ),
              new AboutListTile(
                icon: new Icon(Icons.info),
                child: new Text(S.of(context).about),
                applicationName: "V2LF",
                applicationVersion: "v2019.2",
                // todo
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

  void checkDailyAward() {
    DioWeb.checkDailyAward().then((onValue) {
      if (!onValue) {
        DioWeb.dailyMission();
        print('准备去领取奖励...');
      } else {
        print('已经领过奖励了...');
      }
    });
  }

  checkLoginState() {
    print('wml：checkLoginState');
    if (SpHelper.sp.containsKey(SP_USERNAME)) {
      userName = SpHelper.sp.getString(SP_USERNAME);
      avatar = SpHelper.sp.getString(SP_AVATAR);
      // 显示诗词
      getOnePoem();
      // 显示未读通知数目
      if (SpHelper.sp.getString(SP_NOTIFICATION_COUNT) != null) {
        notificationCount = SpHelper.sp.getString(SP_NOTIFICATION_COUNT);
      }
    }
  }

  Future getOnePoem() async {
    String today = DateTime.now().toString().substring(0, "yyyy-MM-dd".length);
    print('今天是：' + today);
    var spPoem = SpHelper.sp.getStringList(SP_TODAY_POEM);
    if (spPoem != null && spPoem[0] == today) {
      setState(() {
        poemOne = Poem.fromJson(json.decode(spPoem[1]));
      });
    } else {
      var poem = await NetworkApi.getPoem();
      // 存入 sp
      print(json.encode(poem.toJson()));
      SpHelper.sp.setStringList(SP_TODAY_POEM, [today, json.encode(poem.toJson())]);
      if (!mounted) return;
      setState(() {
        if (poem != null) poemOne = poem;
      });
    }
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
    await launch(url, forceWebView: true, statusBarBrightness: Platform.isIOS ? Brightness.light : null);
  } else {
    Fluttertoast.showToast(msg: 'Could not launch $url', gravity: ToastGravity.CENTER);
  }
}
