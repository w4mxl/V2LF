/// @author: wml
/// @date  : 2019-11-04 18:30
/// @email : mxl1989@gmail.com
/// @desc  : 我关注的人

import 'package:flutter/material.dart';
import 'package:flutter_app/models/web/item_following_user.dart';
import 'package:flutter_app/network/dio_web.dart';

class FollowingUsersListView extends StatefulWidget {
  @override
  _FollowingUsersListViewState createState() => _FollowingUsersListViewState();
}

class _FollowingUsersListViewState extends State<FollowingUsersListView> {
  Future<List<FollowingUser>> _future;
  Future<List<FollowingUser>> getFollowingUsers() async {
    return await DioWeb.getFollowingUsers();
  }

  @override
  void initState() {
    super.initState();

    _future = getFollowingUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
