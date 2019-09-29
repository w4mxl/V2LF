import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/item_profile_recent_reply.dart';
import 'package:flutter_app/model/web/item_profile_recent_topic.dart';
import 'package:flutter_app/model/web/model_member_profile.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_topic_detail.dart';
import 'package:flutter_app/theme/theme_data.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:flutter_app/utils/url_helper.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// @author: wml
/// @date  : 2019-09-05 18:01
/// @email : mxl1989@gmail.com
/// @desc  : 用户个人信息页面

// 没登录：他人
// 登录: 本人、他人

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  MemberProfileModel _memberProfileModel;

  TabController tabController;

  @override
  void initState() {
    super.initState();

    this.tabController = TabController(length: 2, vsync: this);

    getData();
  }

  Future getData() async {
    var memberProfileModel = await DioWeb.getMemberProfile("ydatong");
    if (memberProfileModel != null) {
      setState(() {
        _memberProfileModel = memberProfileModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: CustomSliverDelegate(
              expandedHeight: 120,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyTabBarDelegate(
              child: TabBar(
                labelColor: Colors.black,
                controller: this.tabController,
                tabs: <Widget>[
                  Tab(text: 'Home'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: this.tabController,
              children: <Widget>[
                Center(child: Text('Content of Home')),
                Center(child: Text('Content of Profile')),
              ],
            ),
          ),
        ],
      ),
/*      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [MyTheme.appMainColor.shade300, MyTheme.appMainColor.shade500]),
            ),
          ),
          // 左上角返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0.0,
            child: IconTheme(
              data: IconThemeData(color: Colors.white),
              child: SafeArea(
                top: false,
                bottom: false,
                child: IconButton(
                  icon: BackButtonIcon(),
                  tooltip: 'Back',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          _memberProfileModel == null
              ? Center(
                  child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemBuilder: _mainListBuilder,
                  itemCount: 5,
                ),
        ],
      ),*/
    );
  }

  Widget _mainListBuilder(BuildContext context, int index) {
    if (index == 0) return _buildHeader(context);
    if (index == 1) return _buildRecentTopicsHeader(context);
    if (index == 2) return _buildRecentTopicsListView(context);
    if (index == 3) return _buildRecentRepliesHeader(context);
    if (index == 4) return _buildRecentRepliesListView(context);
  }

  Container _buildHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0, bottom: 10.0),
            child: Material(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              elevation: 5.0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50.0,
                    ),
                    Text(
                      _memberProfileModel.userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Visibility(
                      visible: _memberProfileModel.sign.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          _memberProfileModel.sign,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    if (_memberProfileModel.company.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Html(
                          data: _memberProfileModel.company.split(' &nbsp; ')[1],
                          customTextAlign: (node) {
                            return TextAlign.center;
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _memberProfileModel.memberInfo.replaceFirst(' +08:00', ''), // 时间 去除+ 08:00;,
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_memberProfileModel.clips != null)
                      Column(
                        children: <Widget>[
                          Divider(),
                          Wrap(
                            spacing: 8,
                            runSpacing: -5,
                            children: _memberProfileModel.clips.map((Clip clip) {
                              return ActionChip(
                                avatar: CachedNetworkImage(imageUrl: Strings.v2exHost + clip.icon),
                                label: Text(
                                  clip.name,
                                ),
                                backgroundColor: Colors.grey[200],
                                onPressed: () {
                                  Utils.launchURL(clip.url.startsWith('http://www.google.com/maps?q=')
                                      ? 'http://www.google.com/maps?q=' + Uri.encodeComponent(clip.url.split('maps?q=')[1])
                                      : clip.url);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    Visibility(
                      visible: _memberProfileModel.memberIntro.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _memberProfileModel.memberIntro.trimLeft().trimRight(),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OnlinePersonAction("https:${_memberProfileModel.avatar}", _memberProfileModel.online),
            ],
          ),
        ],
      ),
    );
  }

  Container _buildRecentTopicsHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              '最近主题',
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Offstage(
            offstage: _memberProfileModel.topicList == null || _memberProfileModel.topicList.length == 0,
            child: FlatButton(
                onPressed: () {},
                child: Text(
                  '查看所有',
                  style: TextStyle(color: Colors.blue),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTopicsListView(BuildContext context) {
    if (_memberProfileModel.topicList == null) {
      // 根据 xxx 的设置，主题列表被隐藏
      return Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/lock.png',
              width: 128,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(bottom: 20),
              width: 250,
              child: Text("根据 ${_memberProfileModel.userName} 的设置，主题列表被隐藏",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black45,
                  )),
            ),
          ],
        ),
      );
    } else if (_memberProfileModel.topicList.length > 0) {
      return Container(
        color: MyTheme.isDark ? Colors.black : CupertinoColors.white,
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          // 禁用滚动事件
          itemCount: _memberProfileModel.topicList.length,
          itemBuilder: (context, index) {
            return TopicItemView(_memberProfileModel.topicList[index]);
          },
          separatorBuilder: (BuildContext context, int index) => Divider(
            height: 0,
            indent: 12,
            endIndent: 12,
          ),
        ),
      );
    } else if (_memberProfileModel.topicList.length == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${_memberProfileModel.userName} 暂未发布任何主题",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
        ),
      );
    }
    // By default, show a loading spinner
    return new Center(
      child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
    );
  }

  Container _buildRecentRepliesHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              '最近回复',
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Offstage(
            offstage: _memberProfileModel.replyList.length == 0,
            child: FlatButton(
                onPressed: () {},
                child: Text(
                  '查看所有',
                  style: TextStyle(color: Colors.blue),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRepliesListView(BuildContext context) {
    if (_memberProfileModel.replyList.length > 0) {
      return Container(
        color: MyTheme.isDark ? Colors.black : CupertinoColors.white,
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          // 禁用滚动事件
          itemCount: _memberProfileModel.replyList.length,
          itemBuilder: (context, index) {
            return ReplyItemView(_memberProfileModel.replyList[index]);
          },
          separatorBuilder: (BuildContext context, int index) => Divider(
            height: 0,
            indent: 12,
            endIndent: 12,
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${_memberProfileModel.userName} 暂未发布任何回复",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
        ),
      );
    }
  }
}

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final bool hideTitleWhenExpanded;

  CustomSliverDelegate({
    @required this.expandedHeight,
    this.hideTitleWhenExpanded = true,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = expandedHeight - shrinkOffset;
    final cardTopPosition = expandedHeight / 2 - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return SizedBox(
      height: expandedHeight + expandedHeight / 2,
      child: Stack(
        children: [
          SizedBox(
            height: appBarSize < kToolbarHeight ? kToolbarHeight : appBarSize,
            child: AppBar(
              backgroundColor: Colors.green,
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {},
              ),
              elevation: 0.0,
              title: Opacity(opacity: hideTitleWhenExpanded ? 1.0 - percent : 1.0, child: Text("Test")),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            top: cardTopPosition > 0 ? cardTopPosition : 0,
            bottom: 0.0,
            child: Opacity(
              opacity: percent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30 * percent),
                child: Card(
                  elevation: 20.0,
                  child: Center(
                    child: Text("Header"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  StickyTabBarDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

/// 用户是否在线
class OnlinePersonAction extends StatelessWidget {
  final String avatarPath;
  final bool online;

  OnlinePersonAction(this.avatarPath, this.online);

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Material(
            elevation: 8.0,
            shape: CircleBorder(),
            child: CircleAvatar(
              radius: 40.0,
              backgroundImage: CachedNetworkImageProvider(avatarPath),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: online ? Colors.greenAccent : Colors.redAccent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  width: 1,
                  color: Color(0xFFFFFFFF),
                )),
          ),
        )
      ],
    );
  }
}

/// topic item view
class TopicItemView extends StatelessWidget {
  final ProfileRecentTopicItem topic;

  TopicItemView(this.topic);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => TopicDetails(topic.topicId)),
        );
      },
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            /// title
                            Container(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                topic.topicTitle,
                                style: new TextStyle(fontSize: 16.0, color: MyTheme.isDark ? Colors.white : Colors.black),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: new Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(top: 1, bottom: 1, left: 4, right: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Theme.of(context).dividerColor),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        topic.nodeName,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Theme.of(context).disabledColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${topic.lastReplyTime}',
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      style: new TextStyle(
                                        fontSize: 12.0,
                                        color: const Color(0xffcccccc),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                  Offstage(
                    offstage: topic.replyCount == '0',
                    child: Row(
                      children: <Widget>[
                        new Icon(
                          FontAwesomeIcons.comment,
                          size: 14.0,
                          color: Colors.grey,
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: new Text(
                            topic.replyCount,
                            style: new TextStyle(fontSize: 13.0, color: Theme.of(context).unselectedWidgetColor),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// reply item view
class ReplyItemView extends StatelessWidget {
  final ProfileRecentReplyItem reply;

  ReplyItemView(this.reply);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Html(
            data: reply.dockAreaText,
            defaultTextStyle: TextStyle(color: MyTheme.isDark ? Colors.white : Colors.black54, fontSize: 15.0),
            linkStyle: TextStyle(
              color: Theme.of(context).accentColor,
            ),
            onLinkTap: (url) {
              if (UrlHelper.canLaunchInApp(context, url)) {
                return;
              } else if (url.contains("/member/")) {
                // @xxx 需要补齐 base url
                url = Strings.v2exHost + url;
                print(url);
              }
              Utils.launchURL(url);
            },
          ),
          SizedBox(
            height: 5,
          ),
          Html(
            data: reply.replyContent,
            defaultTextStyle: TextStyle(color: MyTheme.isDark ? Colors.white : Colors.black, fontSize: 14.0),
            backgroundColor: MyTheme.isDark ? Colors.grey[800] : Colors.grey[200],
            padding: EdgeInsets.all(4.0),
            linkStyle: TextStyle(
              color: Theme.of(context).accentColor,
            ),
            onLinkTap: (url) {
              if (UrlHelper.canLaunchInApp(context, url)) {
                return;
              } else if (url.contains("/member/")) {
                // @xxx 需要补齐 base url
                url = Strings.v2exHost + url;
                print(url);
              }
              Utils.launchURL(url);
            },
          ),
          SizedBox(
            height: 4,
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: Text(
              reply.replyTime,
              style: new TextStyle(
                fontSize: 12.0,
                color: MyTheme.isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
