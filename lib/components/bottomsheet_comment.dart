// 评论列表item点击
import 'package:flutter/material.dart';

class BottomSheetComment{

  bottomSheet(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(context, '回复', Icons.reply, _action1),
              _createTile(context, '感谢', Icons.thumb_up, _action2),
              _createTile(context, '查看对话', Icons.forum, _action3),
            ],
          );
        }
    );
  }

  ListTile _createTile(BuildContext context, String name, IconData icon, Function action){
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      onTap: (){
        Navigator.pop(context);
        action();
      },
    );
  }

  _action1(){
    print('action 1');
  }

  _action2(){
    print('action 2');
  }

  _action3(){
    print('action 3');
  }
}