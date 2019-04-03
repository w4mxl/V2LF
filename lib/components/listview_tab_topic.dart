// 话题列表页

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/web/item_tab_topic.dart';
import 'package:flutter_app/network/api_web.dart';
import 'package:flutter_app/page_topic_detail.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    return new FutureBuilder<List<TabTopicItem>>(
        future: topicListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new RefreshIndicator(
                child: new Container(
//                  color: CupertinoColors.lightBackgroundGray,
                    child: ListView.separated(
                        itemBuilder: (context, index) => TopicItemView(snapshot.data[index]),
                        separatorBuilder: (context, index) => Divider(height: 0,indent: 15,),
                        itemCount: snapshot.data.length)
//                    child: new ListView(
//                        physics: ClampingScrollPhysics(), //正常的滚动效果，没有弹性
//                        padding: const EdgeInsets.only(bottom: 15.0),
//                        children: snapshot.data.map((TabTopicItem topic) {
//                          return new TopicItemView(topic);
//                        }).toList())
                    ),
                onRefresh: _onRefresh);
          } else if (snapshot.hasError) {
            print("${snapshot.error}");
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(MyLocalizations.of(context).oops),
                RaisedButton.icon(
                  onPressed: () {
                    _onRefresh();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text(MyLocalizations.of(context).retry),
                )
              ],
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
          new MaterialPageRoute(builder: (context) => new TopicDetails(topic.topicId)),
        );
      },
      child: new Container(
        padding: const EdgeInsets.all(12.0),
        child: new Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 5.0),
                    child: new Text(
                      topic.topicContent,
                      /*maxLines: 2,
                  overflow: TextOverflow.ellipsis,*/
                      style: new TextStyle(fontSize: 16),
                    ),
                  ),
                  Row(children: <Widget>[
                    new Text(
                      topic.memberId,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: new TextStyle(fontSize: 14.0, color: Colors.black87),
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
                    new Text(
                      topic.lastReplyTime == ''
                          ? MyLocalizations.of(context).noComment
                          : '${topic.lastReplyTime} • 最后回复 ${topic.lastReplyMId}',
                      style: new TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],),
                ],
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // 头像
                ClipOval(
                  child: new CachedNetworkImage(
                    imageUrl: topic.avatar,
                    height: 32.0,
                    width: 32.0,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Icon(Icons.account_circle, size: 32.0, color: Color(0xFFcccccc)),
                  ),
                ),
                SizedBox(width: 10.0),
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
          ],
        ),
      ),
    );
  }
}
