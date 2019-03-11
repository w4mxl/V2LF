// 我的通知列表页面

import 'package:flutter/material.dart';
import 'package:flutter_app/components/listview_notifications.dart';
import 'package:flutter_app/i10n/localization_intl.dart';

class NotificationTopics extends StatefulWidget {
  @override
  _NotificationTopicsState createState() => _NotificationTopicsState();
}

class _NotificationTopicsState extends State<NotificationTopics> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(MyLocalizations.of(context).notifications),
      ),
      body: new NotificationsListView(),
    );
  }
}
