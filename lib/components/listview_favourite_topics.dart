// 收藏 listview
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/web/item_fav_topic.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/page_topic_detail.dart';
import 'package:flutter_app/theme/theme_data.dart';

class FavTopicListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<FavTopicListView> with AutomaticKeepAliveClientMixin {
  int p = 1;
  int maxPage = 1;

  bool isLoading = false; // 正在请求的过程中多次下拉或上拉会造成多次加载更多的情况，通过这个字段解决
  bool empty = false;
  List<FavTopicItem> items = new List();

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
    if (!isLoading) {
      isLoading = true;
      List<FavTopicItem> newEntries = await DioWeb.getFavTopics(p++);
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
            color: MyTheme.isDark ? Colors.black : CupertinoColors.lightBackgroundGray,
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
          padding: EdgeInsets.only(bottom: 20),
          width: 250,
          child: Text("No Favorites Yet!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black.withOpacity(0.65),
              )),
        ),
        Container(
          width: 270,
          margin: EdgeInsets.only(bottom: 114),
          child: Text("Browse to a topic and tap on the star icon to save something in this list.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, height: 1.1, color: Colors.black.withOpacity(0.65))),
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
        child: Text(p <= maxPage ? MyLocalizations.of(context).loadingPage(p.toString()) : "---- 🙄 ----"),
      ),
    );
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    print("刷新数据...");
    p = 1;
    List<FavTopicItem> newEntries = await DioWeb.getFavTopics(p);
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

/// topic item view
class TopicItemView extends StatelessWidget {
  final FavTopicItem topic;

  TopicItemView(this.topic);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(topic.topicId)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(12.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /// title
                              new Container(
                                alignment: Alignment.centerLeft,
                                child: new Text(
                                  topic.topicTitle,
                                  style: new TextStyle(fontSize: 16.0, color: MyTheme.isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              new Container(
                                margin: const EdgeInsets.only(top: 5.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: new Row(
                                    children: <Widget>[
                                      Material(
                                        color: MyTheme.appMainColor[200],
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                        child: new Container(
                                          padding: const EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
                                          alignment: Alignment.center,
                                          child: new Text(
                                            topic.nodeName,
                                            style: new TextStyle(fontSize: 12.0, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      /*new Text(
                                        " • ",
                                        style: new TextStyle(
                                          fontSize: 12.0,
                                          color: const Color(0xffcccccc),
                                        ),
                                      ),*/
                                      // 圆形头像
                                      new Container(
                                        margin: const EdgeInsets.only(left: 6.0, right: 4.0),
                                        width: 20.0,
                                        height: 20.0,
                                        child: CircleAvatar(
                                          backgroundImage: CachedNetworkImageProvider("https:${topic.avatar}"),
                                        ),
                                      ),
                                      new Text(
                                        topic.memberId,
                                        style: new TextStyle(
                                          fontSize: 12.0,
                                          color: MyTheme.isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                      new Text(
                                        '${topic.lastReplyTime}• ',
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        style: new TextStyle(
                                          fontSize: 12.0,
                                          color: const Color(0xffcccccc),
                                        ),
                                      ),
                                      new Text(
                                        topic.lastReplyMId,
                                        style: new TextStyle(
                                          fontSize: 12.0,
                                          color: MyTheme.isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    Offstage(
                      offstage: topic.replyCount == '0',
                      child: Material(
                        color: MyTheme.appMainColor[400],
                        shape: new StadiumBorder(),
                        child: new Container(
                          width: 35.0,
                          height: 20.0,
                          alignment: Alignment.center,
                          child: new Text(
                            topic.replyCount,
                            style: new TextStyle(fontSize: 12.0, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
