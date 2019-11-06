// 收藏 listview
import 'dart:async';
import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/components/circle_avatar.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/models/web/item_fav_topic.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_topic_detail.dart';
import 'package:flutter_app/states/model_display.dart';
import 'package:provider/provider.dart';

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
          HapticFeedback.heavyImpact(); // 震动反馈
        }
      }
    });
  }

  Future getTopics() async {
    if (!isLoading) {
      isLoading = true;
      List<FavTopicItem> newEntries = await DioWeb.getTopics('topics', p++);
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
      return RefreshIndicator(
          child: Container(
            //color: MyTheme.isDark ? Colors.black : CupertinoColors.lightBackgroundGray,
            child: ListView.builder(
                controller: _scrollController,
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    // 滑到了最后一个item
                    return _buildLoadText();
                  } else {
                    return TopicItemView(items[index]);
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
    return Center(
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
    List<FavTopicItem> newEntries = await DioWeb.getTopics('topics', p);
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TopicDetails(topic.topicId)),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /// title
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  topic.topicTitle,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(top: 1, bottom: 1, left: 4, right: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Theme.of(context).dividerColor),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          topic.nodeName,
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Theme.of(context).disabledColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // 圆形头像
                                      Container(
                                        margin: const EdgeInsets.only(left: 6.0, right: 4.0),
                                        child: CircleAvatarWithPlaceholder(imageUrl: topic.avatar,size: 20,)
                                      ),
                                      Text(topic.memberId, style: Theme.of(context).textTheme.caption),
                                      Text('${topic.lastReplyTime}',
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          style: Theme.of(context).textTheme.caption),
                                      Text(topic.lastReplyMId, style: Theme.of(context).textTheme.caption),
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
                        color: Provider.of<DisplayModel>(context).materialColor[400],
                        shape: StadiumBorder(),
                        child: Container(
                          width: 35.0,
                          height: 20.0,
                          alignment: Alignment.center,
                          child: Text(
                            topic.replyCount,
                            style: TextStyle(fontSize: 12.0, color: Colors.white),
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
