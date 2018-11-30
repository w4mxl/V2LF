// 话题详情页+评论列表

import 'package:flutter/material.dart';
import 'package:flutter_app/model/RepliesResp.dart';
import 'package:flutter_app/model/TopicsResp.dart';
import 'package:flutter_app/network/NetworkApi.dart';
import 'package:flutter_app/utils/TimeBase.dart';

class TopicDetails extends StatelessWidget {
  final Topic topic;

  TopicDetails(this.topic);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Topic detils',
      theme: new ThemeData(
        primaryColor: Colors.blueGrey,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(topic.title),
          leading: new GestureDetector(
            onTap: () {
              print('back');
              Navigator.pop(context);
            },
            child: new Icon(Icons.arrow_back),
          ),
        ),
        body: new ListView(
          children: <Widget>[
            /// topic content
            new TopicContentView(topic),

            /// topic replies
            new RepliesView(topic.id),
          ],
        ),
      ),
    );
  }
}

class RepliesView extends StatelessWidget {
  final int topicId;

  RepliesView(this.topicId);

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: new FutureBuilder<RepliesResp>(
          future: NetworkApi.getReplies(topicId),
          builder: (context, result) {
            if (result.hasData) {
              return new Column(
                children: result.data.list.map((Reply reply) {
                  return new Container(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
                    child: new Row(
                      children: <Widget>[
                        new Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(
                                'https:' + reply.member.avatar_large,
                              ),
                            ),
                          ),
                        ),
                        new Container(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: new Column(
                            children: <Widget>[
                              new Container(
                                width: 300.0,
                                child: new Text(
                                  reply.member.username,
                                  style: new TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              new Container(
                                width: 300.0,
                                child: new Text(
                                  reply.content.toString(),
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              new Container(
                                width: 300.0,
                                padding: const EdgeInsets.only(
                                    bottom: 10.0, top: 5.0),
                                child: new Text(
                                  new TimeBase(reply.last_modified)
                                      .getShowTime(),
                                  style: new TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                              new Container(
                                width: 300.0,
                                height: 0.2,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
//            return new Center(
//              child: new Text("${result.error}"),
//            );
            } else if (result.hasError) {
              return new Center(
                child: new Text("${result.error}"),
              );
            }

            return new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Center(
                child: new CircularProgressIndicator(),
              ),
            );
          }),
    );
  }
}

class TopicContentView extends StatelessWidget {
  final Topic topic;

  TopicContentView(this.topic);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          padding: const EdgeInsets.all(10.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 10.0),
                width: 40.0,
                height: 40.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image:
                        new NetworkImage('https:' + topic.member.avatar_large),
                  ),
                ),
              ),
              new Expanded(
                  child: new Column(
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: new Row(
                      children: <Widget>[
                        new Text(
                          topic.member.username,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.black87,
                          ),
                        ),
                        new Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.green,
                          size: 16.0,
                        ),
                        new Text(
                          topic.node.title,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      new Icon(
                        Icons.edit,
                        size: 16.0,
                        color: Colors.grey[500],
                      ),
                      new Text(
                        new TimeBase(topic.last_modified).getShowTime(),
                        style: new TextStyle(
                            fontSize: 12.0, color: Colors.grey[500]),
                      )
                    ],
                  )
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
                  style: new TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                ),
              )
            ],
          ),
        ),
        /*new Container(
          color: Colors.black,
          height: 0.2,
        ),*/
        new Container(
          padding: const EdgeInsets.only(
              left: 10.0, top: 10.0, bottom: 5.0, right: 10.0),
          width: 500.0,
          child: new Text(
            topic.title,
            softWrap: true,
            style: new TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        new Container(
          padding: const EdgeInsets.only(
              left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
          child: new Text(
            topic.content,
            softWrap: true,
            style: new TextStyle(color: Colors.black87, fontSize: 14.0),
          ),
        ),
        new Container(
          color: Colors.black,
          height: 0.2,
        ),
      ],
    );
  }
}
