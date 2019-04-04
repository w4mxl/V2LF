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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                    child: ListView.separated(
                        itemBuilder: (context, index) => TopicItemView(snapshot.data[index]),
                        separatorBuilder: (context, index) => Divider(
                              height: 0,
                              indent: 15,
                            ),
                        itemCount: snapshot.data.length)
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
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // todo 跳转详情页面
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(topic.topicId)),
        );
      },
      child: new Container(
        padding: const EdgeInsets.only(left:18.0,right: 18.0,top: 15,bottom: 15),
        child: new Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    topic.topicContent,
                    /*maxLines: 2,
                  overflow: TextOverflow.ellipsis,*/
                    style: new TextStyle(fontSize: 17),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: <Widget>[
                      // 头像
                      ClipOval(
                        child: new CachedNetworkImage(
                          imageUrl: topic.avatar,
                          height: 22.0,
                          width: 22.0,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(Icons.account_circle, size: 22.0, color: Color(0xFFcccccc)),
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        topic.memberId,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        style: new TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w600, color: Theme.of(context).unselectedWidgetColor),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 2, bottom: 2, left: 4, right: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: new Text(
                          topic.nodeName,
                          style: new TextStyle(
                              fontSize: 12.0, color: Theme.of(context).disabledColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Offstage(
                        offstage: topic.lastReplyTime == '',
                        child: Text(
                          " • " + topic.lastReplyTime,
                          style: new TextStyle(color: Theme.of(context).disabledColor, fontSize: 12.0),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: <Widget>[
                          new Icon(
                            FontAwesomeIcons.comment,
                            size: 16.0,
                            color: Colors.grey,
                          ),
                          new Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: new Text(
                              topic.replyCount,
                              style: new TextStyle(fontSize: 14.0, color: Theme.of(context).unselectedWidgetColor),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

//            Offstage(
//              offstage: topic.replyCount == '0',
//              child: Material(
//                color: ColorT.appMainColor[200],
//                shape: new StadiumBorder(),
//                child: new Container(
//                  width: 35.0,
//                  height: 20.0,
//                  alignment: Alignment.center,
//                  child: new Text(
//                    topic.replyCount,
//                    style: new TextStyle(fontSize: 12.0, color: Theme.of(context).cardColor),
//                  ),
//                ),
//              ),
//            ),

          ],
        ),
      ),
    );
  }
}
