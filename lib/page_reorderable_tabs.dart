/**
 * @author: wml
 * @date  : 2019/3/13 16:25
 * @email : mxl1989@gmail.com
 * @desc  : 首页 Tab 自由配置页
 */

import 'package:flutter/material.dart';
import 'package:flutter_app/model/language.dart';
import 'package:flutter_app/model/tab.dart';
import 'dart:convert';

import 'package:flutter_app/utils/sp_helper.dart';

// Adapted from reorderable list demo in offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/reorderable_list_demo.dart
class ReorderableListTabs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReorderableListTabsState();
  }
}

class TabData {
  const TabData({this.title, this.key});

  final String title;
  final String key;
}

class _ListItem {
  _ListItem(this.value, this.checked);

  final TabData value;
  bool checked;
}

//const TabData(title: '技术', key: 'tech'),
//const TabData(title: '创意', key: 'creative'),
//const TabData(title: '好玩', key: 'play'),
//const TabData(title: 'APPLE', key: 'apple'),
//const TabData(title: '酷工作', key: 'jobs'),
//const TabData(title: '交易', key: 'deals'),
//const TabData(title: '城市', key: 'city'),
//const TabData(title: '问与答', key: 'qna'),
//const TabData(title: '最热', key: 'hot'),
//const TabData(title: '全部', key: 'all'),
//const TabData(title: 'R2', key: 'r2'),

class _ReorderableListTabsState extends State<ReorderableListTabs> {

  //static final List<TabModel> _tabs = SpHelper.getMainTabs();
//  bool _reverseSort = false;
  static final _items = <TabData>[
    TabData(title: '技术', key: 'tech'),
    TabData(title: '创意', key: 'creative'),
    TabData(title: '好玩', key: 'play'),
    TabData(title: 'APPLE', key: 'apple'),
    TabData(title: '酷工作', key: 'jobs'),
    TabData(title: '交易', key: 'deals'),
    TabData(title: '城市', key: 'city'),
    TabData(title: '问与答', key: 'qna'),
    TabData(title: '最热', key: 'hot'),
    TabData(title: '全部', key: 'all'),
    TabData(title: 'R2', key: 'r2'),
  ].map((item) => _ListItem(item, false)).toList();

  // Handler called by ReorderableListView onReorder after a list child is
  // dropped into a new position.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final _ListItem item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  // Handler called when the "sort" button on appbar is clicked.
//  void _onSort() {
//    setState(() {
//      _reverseSort = !_reverseSort;
//      _items.sort((_ListItem a, _ListItem b) => _reverseSort ? b.value.compareTo(a.value) : a.value.compareTo(b.value));
//    });
//  }

  @override
  Widget build(BuildContext context) {
    List<TabModel> _tabs = SpHelper.getMainTabs();
    print(_tabs.length);

    final _appbar = AppBar(
      title: Text('自定义主页 TAB'),
      actions: <Widget>[
        MaterialButton(
          onPressed: () {

            List<Map<String, dynamic>> linkMap = [];
            for (var item in _items) {
              linkMap.add({
                'title': item.value.title,
                'key': item.value.key,
                'isSelected':item.checked,
              });
            }

            print(json.encode(linkMap));
          },
          child: Text(
            '保存',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
            semanticsLabel: 'Save',
          ),
        )
//        IconButton(
//          icon: Icon(Icons.save),
//          tooltip: 'Save',
//          onPressed: _onSort,
//        ),
      ],
    );
    final _listTiles = _items
        .map(
          (item) => CheckboxListTile(
                key: Key(item.value.key),
                value: item.checked ?? false,
                onChanged: (bool newValue) {
                  setState(() => item.checked = newValue);
                },
                title: Text(item.value.title),
//                isThreeLine: true,
                subtitle: Text('Tab ${item.value.title}, checked=${item.checked}'),
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
