import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/bubble_tab_indicator.dart';
import 'package:flutter_app/utils/url_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:ovprogresshud/progresshud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webfeed/webfeed.dart';

/// @author: wml
/// @date  : 2019-05-21 11:41
/// @email : mxl1989@gmail.com
/// @desc  : 用商品分类页的方式显示往期热门话题

class HistoryHotCategory extends StatefulWidget {
  @override
  _HistoryHotCategoryState createState() => _HistoryHotCategoryState();
}

class _HistoryHotCategoryState extends State<HistoryHotCategory> with AutomaticKeepAliveClientMixin {
  final List<Tab> tabs = <Tab>[
    new Tab(text: "最热"),
    new Tab(text: "最热"),
    new Tab(text: "最热"),
    new Tab(text: "最热"),
  ];

  Future<AtomFeed> _future;

  @override
  void initState() {
    super.initState();
    _future = getFeed();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
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
          body: buildFutureBuilder(),
        ));
  }

  FutureBuilder<AtomFeed> buildFutureBuilder() {
    return FutureBuilder<AtomFeed>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data.items[0].content);
            return TabBarView(
              children: snapshot.data.items.map((atomItem) {
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Html(
                      data: atomItem.content.replaceFirst('<br />', ''),
                      defaultTextStyle: TextStyle(fontSize: 14),
                      linkStyle: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                      onLinkTap: (url) {
                        if (UrlHelper.canLaunchInApp(context, url)) {
                          return;
                        }
                        _launchURL(url);
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          }
          return Center(
            child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
          );
        });
  }

  Future<AtomFeed> getFeed() async {
    // Atom feed
    Utf8Decoder utf8decoder = Utf8Decoder(); // 需要转码一下，不然中文出现乱码
    return get(
      "https://v2exday.com/allinone.xml",
    ).then((response) {
      return utf8decoder.convert(response.bodyBytes);
    }).then((bodyString) {
      AtomFeed feed = new AtomFeed.parse(bodyString);
      setState(() {
        tabs.clear();
        tabs.add(Tab(text: feed.items[0].title.replaceFirst('-', 'xxx').split('xxx')[1].replaceAll(']V2ex', ' ')));
        tabs.add(Tab(text: feed.items[1].title.replaceFirst('-', 'xxx').split('xxx')[1].replaceAll(']V2ex', ' ')));
        tabs.add(Tab(text: feed.items[2].title.replaceFirst('-', 'xxx').split('xxx')[1].replaceAll(']V2ex', ' ')));
        tabs.add(Tab(text: feed.items[3].title.replaceFirst('-', 'xxx').split('xxx')[1].replaceAll(']V2ex', ' ')));
      });
      return feed;
    });
  }

  @override
  bool get wantKeepAlive => true;
}

// 外链跳转
_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, statusBarBrightness: Platform.isIOS ? Brightness.light : null);
  } else {
    Progresshud.showErrorWithStatus('Could not launch $url');
  }
}
