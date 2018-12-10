// node listview
import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/item_node_topic.dart';
import 'package:flutter_app/network/api_web.dart';

class NodeTopicListView extends StatefulWidget {
  final String tabKey;

  NodeTopicListView(this.tabKey);

  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<NodeTopicListView> with AutomaticKeepAliveClientMixin {
  Future<List<NodeTopicItem>> topicListFuture;

  @override
  void initState() {
    super.initState();
    // 获取数据
    topicListFuture = getTopics();
  }

  Future<List<NodeTopicItem>> getTopics() async {
    return await v2exApi.getNodeTopicsByTabKey(widget.tabKey);
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<NodeTopicItem>>(
        future: topicListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new RefreshIndicator(
                child: new Container(
                    child: new ListView(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        children: snapshot.data.map((NodeTopicItem topic) {
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
  final NodeTopicItem topic;

  TopicItemView(this.topic);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        // todo 跳转详情页面
        /*Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(topic)),
        );*/
      },
      child: new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(5.0),
              child: new Row(
                children: <Widget>[
                  // 头像
                  new Container(
                    margin: const EdgeInsets.only(right: 10.0),
                    width: 24.0,
                    height: 24.0,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(topic.avatar),
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            /// title
                            new Container(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                topic.title,
                                /*maxLines: 2,
                    overflow: TextOverflow.ellipsis,*/
                                style: new TextStyle(fontSize: 16.0, color: const Color(0xff778087)),
                              ),
                            ),
                            new Container(
                              child: new Row(
                                children: <Widget>[
                                  new Text(
                                    topic.memberId,
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    style: new TextStyle(
                                      fontSize: 11.0,
                                      color: const Color(0xffcccccc),
                                    ),
                                  ),
                                  new Text(
                                    ' • ${topic.characters} • ${topic.clickTimes}',
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    style: new TextStyle(
                                      fontSize: 11.0,
                                      color: const Color(0xffcccccc),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                  new Icon(
                    Icons.comment,
                    size: 18.0,
                    color: Colors.grey,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 5.0),
                    child: new Text(
                      topic.replyCount,
                      style: new TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                    ),
                  )
                ],
              ),
            ),
            new Divider(
              height: 5.0,
            )
          ],
        ),
      ),
    );
  }
}
