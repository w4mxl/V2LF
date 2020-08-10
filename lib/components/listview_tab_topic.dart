// 话题列表页

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/models/web/item_tab_topic.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_login.dart';
import 'package:flutter_app/pages/page_profile.dart';
import 'package:flutter_app/pages/page_recent_topics.dart';
import 'package:flutter_app/pages/page_topic_detail.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ovprogresshud/progresshud.dart';
import 'package:shimmer/shimmer.dart';

import 'circle_avatar.dart';

class TopicListView extends StatefulWidget {
  final String tabKey;

  TopicListView(this.tabKey);

  @override
  State<StatefulWidget> createState() => TopicListViewState();
}

class TopicListViewState extends State<TopicListView>
    with AutomaticKeepAliveClientMixin {
  Future<List<TabTopicItem>> topicListFuture;

  ScrollController _scrollController;
  bool showToTopBtn = false; //是否显示“返回到顶部”按钮

  @override
  void initState() {
    super.initState();

    // 设置默认操作进度加载背景
    Progresshud.setDefaultMaskTypeBlack();

    // 获取数据
    topicListFuture = getTopics();

    _scrollController = ScrollController();
    // 监听是否滑到了页面底部
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        HapticFeedback.heavyImpact(); // 震动反馈（暗示已经滑到底部了）
      }

      if (_scrollController.offset >= 400 && showToTopBtn == false) {
        setState(() {
          showToTopBtn = true;
        });
      } else if (_scrollController.offset < 400 && showToTopBtn) {
        setState(() {
          showToTopBtn = false;
        });
      }
    });
  }

  Future<List<TabTopicItem>> getTopics() async {
    return await DioWeb.getTopicsByTabKey(widget.tabKey, 0);
  }

  Widget _widgetLoadMore() {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text('»  更多新主题'),
      ),
      onTap: () {
        // https://www.v2ex.com/recent 需要登录后才能查看的
        print(SpHelper.sp.containsKey(SP_USERNAME));
        if (SpHelper.sp.containsKey(SP_USERNAME)) {
          // =》「最近的主题」页面
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => RecentTopicsPage()));
        } else {
          // =》 跳到登录页面
          Progresshud.showInfoWithStatus('你要查看的页面需要先登录');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
              fullscreenDialog: true,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: FutureBuilder<List<TabTopicItem>>(
          future: topicListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return RefreshIndicator(
                  child: snapshot.data.length > 0
                      ? Stack(
                          children: <Widget>[
                            ListView.builder(
                                controller: _scrollController,
                                itemCount: snapshot.data.length + 1, // »  更多新主题
                                itemBuilder: (context, index) {
                                  if (index == snapshot.data.length) {
                                    // 滑到了最后一个itme
                                    return _widgetLoadMore();
                                  } else {
                                    return TopicItemView(snapshot.data[index]);
                                  }
                                }),
                            Visibility(
                                visible: showToTopBtn,
                                child: Positioned(
                                  right: 20,
                                  bottom: 20,
                                  child: FloatingActionButton(
                                      heroTag: null,
                                      child:
                                          Icon(FontAwesomeIcons.angleDoubleUp),
                                      onPressed: () {
                                        _scrollController.animateTo(0,
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.ease);
                                      }),
                                ))
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('暂无数据'),
                          ],
                        ),
                  onRefresh: () {
                    // https://stackoverflow.com/questions/51775098/how-do-i-use-refreshindicator-with-a-futurebuilder-in-flutter
                    setState(() {
                      topicListFuture = getTopics();
                    });
                    return topicListFuture;
                  });
            } else if (snapshot.hasError) {
              print("wmllll:${snapshot.error}");
              return Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(S.of(context).oops),
                    RaisedButton.icon(
                      onPressed: () {
                        Progresshud.show();
                        _onRefresh().then((_) => Progresshud.dismiss());
                      },
                      icon: Icon(Icons.refresh),
                      label: Text(S.of(context).retry),
                    )
                  ],
                ),
              );
            }
            // By default, show a loading skeleton
            return LoadingList();
          }),
    );
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    await Future.delayed(Duration(seconds: 1), () {
      setState(() {
        topicListFuture = getTopics();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

/// topic item view
class TopicItemView extends StatefulWidget {
  final TabTopicItem topic;

  TopicItemView(this.topic);

  @override
  _TopicItemViewState createState() => _TopicItemViewState();
}

class _TopicItemViewState extends State<TopicItemView> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          widget.topic.readStatus = 'read';
        });

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TopicDetails(
                    widget.topic.topicId,
                    topicTitle: widget.topic.topicContent,
                    nodeName: widget.topic.nodeName,
                    createdId: widget.topic.memberId,
                    avatar: widget.topic.avatar,
                    replyCount: widget.topic.replyCount,
                  )),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 18.0, right: 18.0, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.topic.topicContent,
              // 区分：已读 or 未读
              style: TextStyle(
                  fontSize: 17,
                  color:
                      widget.topic.readStatus == 'read' ? Colors.grey : null),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InkWell(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // 头像
                              CircleAvatarWithPlaceholder(
                                imageUrl: widget.topic.avatar,
                                size: 22,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              // 用户名
                              Text(
                                widget.topic.memberId,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Theme.of(context)
                                        .unselectedWidgetColor),
                              ),
                            ],
                          ),
                          onTap: () {
                            var largeAvatar =
                                Utils.avatarLarge(widget.topic.avatar);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                    widget.topic.memberId, largeAvatar),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: 1, bottom: 1, left: 4, right: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.topic.nodeName,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Offstage(
                          offstage: widget.topic.lastReplyTime == '',
                          child: Text(
                            widget.topic.lastReplyTime,
                            style: TextStyle(
                                color: Theme.of(context).disabledColor,
                                fontSize: 12.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Offstage(
                  offstage: widget.topic.replyCount == '',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.comment,
                        size: 14.0,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          widget.topic.replyCount,
                          style: TextStyle(
                              fontSize: 13.0,
                              color: Theme.of(context).unselectedWidgetColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              height: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[300]
                : Colors.black12,
            highlightColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[100]
                : Colors.white70,
            child: Column(
              children: [0, 1, 2, 3, 4, 5, 6]
                  .map((_) => Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              child: Container(
                                width: double.infinity,
                                height: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Row(
                              children: <Widget>[
                                ClipOval(
                                  child: Container(
                                    width: 22.0,
                                    height: 22.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  child: Container(
                                    width: 40.0,
                                    height: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  child: Container(
                                    width: 40.0,
                                    height: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  child: Container(
                                    width: 40.0,
                                    height: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  FontAwesomeIcons.comment,
                                  size: 16.0,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  child: Container(
                                    width: 20.0,
                                    height: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          )),
    );
  }
}
