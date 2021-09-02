import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/models/jinrishici.dart';
import 'package:flutter_app/models/node.dart';
import 'package:flutter_app/models/resp_replies.dart';
import 'package:flutter_app/models/resp_site_info.dart';
import 'package:flutter_app/models/resp_topics.dart';
import 'package:flutter_app/models/web/node.dart';
import 'package:flutter_app/utils/constants.dart' as Constants;
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:http/http.dart' as http;

class NetworkApi {
  static Future _read(String url) {
    return http.read(Uri.parse(url));
  }

  static dynamic _get(String url) async {
    String response = await _read(url);
    print('$url =>\n $response');
    // return JsonDecoder().convert(response);
    return json.decode(response);
  }

  static Future<TopicsResp> getLatestTopics() async {
    return TopicsResp.fromJson(await _get(Constants.API_TOPICS_LATEST));
  }

  static Future<TopicsResp> getHotTopics() async {
    return TopicsResp.fromJson(await _get(Constants.API_TOPICS_HOT));
  }

  static Future<TopicsResp> getTopicDetails(int id) async {
    return TopicsResp.fromJson(
        await _get(Constants.API_TOPIC_DETAILS + '?id=' + id.toString()));
  }

  static Future<RepliesResp> getReplies(int topicId) async {
    return RepliesResp.fromJson(await _get(
        Constants.API_TOPIC_REPLY + '?topic_id=' + topicId.toString()));
  }

  static Future<SiteInfoResp> getSiteInfo() async {
    return SiteInfoResp.fromJson(await _get(Constants.API_SITE_INFO));
  }

  // Node / 获取指定节点信息
  static Future<Node> getNodeInfo(String nodeName) async {
    return Node.fromJson(await _get(Constants.API_NODE + '?name=' + nodeName));
  }

  // Nodes / 获取所有节点列表
  static Future<List<NodeItem>> getAllNodes() async {
    List<dynamic> list = await _get(Constants.API_ALL_NODES);
    return list.map((e) => NodeItem(e['name'], e['title'])).toList();
  }

  static Future<Poem> getPoem() async {
    var spJinrishiciToken = SpHelper.sp.getString(SP_JINRISHICI_TOKEN);
    Map<String, String> headers = {'X-User-Token': spJinrishiciToken};
    String response = await http.read(Uri.parse(Constants.API_JINRISHICI_ONE),
        headers: spJinrishiciToken != null ? headers : null);
    var poem = Poem.fromJson(json.decode(response));
    if (poem.status == 'success') {
      if (spJinrishiciToken == null)
        SpHelper.sp.setString(SP_JINRISHICI_TOKEN, poem.token);
      return poem;
    }
    return null;
  }
}
