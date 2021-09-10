import 'dart:async';

/// @author: wml
/// @date  : 2019-05-31 18:17
/// @email : mxl1989@gmail.com
/// @desc  : 数据库操作
/// study from https://medium.com/@studymongolian/simple-sqflite-database-example-in-flutter-e56a5aaa3f91

import 'dart:io';

import 'package:flutter_app/models/web/item_recent_read_topic.dart';
import 'package:flutter_app/models/web/item_tab_topic.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyReadHistory.db";
  static const _databaseVersion = 2;

  static const table = 'recent_read_table';

  static const columnTopicId = 'topicId';
  //static final columnReadStatus = 'readStatus';
  static const columnMemberId = 'memberId';

  static const columnAvatar = 'avatar';
  static const columnTopicContent = 'topicContent';
  //static final columnReplyCount = 'replyCount';
  static const columnNodeId = 'nodeId';
  static const columnNodeName = 'nodeName';
  //static final columnLastReplyMId = 'lastReplyMId';
  //static final columnLastReplyTime = 'lastReplyTime';

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnTopicId TEXT PRIMARY KEY,
            $columnMemberId TEXT NOT NULL,
            $columnAvatar TEXT NOT NULL,
            $columnTopicContent TEXT NOT NULL,
            $columnNodeId TEXT NOT NULL,
            $columnNodeName TEXT NOT NULL
          )
          ''');
  }

  // 升级 recent_read_table 表，从 v1 到 v2 (删除 v1 中无用的列)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      var batch = db.batch();
      batch.execute('''
          CREATE TABLE recent_read_table_back (
            $columnTopicId TEXT PRIMARY KEY,
            $columnMemberId TEXT NOT NULL,
            $columnAvatar TEXT NOT NULL,
            $columnTopicContent TEXT NOT NULL,
            $columnNodeId TEXT NOT NULL,
            $columnNodeName TEXT NOT NULL
          )
          ''');
      batch.execute(
          'INSERT INTO recent_read_table_back SELECT $columnTopicId,$columnMemberId,$columnAvatar,$columnTopicContent,$columnNodeId,$columnNodeName FROM $table');
      batch.execute('DROP TABLE IF EXISTS $table');
      batch.execute('ALTER TABLE recent_read_table_back RENAME TO $table');
      await batch.commit();
    }
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(RecentReadTopicItem item) async {
    // 判断如果已经有相同id的主题存在，则先删除后添加
    if (await queryTopic(item.topicId)) {
      print("已存在，先移除");
      delete(item.topicId);
    }
    Database db = await instance.database;
    return await db.insert(table, item.toMap());
  }

  Future<bool> queryTopic(String topicId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(table, where: '$columnTopicId = ?', whereArgs: [topicId]);
    return result.isNotEmpty;
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // 获取近期已读列表
  Future<List<RecentReadTopicItem>> getRecentReadTopics() async {
    var mapList = await queryAllRows();
    List<RecentReadTopicItem> topicList = <RecentReadTopicItem>[];
    mapList.forEach((map) => topicList.insert(0, RecentReadTopicItem.fromMap(map)));
    print("当前数据库共有${topicList.length}条记录");
    return topicList;
  }

  // 对请求回来的数据，已读的增加已读标记
  Future<List<TabTopicItem>> addReadState(List<TabTopicItem> list) async {
    for (var tabTopicItem in list) {
      if (await queryTopic(tabTopicItem.topicId)) {
        print("${tabTopicItem.topicContent} :存在，设为已读");
        tabTopicItem.readStatus = 'read';
      }
    }
    return list;
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(RecentReadTopicItem tabTopicItem) async {
    Database db = await instance.database;
    return await db.update(table, tabTopicItem.toMap(), where: '$columnTopicId = ?', whereArgs: [tabTopicItem.topicId]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(String topicId) async {
    Database db = await instance.database;
    print("删除某条已读： " + topicId);
    return await db.delete(table, where: '$columnTopicId = ?', whereArgs: [topicId]);
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}
