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
    var memberProfileModel = await DioWeb.getMemberProfile("socekin");
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
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _memberProfileModel != null ? _memberProfileModel.userName : '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _memberProfileModel != null
                        ? _memberProfileModel.memberInfo.replaceFirst(' +08:00', '')
                        : '', // 时间 去除+ 08:00;,
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ),
              //titlePadding: EdgeInsets.only(bottom: 60),
              background: Container(
                child: _memberProfileModel != null
                    ? Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: OnlinePersonAction("https:${_memberProfileModel.avatar}", _memberProfileModel.online),
                          ),
                        ],
                      )
                    : Center(
                        child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
                      ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [MyTheme.appMainColor.shade300, MyTheme.appMainColor.shade500]),
                ),
              ),
            ),
          ),
          if (_memberProfileModel != null &&
                  (_memberProfileModel.sign.isNotEmpty ||
                      _memberProfileModel.company.isNotEmpty ||
                      _memberProfileModel.memberIntro.isNotEmpty) ||
              _memberProfileModel.clips != null)
            _buildUserOtherInfo(),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyTabBarDelegate(
              child: TabBar(
                labelColor: Colors.black,
                labelPadding: EdgeInsets.zero,
                controller: this.tabController,
                tabs: <Widget>[
                  Tab(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                      child: Center(child: Text('最近回复')),
                    ),
                  ),
                  Tab(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                      child: Center(child: Text('最近回复')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: this.tabController,
              children: <Widget>[
//                Center(child: Text('Content of Home')),
//                Center(child: Text('Content of Profile')),
                _buildRecentTopicsListView(),
                _buildRecentRepliesListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserOtherInfo() {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  visible: _memberProfileModel.sign.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      children: <Widget>[
                        Text('签名：'),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _memberProfileModel.sign,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_memberProfileModel.company.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      children: <Widget>[
                        Text('公司：'),
                        SizedBox(
                          width: 10,
                        ),
                        Html(
                          shrinkToFit: true,
                          data: _memberProfileModel.company.split(' &nbsp; ')[1],
                        ),
                      ],
                    ),
                  ),
                Visibility(
                  visible: _memberProfileModel.memberIntro.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Text('简介：'),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _memberProfileModel.memberIntro.trimLeft().trimRight(),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_memberProfileModel.clips != null)
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
          ),
          Divider(
            height: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTopicsListView() {
    if (_memberProfileModel != null) {
      if (_memberProfileModel?.topicList == null) {
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
                child: Text("根据 ${_memberProfileModel?.userName} 的设置，主题列表被隐藏",
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
            padding: EdgeInsets.zero,
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
      } else if (_memberProfileModel.topicList?.length == 0) {
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
    }
    // By default, show a loading spinner
    return new Center(
      child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
    );
  }

  Widget _buildRecentRepliesListView() {
    if (_memberProfileModel != null) {
      if (_memberProfileModel.replyList.length > 0) {
        return Container(
          color: MyTheme.isDark ? Colors.black : CupertinoColors.white,
          child: ListView.separated(
            padding: EdgeInsets.zero,
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
    return new Center(
      child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
    );
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
        Material(
          elevation: 8.0,
          shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
          child: CircleAvatar(
            radius: 50.0,
            backgroundImage: CachedNetworkImageProvider(avatarPath),
          ),
        ),
        Positioned(
          top: 12,
          right: 5,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: online ? Colors.greenAccent : Colors.redAccent,
                borderRadius: BorderRadius.circular(6),
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
