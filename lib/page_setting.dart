import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/language.dart';
import 'package:flutter_app/page_reorderable_tabs.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:flutter_app/utils/events.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_whatsnew/flutter_whatsnew.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/v2ex_client.dart';
/*import 'package:flame/animation.dart' as animation;
import 'package:flame/flame.dart';
import 'package:flame/position.dart';*/

// 设置页面
class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<LanguageModel> _list = new List();
  LanguageModel _currentLanguage;
  bool _switchSystemFont = false;

  @override
  void initState() {
    super.initState();

    _list.add(LanguageModel('', ''));
    _list.add(LanguageModel('zh', 'Hans'));
    _list.add(LanguageModel('zh', 'Hant'));
    _list.add(LanguageModel('en', 'US'));

    _currentLanguage = SpHelper.getLanguageModel();
    if (_currentLanguage == null) {
      _currentLanguage = _list[0];
    }

    _updateData();

    String _spFont = SpHelper.sp.getString(SP_FONT_FAMILY);
    if (_spFont != null && _spFont == 'System') {
      _switchSystemFont = true;
    }
  }

  void _updateData() {
    print(_currentLanguage.toString());
    String language = _currentLanguage.scriptCode;
    for (int i = 0, length = _list.length; i < length; i++) {
      _list[i].isSelected = (_list[i].scriptCode == language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyLocalizations.of(context).titleSetting),
      ),
      body: Container(
        color: ColorT.isDark ? Colors.black : CupertinoColors.lightBackgroundGray,
        child: ListView(
          children: <Widget>[
            // 主页tab设置
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              color: Theme.of(context).cardColor,
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 0.0,
                  ),
                  ListTile(
                    leading: Icon(Icons.table_chart),
                    title: Text(MyLocalizations.of(context).titlePersonalityHome),
                    subtitle: Text(
                      MyLocalizations.of(context).hintPersonalityHome,
                      style: TextStyle(fontSize: 14.0),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReorderableListTabs()));
                    },
                  ),
                  Divider(
                    height: 0.0,
                  ),
                ],
              ),
            ),
            Container(
              color: Theme.of(context).cardColor,
              margin: EdgeInsets.only(top: 15.0),
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 0.0,
                  ),
                  // 主题设置
                  ExpansionTile(
                    leading: Icon(Icons.color_lens),
                    title: Text(MyLocalizations.of(context).titleTheme),
                    children: <Widget>[
                      Wrap(
                        children: themeColorMap.keys.map((key) {
                          Color value = themeColorMap[key];
                          return new InkWell(
                            onTap: () {
                              SpHelper.sp.setString(KEY_THEME_COLOR, key);
                              eventBus.fire(new MyEventSettingChange());
                            },
                            child: new Container(
                              margin: EdgeInsets.all(5.0),
                              width: 36.0,
                              height: 36.0,
                              color: value,
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  Divider(
                    height: 0.0,
                    indent: 20.0,
                  ),
                  // 字体切换
                  SwitchListTile(
                    value: _switchSystemFont,
                    onChanged: (value) {
                      setState(() {
                        _switchSystemFont = value;
                        if (value) {
                          SpHelper.sp.setString(SP_FONT_FAMILY, 'System');
                        } else {
                          SpHelper.sp.setString(SP_FONT_FAMILY, 'Whitney');
                        }
                        eventBus.fire(new MyEventSettingChange());
                      });
                    },
                    title: Text(MyLocalizations.of(context).titleSystemFont),
                    secondary: Icon(Icons.font_download),
                    selected: false,
                  ),
                  Divider(
                    height: 0.0,
                  ),
                ],
              ),
            ),
            // 多语言设置
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              color: Theme.of(context).cardColor,
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 0.0,
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.language),
                    title: Row(
                      children: <Widget>[
                        Text(MyLocalizations.of(context).titleLanguage),
                        Expanded(
                          child: Text(
                            SpHelper.getLanguageModel() == null
                                ? MyLocalizations.of(context).languageAuto
                                : Utils.getLanguageName(context, SpHelper.getLanguageModel().languageCode,
                                    SpHelper.getLanguageModel().scriptCode),
                            style: TextStyle(
                              fontSize: 14.0,
                              color: ColorT.gray_99,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    children: <Widget>[
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: _list.length,
                          itemBuilder: (BuildContext context, int index) {
                            LanguageModel model = _list[index];
                            return new ListTile(
                              title: new Text(
                                (model.languageCode.isEmpty
                                    ? MyLocalizations.of(context).languageAuto
                                    : Utils.getLanguageName(context, model.languageCode, model.scriptCode)),
                                style: new TextStyle(fontSize: 13.0),
                              ),
                              trailing: new Radio(
                                  value: true,
                                  groupValue: model.isSelected == true,
                                  //activeColor: Colors.indigoAccent,
                                  onChanged: (value) {
                                    setState(() {
                                      updateLanguage(model);
                                    });
                                  }),
                              onTap: () {
                                setState(() {
                                  updateLanguage(model);
                                });
                              },
                            );
                          }),
                    ],
                  ),
                  Divider(
                    height: 0.0,
                  ),
                ],
              ),
            ),
            Container(
              color: Theme.of(context).cardColor,
              margin: EdgeInsets.only(top: 15.0),
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 0.0,
                  ),
                  // 给软件评分
                  ListTile(
                    leading: Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    title: Text(MyLocalizations.of(context).titleToRate),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                    onTap: () {
                      Fluttertoast.showToast(msg: '上架后可用～');
                      // LaunchReview.launch(); // todo 配置信息
                    },
                  ),
                  Divider(
                    height: 0.0,
                    indent: 20.0,
                  ),
                  // 推荐给朋友
                  ListTile(
                    leading: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    title: Text(MyLocalizations.of(context).titleRecommend),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                    onTap: () {
                      Share.share('V2LF - A new way to explore  https://testflight.apple.com/join/cvx4MQuh'); // todo 配置信息
                    },
                  ),
                  Divider(
                    height: 0.0,
                  ),
                ],
              ),
            ),
            // 意见反馈
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              color: Theme.of(context).cardColor,
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 0.0,
                  ),
                  ListTile(
                    leading: Icon(Icons.rate_review),
                    title: new Text(MyLocalizations.of(context).feedback),
                    onTap: () {
                      if (Platform.isIOS) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => SimpleDialog(
                                  title: Text('您的反馈我会认真考虑'),
                                  children: <Widget>[
                                    SimpleDialogOption(
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.alternate_email),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text('Email'),
                                          ),
                                        ],
                                      ),
                                      onPressed: () => _launchURL(
                                          "mailto:mxl1989@gmail.com?subject=V2LF%20Feedback&body=New%20feedback"),
                                    ),
                                    SimpleDialogOption(
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.message),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text('iMessage'),
                                          ),
                                        ],
                                      ),
                                      onPressed: () => _launchURL("sms:745871698@qq.com&body=New%20feedback"),
                                    )
                                  ],
                                ));
                      } else if (Platform.isAndroid) {
                        _launchURL("mailto:mxl1989@gmail.com?subject=V2LF%20Feedback&body=New%20feedback");
                      }
                    },
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                  ),
                  Divider(
                    height: 0.0,
                  ),
                ],
              ),
            ),
            // 更新记录
            Container(
              margin: const EdgeInsets.only(top: 15.0, bottom: 24.0),
              color: Theme.of(context).cardColor,
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 0.0,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.flag,
                    ),
                    title: new Text(MyLocalizations.of(context).versions),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WhatsNewPage.changelog(
                                title: Text(
                                  "What's New",
                                  textScaleFactor: 1.2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    // Text Style Needed to Look like iOS 11
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                buttonText: Text(
                                  'Close',
                                  //textScaleFactor: textScaleFactor,
                                  style: TextStyle(color: Colors.white),
                                ),
                                buttonColor: Theme.of(context).accentColor,
                              ),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                  ),
                  Divider(
                    height: 0.0,
                  ),
                ],
              ),
            ),
            // 退出登录
            Offstage(
              offstage: !SpHelper.sp.containsKey(SP_USERNAME),
              child: GestureDetector(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 40.0),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: <Widget>[
                      Divider(
                        height: 0.0,
                      ),
                      Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            MyLocalizations.of(context).logoutLong,
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          )),
                      Divider(
                        height: 0.0,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // ⏏ 确认对话框
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            content: Text(MyLocalizations.of(context).sureLogout),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(MyLocalizations.of(context).cancel),
                                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                              ),
                              FlatButton(
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true).pop();
                                    await V2exClient.logout();
                                    Navigator.pop(context);
                                  },
                                  child: Text(MyLocalizations.of(context).logout)),
                            ],
                          ));
                },
              ),
            ),
            /*Center(
              child: Flame.util.animationAsWidget(
                  Position(256.0, 256.0), animation.Animation.sequenced('minotaur.png', 19, textureWidth: 96.0)),
            ),*/
          ],
        ),
      ),
    );
  }

  void updateLanguage(LanguageModel model) {
    _currentLanguage = model;
    _updateData();
    SpHelper.putObject(KEY_LANGUAGE, _currentLanguage.languageCode.isEmpty ? null : _currentLanguage);
    eventBus.fire(new MyEventSettingChange());
  }
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Fluttertoast.showToast(msg: '您似乎没在手机上安装邮件客户端 ?', gravity: ToastGravity.CENTER);
  }
}
