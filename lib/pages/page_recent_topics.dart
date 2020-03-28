// 「最近的主题」页面，对应v2ex网站的 /recent

import 'package:flutter/material.dart';
import 'package:flutter_app/components/listview_recent.dart';

class RecentTopicsPage extends StatefulWidget {
  @override
  _RecentTopicsPageState createState() => _RecentTopicsPageState();
}

class _RecentTopicsPageState extends State<RecentTopicsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('最近的主题')),
      body: ListViewRecentTopics(),
    );
  }
}
