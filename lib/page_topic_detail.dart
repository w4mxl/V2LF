// 话题详情页+评论列表

import 'package:flutter/material.dart';
import 'package:flutter_app/model/resp_topics.dart';
import 'package:flutter_app/model/web/item_topic_reply.dart';
import 'package:flutter_app/network/api_network.dart';
import 'package:flutter_app/network/api_web.dart';
import 'package:flutter_app/utils/time_base.dart';
import 'package:flutter_html_view/flutter_html_text.dart';
import "package:flutter_markdown/flutter_markdown.dart";
import 'package:url_launcher/url_launcher.dart';

class TopicDetails extends StatelessWidget {
  //final TabTopicItem topic;
  final int topicId;

  TopicDetails(this.topicId);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(),
      body: new Container(
        color: const Color(0xFFD8D2D1),
        child: new ListView(
          children: <Widget>[
            /// topic content
            new TopicContentView(topicId),

            /// topic replies
            new RepliesView(topicId),
          ],
        ),
      ),
    );
  }
}

class TopicContentView extends StatelessWidget {
  final int topicId;

  TopicContentView(this.topicId);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new FutureBuilder<TopicsResp>(
          future: NetworkApi.getTopicDetails(topicId),
          builder: (context, result) {
            if (result.hasData) {
              return new Card(
                margin: const EdgeInsets.all(8.0),
                color: Colors.white,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                image: new NetworkImage(
                                    'https:' + result.data.list[0].member.avatar_large),
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Column(
                            children: <Widget>[
                              new Container(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                child: new Row(
                                  children: <Widget>[
                                    new Text(
                                      result.data.list[0].member.username,
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
                                      result.data.list[0].node.title,
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
                                    Icons.keyboard,
                                    size: 16.0,
                                    color: Colors.grey[500],
                                  ),
                                  new Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: new Text(
                                        new TimeBase(result.data.list[0].last_modified)
                                            .getShowTime(), // todo:   + "，100次点击"
                                        style:
                                            new TextStyle(fontSize: 12.0, color: Colors.grey[500]),
                                      ))
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
                              result.data.list[0].replies.toString(),
                              style: new TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                            ),
                          )
                        ],
                      ),
                    ),
                    // topic title
                    new Container(
                      padding:
                          const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 5.0, right: 10.0),
                      width: 500.0,
                      child: new Text(
                        result.data.list[0].title,
                        softWrap: true,
                        style: new TextStyle(
                          color: Colors.black87,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // topic content
                    new Container(
                      padding:
                          const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                      child: MarkdownBody(
                          data: result.data.list[0].content, onTapLink: (href) => _launchURL(href)),
                      /*child: new Text(
                        result.data.list[0].content,
                        softWrap: true,
                        style: new TextStyle(color: Colors.black87, fontSize: 14.0),
                      ),*/
                    ),
                  ],
                ),
              );
            }

            return new Container(width: 0.0, height: 0.0);
          }),
    );
  }
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class RepliesView extends StatelessWidget {
  final int topicId;

  RepliesView(this.topicId);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new FutureBuilder<List<ReplyItem>>(
          future: v2exApi.parseTopicReplies(topicId.toString()),
          builder: (context, result) {
            if (result.hasData) {
              // 返回数据为空
              if (result.data.length == 0) {
                return new Center(
                  child: new Text("目前尚无回复",
                      style: new TextStyle(color: const Color.fromRGBO(0, 0, 0, 0.25))),
                );
              }
              return new Card(
                margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                color: Colors.white,
                child: new Column(
                  children: result.data.map((ReplyItem reply) {
                    //print(reply.content.toString());
                    return new Container(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            width: 25.0,
                            height: 25.0,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: new NetworkImage(
                                  'https:' + reply.avatar,
                                ),
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Row(
                                  children: <Widget>[
                                    new Text(
                                      reply.userName,
                                      style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    new Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: new Text(
                                        reply.lastReplyTime,
                                        //new TimeBase(reply.last_modified).getShowTime(),
                                        style: new TextStyle(
                                          color: const Color(0xFFcccccc),
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Container(
                                  padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                                  child: HtmlText(
                                    data: reply.content,
                                    onLaunchFail: (url) {
                                      print("launch $url failed");
                                    },
                                  )
                                      /*new Text(
                                    reply.content.toString(),
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                    style: new TextStyle(fontSize: 14.0, color: Colors.black),
                                  )*/
                                      ,
                                ),
                                new Container(
                                  width: 300.0,
                                  height: 0.2,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
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
