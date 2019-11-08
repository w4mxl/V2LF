/// @author: wml
/// @date  : 2019-10-04 12:28
/// @email : mxl1989@gmail.com
/// @desc  : 用户的所有主题

import 'package:flutter/material.dart';
import 'package:flutter_app/components/listview_all_topics.dart';

class UserAllTopicsPage extends StatelessWidget {
  final String userName;
  final String avatar;

  UserAllTopicsPage(this.userName, this.avatar);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userName › 全部主题'),
      ),
      body: AllTopicsListView(userName,avatar),
    );
  }
}
