import 'package:flutter/material.dart';
import 'package:flutter_app/components/bubble_tab_indicator.dart';
import 'package:flutter_app/components/gridview_favourite_nodes.dart';
import 'package:flutter_app/components/listview_favourite_topics.dart';

/// @author: wml
/// @date  : 2019/3/30 4:09 PM
/// @email : mxl1989@gmail.com
/// @desc  : 收藏：主题收藏 && 节点收藏

class FavouritePage extends StatefulWidget {
  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage>
    with AutomaticKeepAliveClientMixin {
  final List<Tab> tabs = <Tab>[
    Tab(text: '主题收藏'),
    Tab(text: '节点收藏'),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: TabBar(
                isScrollable: true,
                indicator: BubbleTabIndicator(
                  indicatorColor: Theme.of(context).primaryColorBrightness ==
                          Brightness.dark
                      ? Theme.of(context).focusColor
                      : Colors.white,
                ),
                tabs: tabs),
          ),
          body:
              TabBarView(children: [FavTopicListView(), FavouriteNodesGrid()]),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
