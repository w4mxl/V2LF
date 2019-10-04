/// @author: wml
/// @date  : 2019-10-04 12:28
/// @email : mxl1989@gmail.com
/// @desc  : 用户的所有回复

import 'package:flutter/material.dart';
import 'package:flutter_app/components/listview_all_replies.dart';
import 'package:flutter_app/components/listview_all_topics.dart';

class UserAllRepliesPage extends StatelessWidget {
  final String userName;

  UserAllRepliesPage(this.userName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userName › 全部回复'),
      ),
      body: AllRepliesListView(userName),
    );
  }
}
