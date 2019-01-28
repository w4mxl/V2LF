// 话题列表页

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/item_tab_topic.dart';
import 'package:flutter_app/network/api_web.dart';
import 'package:flutter_app/page_topic_detail.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TopicListView extends StatefulWidget {
  final String tabKey;

  TopicListView(this.tabKey);

  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<TopicListView> with AutomaticKeepAliveClientMixin {
  Future<List<TabTopicItem>> topicListFuture;

  @override
  void initState() {
    super.initState();
    // 获取数据
    topicListFuture = getTopics();
  }

  Future<List<TabTopicItem>> getTopics() async {
    return await v2exApi.getTopicsByTabKey(widget.tabKey);
  }

  @override
  Widget build(BuildContext context) {
    Fluttertoast.showToast(msg: "wml: " + Localizations.localeOf(context).toString());
    return new FutureBuilder<List<TabTopicItem>>(
        future: topicListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new RefreshIndicator(
                child: new Container(
                    color: const Color(0xFFD8D2D1),
                    child: new ListView(
                        physics: ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 15.0),
                        children: snapshot.data.map((TabTopicItem topic) {
                          return new TopicItemView(topic);
                        }).toList())),
                onRefresh: _onRefresh);
          } else if (snapshot.hasError) {
            return new Center(
              child: new Text("${snapshot.error}"),
            );
          }

          // By default, show a loading spinner
          return new Center(
            child: new CircularProgressIndicator(),
          );
        });
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    setState(() {
      topicListFuture = getTopics();
    });
  }

  @override
  bool get wantKeepAlive => true;
}

/// topic item view
class TopicItemView extends StatelessWidget {
  final TabTopicItem topic;

  TopicItemView(this.topic);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        // todo 跳转详情页面
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(int.parse(topic.topicId))),
        );
      },
      child: new Card(
        margin: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        color: Colors.white,
        child: new Container(
          child: new Container(
            padding: const EdgeInsets.all(12.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Container(
                      margin: const EdgeInsets.only(right: 10.0),
                      width: 32.0,
                      height: 32.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(topic.avatar),
                        ),
                      ),
                    ),
                    new Expanded(
                        child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          child: new Row(
                            children: <Widget>[
                              new Text(
                                topic.memberId,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                style: new TextStyle(fontSize: 14.0, color: Colors.black87, fontWeight: FontWeight.bold),
                              ),
                              new Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.green,
                                size: 16.0,
                              ),
                              new Text(
                                topic.nodeName,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                style: new TextStyle(fontSize: 14.0, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        new Text(
                          topic.lastReplyTime == '' ? '暂无评论' : '${topic.lastReplyTime} • 最后回复 ${topic.lastReplyMId}',
                          style: new TextStyle(color: Colors.grey, fontSize: 12.0),
                        )
                      ],
                    )),
                    Material(
                      color: ColorT.app_main[400],
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
                    )
                  ],
                ),

                /// title
                new Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 5.0),
                  child: new Text(
                    topic.topicContent,
                    /*maxLines: 2,
                    overflow: TextOverflow.ellipsis,*/
                    style: new TextStyle(fontSize: 15.0, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
