import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/components/circle_avatar.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/models/web/item_notification.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_profile.dart';
import 'package:flutter_app/pages/page_topic_detail.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:flutter_app/utils/url_helper.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

// 通知列表页面
class NotificationsListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<NotificationsListView> with AutomaticKeepAliveClientMixin {
  int p = 1;
  int maxPage = 1;

  bool isLoading = false;
  bool empty = false;
  List<NotificationItem> items = new List();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    // 获取数据
    getTopics();
    // 监听是否滑到了页面底部
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("加载更多...");
        if (items.length > 0 && p <= maxPage) {
          getTopics();
        } else {
          print("没有更多...");
          HapticFeedback.heavyImpact(); // 震动反馈
        }
      }
    });
  }

  Future getTopics() async {
    if (!isLoading) {
      isLoading = true;
      List<NotificationItem> newEntries = await DioWeb.getNotifications(p++);
      setState(() {
        isLoading = false;
        if (newEntries.length > 0) {
          items.addAll(newEntries);
          maxPage = newEntries[0].maxPage;
        } else {
          empty = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.length > 0) {
      return new RefreshIndicator(
          child: Container(
            child: ListView.builder(
                controller: _scrollController,
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    // 滑到了最后一个item
                    return _buildLoadText();
                  } else {
                    return new TopicItemView(items[index]);
                  }
                }),
          ),
          onRefresh: _onRefresh);
    } else if (empty == true) {
      // 空视图
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 128.0,
            height: 114.0,
            margin: EdgeInsets.only(bottom: 30),
            child: FlareActor("assets/Broken Heart.flr", animation: "Heart Break", shouldClip: false)),
        Container(
          margin: EdgeInsets.only(bottom: 114),
          width: 250,
          child: Text("No Notifications Yet!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black.withOpacity(0.65),
              )),
        ),
      ]);
    }
    // By default, show a loading spinner
    return new Center(
      child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
    );
  }

  Widget _buildLoadText() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      child: Center(
        child: Text(p <= maxPage ? S.of(context).loadingPage(p.toString()) : "---- 🙄 ----"),
      ),
    );
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    print("刷新数据...");
    p = 1;
    List<NotificationItem> newEntries = await DioWeb.getNotifications(p);
    setState(() {
      items.clear();
      items.addAll(newEntries);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}

/// notification item view
class TopicItemView extends StatelessWidget {
  final NotificationItem notificationItem;

  TopicItemView(this.notificationItem);

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(notificationItem.topicId)),
        );
      },
      child: new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(12.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // 圆形头像
                        Container(
                          margin: const EdgeInsets.only(right: 6.0),
                          child: CircleAvatarWithPlaceholder(
                            imageUrl: notificationItem.avatar,
                            size: 21,
                          ),
                        ),
                        Text(
                          notificationItem.userName,
                          style: TextStyle(fontSize: 14),
                        ),
                        // 20天前
                        Expanded(
                          child: Text(
                            notificationItem.date,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(notificationItem.userName, Utils.avatarLarge(notificationItem.avatar)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // title
                      new Container(
                        alignment: Alignment.centerLeft,
                        child: Html(
                          data: notificationItem.title,
                          defaultTextStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 13.0),
                          linkStyle: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                          onLinkTap: (url) { // todo
                            if (UrlHelper.canLaunchInApp(context, url)) {
                              return;
                            } else if (url.contains("/member/")) {
                              // @xxx 需要补齐 base url
                              url = Strings.v2exHost + url;
                              print(url);
                            }
                            _launchURL(url);
                          },
                        ),
                      ),
                      // reply
                      Offstage(
                        offstage: notificationItem.reply.isEmpty,
                        child: new Container(
                          margin: const EdgeInsets.only(top: 8.0),
                          child: Html(
                            data: notificationItem.reply,
                            defaultTextStyle: TextStyle(fontSize: 15.0),
                            backgroundColor: Theme.of(context).hoverColor,
                            padding: EdgeInsets.all(4.0),
                            linkStyle: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                            onLinkTap: (url) { // todo
                              if (UrlHelper.canLaunchInApp(context, url)) {
                                return;
                              } else if (url.contains("/member/")) {
                                // @xxx 需要补齐 base url
                                url = Strings.v2exHost + url;
                                print(url);
                              }
                              _launchURL(url);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            new Divider(
              height: 6.0,
            )
          ],
        ),
      ),
    );
  }
}

// 外链跳转
_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, statusBarBrightness: Platform.isIOS ? Brightness.light : null);
  } else {
    Fluttertoast.showToast(msg: 'Could not launch $url', toastLength: Toast.LENGTH_SHORT, timeInSecForIos: 1, gravity: ToastGravity.CENTER);
  }
}
