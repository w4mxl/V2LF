import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/v2ex_client.dart';
import 'package:flutter_app/components/switch_list_tile_cupertino.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/pages/page_reorderable_tabs.dart';
import 'package:flutter_app/states/model_display.dart';
import 'package:flutter_app/states/model_locale.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_whatsnew/flutter_whatsnew.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

// 设置页面
class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  ThemeMode _currentAppearance = SpHelper.getThemeMode(); // 当前外观
  Locale _currentLocale = SpHelper.getLocale();
  bool _switchAutoAward = true; // 是否自动签到；默认是

  @override
  void initState() {
    super.initState();

    bool _spAutoAward = SpHelper.sp.getBool(SP_AUTO_AWARD);
    if (_spAutoAward != null) {
      _switchAutoAward = _spAutoAward;
    }
    print("wml:" + _spAutoAward.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).titleSetting),
        actions: <Widget>[
          // 退出登录
          Offstage(
            offstage: !SpHelper.sp.containsKey(SP_USERNAME),
            child: FlatButton(
              onPressed: () {
                // ⏏ 确认对话框
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          content: Text(S.of(context).sureLogout),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(S.of(context).cancel),
                              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                            ),
                            FlatButton(
                                onPressed: () async {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  await V2exClient.logout();
                                  Navigator.pop(context);
                                },
                                child: Text(S.of(context).logout)),
                          ],
                        ));
              },
              child: Text(
                S.of(context).logout,
                semanticsLabel: 'logout',
                style: Theme.of(context).primaryTextTheme.title.copyWith(fontSize: 18),
              ),
            ),
          )
        ],
      ),
      body: Container(
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
                    title: Text(S.of(context).titlePersonalityHome),
                    subtitle: Text(
                      S.of(context).hintPersonalityHome,
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
                    leading: Icon(Icons.color_lens, color: ListTileTheme.of(context).iconColor),
                    title: Row(
                      children: <Widget>[
                        Text(S.of(context).titleTheme),
                        Expanded(
                          child: Text(
                            SpHelper.getThemeColor(),
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    children: <Widget>[
                      Wrap(
                        children: themeColorMap.keys.map((key) {
                          Color value = themeColorMap[key];
                          return new InkWell(
                            onTap: () {
                              Provider.of<DisplayModel>(context).switchColor(key);
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
                  // Dark mode
                  _appAppearanceTile(context),
                  Divider(
                    height: 0.0,
                    indent: 20.0,
                  ),
                  // 字体切换
                  Platform.isIOS
                      ? CupertinoSwitchListTile(
                          value: SpHelper.getFontFamily() == 'System',
                          onChanged: (value) {
                            buildSwitchFontSetState(value, context);
                          },
                          title: Text(S.of(context).titleSystemFont),
                          secondary: Icon(
                            Icons.font_download,
                          ),
                          selected: false,
                          activeColor: Theme.of(context).accentColor,
                        )
                      : SwitchListTile(
                          value: SpHelper.getFontFamily() == 'System',
                          onChanged: (value) {
                            buildSwitchFontSetState(value, context);
                          },
                          title: Text(S.of(context).titleSystemFont),
                          secondary: Icon(
                            Icons.font_download,
                          ),
                          selected: false,
                        ),
                  Divider(
                    height: 0.0,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              color: Theme.of(context).cardColor,
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 0.0,
                  ),
                  // 多语言设置
                  ExpansionTile(
                    leading: Icon(
                      Icons.language,
                    ),
                    title: Row(
                      children: <Widget>[
                        Text(S.of(context).titleLanguage),
                        Expanded(
                          child: Text(
                            _currentLocale == null
                                ? S.of(context).followSystem
                                : (_currentLocale.languageCode == LOCALE_ZH ? '简体中文' : 'English'),
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    children: <Widget>[
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return RadioListTile(
                              title: Text(
                                index == 0 ? S.of(context).followSystem : (index == 1 ? '简体中文' : 'English'),
                                style: TextStyle(fontSize: 14.0),
                              ),
                              value: index == 0 ? null : (index == 1 ? Locale('zh', 'CN') : Locale('en')),
                              groupValue: _currentLocale,
                              onChanged: (newValue) {
                                setState(() {
                                  _currentLocale = newValue;
                                  Provider.of<LocaleModel>(context).switchLocale(newValue);
                                });
                              },
                              controlAffinity: ListTileControlAffinity.trailing,
                            );
                          }),
                    ],
                  ),
                  Divider(
                    height: 0.0,
                    indent: 20.0,
                  ),
                  // 自动签到
                  Platform.isIOS
                      ? CupertinoSwitchListTile(
                          value: _switchAutoAward,
                          onChanged: (value) {
                            setState(() {
                              _switchAutoAward = value;
                              SpHelper.sp.setBool(SP_AUTO_AWARD, value);
                            });
                          },
                          title: Text(S.of(context).titleAutoAward),
                          secondary: Icon(
                            Icons.monetization_on,
                          ),
                          selected: false,
                          activeColor: Theme.of(context).accentColor,
                        )
                      : SwitchListTile(
                          value: _switchAutoAward,
                          onChanged: (value) {
                            setState(() {
                              _switchAutoAward = value;
                              SpHelper.sp.setBool(SP_AUTO_AWARD, value);
                            });
                          },
                          title: Text(S.of(context).titleAutoAward),
                          secondary: Icon(
                            Icons.monetization_on,
                          ),
                          selected: false,
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
                    ),
                    title: Text(S.of(context).titleToRate),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                    onTap: () {
                      // Fluttertoast.showToast(msg: '上架后可用～', timeInSecForIos: 2,gravity: ToastGravity.CENTER);
                      LaunchReview.launch(androidAppId: 'io.github.w4mxl.v2lf', iOSAppId: '1455778208'); // todo 配置信息
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
                    ),
                    title: Text(S.of(context).titleRecommend),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                    onTap: () {
                      Share.share('V2LF - A new way to explore v2ex!  ${Strings.storeUrl}'); // todo 配置信息
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
                    leading: Icon(
                      Icons.alternate_email,
                    ),
                    title: new Text(S.of(context).feedback),
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
                    title: new Text(S.of(context).versions),
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
            /*Center(
              child: Flame.util.animationAsWidget(
                  Position(256.0, 256.0), animation.Animation.sequenced('minotaur.png', 19, textureWidth: 96.0)),
            ),*/
          ],
        ),
      ),
    );
  }

  void buildSwitchFontSetState(bool value, BuildContext context) {
    return setState(() {
      if (value) {
        Provider.of<DisplayModel>(context).switchFont('System');
      } else {
        Provider.of<DisplayModel>(context).switchFont('Whitney');
      }
    });
  }

  Widget _appAppearanceTile(BuildContext context) {
    return Platform.isIOS
        ? (int.parse(Utils.iosInfo.systemVersion.split('.')[0]) < 13
            ? CupertinoSwitchListTile(
                value: _currentAppearance == ThemeMode.dark,
                onChanged: (newValue) {
                  appearanceSwitchApply(newValue);
                },
                title: Text(S.of(context).darkMode),
                secondary: Icon(
                  Icons.brightness_4,
                ),
                selected: false,
                activeColor: Theme.of(context).accentColor,
              )
            : expansionTileAppearance(context))
        : (Utils.androidInfo.version.sdkInt < 29
            ? SwitchListTile(
                value: _currentAppearance == ThemeMode.dark,
                onChanged: (newValue) {
                  appearanceSwitchApply(newValue);
                },
                title: Text(S.of(context).darkMode),
                secondary: Icon(
                  Icons.brightness_4,
                ),
                selected: false,
              )
            : expansionTileAppearance(context));
  }

  ExpansionTile expansionTileAppearance(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.brightness_4),
      title: Row(
        children: <Widget>[
          Text(S.of(context).titleAppearance),
          Expanded(
            child: Text(
              _currentAppearance == ThemeMode.system
                  ? S.of(context).followSystem
                  : (_currentAppearance == ThemeMode.light ? S.of(context).day : S.of(context).night),
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
      children: <Widget>[
        // * Light
        // * Dark
        // * System default (the recommended default option)
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return RadioListTile(
              title: Text(index == 0 ? S.of(context).followSystem : (index == 1 ? S.of(context).day : S.of(context).night),
                  style: TextStyle(fontSize: 14.0)),
              value: index == 0 ? ThemeMode.system : (index == 1 ? ThemeMode.light : ThemeMode.dark),
              groupValue: _currentAppearance,
              onChanged: (newValue) {
                setState(() {
                  _currentAppearance = newValue;
                  Provider.of<DisplayModel>(context).switchThemeMode(newValue);
                });
              },
              controlAffinity: ListTileControlAffinity.trailing,
            );
          },
        ),
      ],
    );
  }

  void appearanceSwitchApply(bool value) {
    setState(() {
      _currentAppearance = value ? ThemeMode.dark : ThemeMode.light;
      Provider.of<DisplayModel>(context).switchThemeMode(_currentAppearance);
    });
  }
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Fluttertoast.showToast(msg: '您似乎没在手机上安装邮件客户端 ?', gravity: ToastGravity.CENTER);
  }
}
