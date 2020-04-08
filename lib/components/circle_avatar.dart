import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 2019/11/6 16:48
/// 带占位图的圆形头像
class CircleAvatarWithPlaceholder extends StatelessWidget {
  final String imageUrl;
  final double size;

  const CircleAvatarWithPlaceholder({Key key, this.imageUrl, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: size,
        width: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset(
          'assets/images/ic_person.png',
          width: size,
          height: size,
          color: Colors.grey,
        ),
      ),
    );
  }
}
