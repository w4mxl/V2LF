// 话题列表页

import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/TabTopicItem.dart';
import 'package:flutter_app/network/WebApi.dart';

class TopicListView extends StatefulWidget {
  final String tabKey;

  TopicListView(this.tabKey);

  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<TopicListView>
    with AutomaticKeepAliveClientMixin {
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
                    color: const Color(0xFFD8D2D1),
                    child: new ListView(
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
        /* Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(topic)),
        );*/
      },
      child: new Card(
        margin: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
        color: Colors.white,
        child: new Container(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: new Container(
            padding: const EdgeInsets.all(10.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Row(
                      children: <Widget>[
                        new Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(topic.avatar),
                            ),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: new Text(
                            topic.memberId +
                                ' · ' +
                                topic.nodeName +
                                ' · ' +
                                topic.lastReplyTime,
                            //new TimeBase(topic.last_modified).getShowTime(),
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            style: new TextStyle(
                              fontSize: 11.0,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    )),
                    new Icon(
                      Icons.comment,
                      size: 18.0,
                      color: Colors.grey,
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: new Text(
                        topic.replyCount,
                        style: new TextStyle(
                            fontSize: 12.0, color: Colors.grey[700]),
                      ),
                    )
                  ],
                ),

                /// title
                new Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: new Text(
                    topic.topicContent,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(fontSize: 14.0, color: Colors.black),
                  ),
                ),

                /// content
                new Container(
                  alignment: Alignment.centerLeft,
                  child: new Text(
                    topic.content,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style:
                        new TextStyle(fontSize: 12.0, color: Colors.grey[800]),
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
