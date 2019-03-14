import 'dart:convert';

/**
 * @author: wml
 * @date  : 2019/3/13 16:25
 * @email : mxl1989@gmail.com
 * @desc  : 首页 Tab 自由配置页
 */

import 'package:flutter/material.dart';
import 'package:flutter_app/model/tab.dart';
import 'package:flutter_app/utils/sp_helper.dart';

// Adapted from reorderable list demo in offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/reorderable_list_demo.dart
class ReorderableListTabs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReorderableListTabsState();
  }
}

class _ReorderableListTabsState extends State<ReorderableListTabs> {
  List<TabModel> _tabsSp = SpHelper.getMainTabs();

  // Handler called by ReorderableListView onReorder after a list child is
  // dropped into a new position.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final TabModel item = _tabsSp.removeAt(oldIndex);
      _tabsSp.insert(newIndex, item);
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
      title: Text('自定义主页 TAB'),
      actions: <Widget>[
        MaterialButton(
          onPressed: () {
            List<Map<String, dynamic>> linkMap = [];
            for (var item in _tabsSp) {
              linkMap.add({
                'title': item.title,
                'key': item.key,
                'checked': item.checked,
              });
            }
            print(json.encode(linkMap));
            SpHelper.sp.setString(KEY_MAIN_TABS, json.encode(linkMap));
          },
          child: Text(
            '保存',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
            semanticsLabel: 'Save',
          ),
        )
      ],
    );
    final _listTiles = _tabsSp
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
        onReorder: _onReorder,
        children: _listTiles,
      ),
    );
  }
}
