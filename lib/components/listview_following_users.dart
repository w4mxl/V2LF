import 'dart:io';

import 'package:flutter/cupertino.dart';
/// @author: wml
/// @date  : 2019-11-04 18:30
/// @email : mxl1989@gmail.com
/// @desc  : 我关注的人

import 'package:flutter/material.dart';
import 'package:flutter_app/components/circle_avatar.dart';
import 'package:flutter_app/models/web/item_following_user.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_profile.dart';

class FollowingUsersListView extends StatefulWidget {
  @override
  _FollowingUsersListViewState createState() => _FollowingUsersListViewState();
}

class _FollowingUsersListViewState extends State<FollowingUsersListView> with AutomaticKeepAliveClientMixin {
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
    super.build(context);
    return FutureBuilder<List<FollowingUser>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            return ListView.separated(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Hero(
                      tag: 'avatar$index',
                      child: CircleAvatarWithPlaceholder(
                        imageUrl: snapshot.data[index].avatar,
                        size: 40,
                      )),
                  title: Text(snapshot.data[index].userName),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                snapshot.data[index].userName,
                                snapshot.data[index].avatar,
                                heroTag: 'avatar$index',
                              ))),
                );
              },
              separatorBuilder: (context, index) => Divider(height: 0),
            );
          } else {
            return Center(
              child: Text('暂无数据'),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text('遇到未知错误'),
          );
        }
        return Center(
          child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
