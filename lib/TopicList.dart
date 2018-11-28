// 话题列表页

import 'package:flutter/material.dart';
import 'package:flutter_app/TopicDetails.dart';
import 'package:flutter_app/model/TopicsResp.dart';
import 'package:flutter_app/network/NetworkApi.dart';
import 'package:flutter_app/utils/TimeBase.dart';

class TopicListView extends StatefulWidget {
  final String tabKey;

  const TopicListView({Key key, this.tabKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends BaseTopicListViewState<TopicListView> {
  @override
  Future<TopicsResp> onRefresh() {
    switch (widget.tabKey) {
      case 'hot':
        return NetworkApi.getHotTopics();
      case 'recent':
        return NetworkApi.getLatestTopics();
      default:
        return null;
    }
  }
}

abstract class BaseTopicListViewState<View extends StatefulWidget>
    extends State<View> with AutomaticKeepAliveClientMixin {
  Future<TopicsResp> data;

  @override
  bool get wantKeepAlive => true;

  Future<Null> _onRefresh() {
    return new Future(() {
      setState(() {
        data = onRefresh();
      });
    });
  }

  Future<TopicsResp> onRefresh();

  @override
  void initState() {
    super.initState();
    data = onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<TopicsResp>(
      future: data,
      builder: (context, result) {
        if (result.hasData) {
          return new RefreshIndicator(
              child: new Container(
                  color: const Color(0xFFD8D2D1),
                  child: new ListView(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      children: result.data.list.map((Topic topic) {
                        return new TopicItemView(topic);
                      }).toList())),
              onRefresh: _onRefresh);
        } else if (result.hasError) {
          return new Center(
            child: new Text("${result.error}"),
          );
        }

        // By default, show a loading spinner
        return new Center(
          child: new CircularProgressIndicator(),
        );
      },
    );
  }
}

/// topic item view
class TopicItemView extends StatelessWidget {
  final Topic topic;

  TopicItemView(this.topic);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(topic)),
        );
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
                              image: new NetworkImage(
                                  'https:' + topic.member.avatar_large),
                            ),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: new Text(
                            topic.member.username +
                                ' · ' +
                                topic.node.title +
                                ' · ' +
                                new TimeBase(topic.last_modified).getShowTime(),
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
                        topic.replies.toString(),
                        style: new TextStyle(
                            fontSize: 11.0, color: Colors.grey[700]),
                      ),
                    )
                  ],
                ),

                /// title
                new Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: new Text(
                    topic.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(fontSize: 14.0, color: Colors.black),
                  ),
                ),

                /// content
                new Container(
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
