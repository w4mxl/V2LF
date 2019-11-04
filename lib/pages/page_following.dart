import 'package:flutter/material.dart';
import 'package:flutter_app/components/bubble_tab_indicator.dart';
import 'package:flutter_app/components/gridview_favourite_nodes.dart';
import 'package:flutter_app/components/listview_favourite_topics.dart';
import 'package:flutter_app/components/listview_following_topics.dart';
import 'package:flutter_app/components/listview_following_users.dart';

/// @author: wml
/// @date  : Mon Nov 4 17:30:46 CST 2019
/// @email : mxl1989@gmail.com
/// @desc  : 特别关注：我关注的人的最新主题 && 我关注的人

class FollowingPage extends StatefulWidget {
  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> with AutomaticKeepAliveClientMixin {
  final List<Tab> tabs = <Tab>[
    new Tab(text: "关注的人的最新主题"),
    new Tab(text: "关注的人"),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: TabBar(
                isScrollable: true,
                indicator: BubbleTabIndicator(
                  indicatorColor: Theme.of(context).primaryColorBrightness == Brightness.dark
                      ? Theme.of(context).focusColor
                      : Colors.white,
                ),
                tabs: tabs),
          ),
          body: TabBarView(children: [FollowTopicListView(), FollowingUsersListView()]),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
