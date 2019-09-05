import 'package:cached_network_image/cached_network_image.dart';

/// @author: wml
/// @date  : 2019-09-05 18:01
/// @email : mxl1989@gmail.com
/// @desc  : 用户个人信息页面

// 没登录
// 登录

import 'package:flutter/material.dart';
import 'package:flutter_app/theme/theme_data.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [MyTheme.appMainColor.shade300, MyTheme.appMainColor.shade500]),
            ),
          ),
          ListView.builder(
            itemBuilder: _mainListBuilder,
            itemCount: 1,
          ),
        ],
      ),
    );
  }

  Widget _mainListBuilder(BuildContext context, int index) {
    if (index == 0) return _buildHeader(context);
  }

  // 头像区域
  Container _buildHeader(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          // avatar
          CircleAvatar(
            backgroundImage:
                CachedNetworkImageProvider('https://cdn.v2ex.com/gravatar/bf07a96ee6f886e82c49f081f87b2c25?s=73&d=retro'),
          ),
        ],
      ),
    );
  }
}
