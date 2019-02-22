import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/item_notification.dart';
import 'package:flutter_app/network/dio_singleton.dart';
import 'package:flutter_app/page_topic_detail.dart';
import 'package:flutter_app/resources/colors.dart';

// 通知 listview
class NotificationsListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<NotificationsListView> with AutomaticKeepAliveClientMixin {
  int p = 1;
  int maxPage = 1;

  bool isUpLoading = false;
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
        }
      }
    });
  }

  Future getTopics() async {
    if (!isUpLoading) {
      setState(() {
        isUpLoading = true;
      });
    }
    List<NotificationItem> newEntries = await dioSingleton.getNotifications(p++);
    print(p);
    setState(() {
      items.addAll(newEntries);
      isUpLoading = false;
      maxPage = newEntries[0].maxPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (items.length > 0) {
      return new RefreshIndicator(
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
          onRefresh: _onRefresh);
    }
    // By default, show a loading spinner
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  Widget _buildLoadText() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      child: Center(
        child: Text(p <= maxPage ? "正在加载第" + p.toString() + "页..." : "---- 🙄 ----"),
      ),
    );
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    print("刷新数据...");
    p = 1;
    List<NotificationItem> newEntries = await dioSingleton.getNotifications(p);
    setState(() {
      items.clear();
      items.addAll(newEntries);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // TODO: implement dispose
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
    return new GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(int.parse(notificationItem.topicId))),
        );
      },
      child: new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(12.0),
              child: new Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      // 圆形头像
                      new Container(
                        margin: const EdgeInsets.only(bottom: 1.0),
                        width: 32.0,
                        height: 32.0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage("https:${notificationItem.avatar}"),
                        ),
                      ),
                      // 20天前
                      new Text(
                        notificationItem.date,
                        style: new TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  new Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            /// title
                            new Container(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                notificationItem.title,
                                style: new TextStyle(fontSize: 16.0, color: Colors.black),
                              ),
                            ),
                            new Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              child: new Text(
                                notificationItem.reply,
                                style: new TextStyle(fontSize: 16.0, color: Colors.black),
                              ),
                            ),
                          ],
                        )),
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
