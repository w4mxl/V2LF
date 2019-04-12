import 'package:flutter/material.dart';
import 'package:flutter_app/components/gridview_favourite_nodes.dart';
import 'package:flutter_app/components/listview_favourite_topics.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:flutter_app/utils/bubble_tab_indicator.dart';

/// @author: wml
/// @date  : 2019/3/30 4:09 PM
/// @email : mxl1989@gmail.com
/// @desc  : 收藏：主题收藏 && 节点收藏

class FavouritePage extends StatefulWidget {
  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> with AutomaticKeepAliveClientMixin {
  final List<Tab> tabs = <Tab>[
    new Tab(text: "主题收藏"),
    new Tab(text: "节点收藏"),
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
//            backgroundColor: Colors.white,
//            iconTheme: IconThemeData(color: Colors.black54),
            centerTitle: true,
            title: TabBar(
                isScrollable: true,
                unselectedLabelColor: ColorT.appMainColor[100],
                labelColor: ColorT.appMainColor,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: new BubbleTabIndicator(
                  indicatorHeight: 30.0,
                  indicatorColor: Colors.white,
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                ),
                tabs: tabs),
          ),
          body: TabBarView(children: [FavTopicListView(), FavouriteNodesGrid()]),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
