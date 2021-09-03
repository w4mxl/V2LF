// 我的通知列表页面

import 'package:flutter/material.dart';
import 'package:flutter_app/components/listview_notifications.dart';
import 'package:flutter_app/generated/i18n.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).notifications),
      ),
      body: NotificationsListView(),
    );
  }
}
