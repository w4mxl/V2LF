// 收藏 listview
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/item_fav_topic.dart';
import 'package:flutter_app/model/web/item_node_topic.dart';
import 'package:flutter_app/network/api_web.dart';
import 'package:flutter_app/network/dio_singleton.dart';
import 'package:flutter_app/page_topic_detail.dart';
import 'package:flutter_app/resources/colors.dart';

class FavTopicListView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<FavTopicListView> with AutomaticKeepAliveClientMixin {
  int p = 1;
  bool isUpLoading = false;
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
        //getTopics();
      }
    });
  }

  Future getTopics() async {
    if (!isUpLoading) {
      setState(() {
        isUpLoading = true;
      });
    }
    List<FavTopicItem> newEntries = await dioSingleton.getFavTopics(p++);
    print(p);
    setState(() {
      items.addAll(newEntries);
      isUpLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (items.length > 0) {
      return new RefreshIndicator(
          child: Container(
            color: const Color(0xFFD8D2D1),
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
        child: Text("正在加载第" + p.toString() + "页..."),
      ),
    );
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    print("刷新数据...");
    p = 1;
    List<FavTopicItem> newEntries = await dioSingleton.getFavTopics(p);
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
          new MaterialPageRoute(builder: (context) => new TopicDetails(int.parse(topic.topicId))),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        color: Colors.white,
        child: new Container(
          child: new Column(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(14.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Container(
                          margin: const EdgeInsets.only(right: 20.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /// title
                              new Container(
                                alignment: Alignment.centerLeft,
                                child: new Text(
                                  topic.topicTitle,
                                  style: new TextStyle(fontSize: 16.0, color: Colors.black),
                                ),
                              ),
                              new Container(
                                margin: const EdgeInsets.only(top: 5.0),
                                child: new Row(
                                  children: <Widget>[
                                    Material(
                                      color: ColorT.appMainColor[100],
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                      child: new Container(
                                        padding: const EdgeInsets.only(left: 3.0, right: 3.0, top: 2.0, bottom: 2.0),
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
                                      margin: const EdgeInsets.only(left:6.0,right: 4.0),
                                      width: 20.0,
                                      height: 20.0,
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage("https:${topic.avatar}"),
                                      ),
                                    ),
                                    new Text(
                                      topic.memberId,
                                      style: new TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Expanded(
                                      child: new Text(
                                        '${topic.lastReplyTime} • ${topic.lastReplyMId}',
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        style: new TextStyle(
                                          fontSize: 11.0,
                                          color: const Color(0xffcccccc),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                    Offstage(
                      offstage: topic.replyCount == '0',
                      child: Material(
                        color: ColorT.appMainColor[400],
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
