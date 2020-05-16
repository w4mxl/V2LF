import 'dart:convert';

/**
 * @author: wml
 * @date  : 2019/3/13 16:25
 * @email : mxl1989@gmail.com
 * @desc  : 首页 Tab 自由配置页
 */

import 'package:flutter/material.dart';
import 'package:flutter_app/models/tab.dart';
import 'package:flutter_app/utils/constants.dart';
import 'package:flutter_app/utils/event_bus.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Adapted from reorderable list demo in offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/reorderable_list_demo.dart
class ReorderableListTabs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReorderableListTabsState();
  }
}

class _ReorderableListTabsState extends State<ReorderableListTabs> {
  List<TabModel> _tabsp = SpHelper.getMainTabs() != null ? SpHelper.getMainTabs() : TABS;
  List<TabModel> _tabs;

  @override
  void initState() {
    super.initState();

    _tabs = _tabsp.sublist(1); // 排除固定的'全部'，保存的时候再加上
  }

  // Handler called by ReorderableListView onReorder after a list child is
  // dropped into a new position.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final TabModel item = _tabs.removeAt(oldIndex);
      _tabs.insert(newIndex, item);
    });
  }

  // todo 考虑添加一个恢复默认排序的操作
  // Handler called when the "sort" button on appbar is clicked.
//  void _onSort() {
//    setState(() {
//      _reverseSort = !_reverseSort;
//      _items.sort((_ListItem a, _ListItem b) => _reverseSort ? b.value.compareTo(a.value) : a.value.compareTo(b.value));
//    });
//  }

  @override
  Widget build(BuildContext context) {
    final _appbar = AppBar(
      title: Text('个性主页'),
      actions: <Widget>[
        MaterialButton(
          onPressed: () async {
            List<Map<String, dynamic>> linkMap = [];

            linkMap.add({
              'title': '全部',
              'key': 'all',
              'checked': true,
            });

            for (var item in _tabs) {
              linkMap.add({
                'title': item.title,
                'key': item.key,
                'checked': item.checked,
              });
            }

            print(json.encode(linkMap));
            bool isSuccess = await SpHelper.sp.setString(KEY_MAIN_TABS, json.encode(linkMap));
            if (isSuccess) {
              eventBus.emit(MyEventTabsChange);
              Navigator.of(context).pop();
            } else {
              Fluttertoast.showToast(msg: '保存出错了...', timeInSecForIosWeb: 2, gravity: ToastGravity.CENTER);
            }
          },
          child: Text(
            '保存',
            style: Theme.of(context).primaryTextTheme.title.copyWith(fontSize: 18),
            semanticsLabel: 'Save',
          ),
        )
      ],
    );

    final _listTiles = _tabs
        .map(
          (item) => CheckboxListTile(
            key: Key(item.key),
            value: item.checked ?? false,
            onChanged: (bool newValue) {
              setState(() => item.checked = newValue);
            },
            title: Text(item.title),
            secondary: Icon(Icons.drag_handle),
          ),
        )
        .toList();
    return Scaffold(
      appBar: _appbar,
      body: ReorderableListView(
        header: CheckboxListTile(
          value: true,
          onChanged: null,
          title: Text('全部'),
          secondary: Icon(Icons.lock_outline),
        ),
        onReorder: _onReorder,
        children: _listTiles,
      ),
    );
  }
}
