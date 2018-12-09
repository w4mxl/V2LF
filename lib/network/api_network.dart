import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/model/resp_replies.dart';
import 'package:flutter_app/model/resp_site_info.dart';
import 'package:flutter_app/model/resp_topics.dart';
import 'package:flutter_app/network/constants.dart' as httpConstants;
import 'package:http/http.dart' as http;

class NetworkApi {
  static Future _read(String url) {
    return http.read(url);
  }

  static dynamic _get(String url) async {
    String response = await _read(url);
    print('$url =>\n $response');
    return json.decode(response);
  }

  static Future<TopicsResp> getLatestTopics() async {
    return TopicsResp.fromJson(await _get(httpConstants.API_TOPICS_LATEST));
  }

  static Future<TopicsResp> getHotTopics() async {
    return TopicsResp.fromJson(await _get(httpConstants.API_TOPICS_HOT));
  }

  static Future<TopicsResp> getTopicDetails(int id) async {
    return TopicsResp.fromJson(
        await _get(httpConstants.API_TOPIC_DETAILS + '?id=' + id.toString()));
  }

  static Future<RepliesResp> getReplies(int topicId) async {
    return RepliesResp.fromJson(await _get(
        httpConstants.API_TOPIC_REPLY + '?topic_id=' + topicId.toString()));
  }

  static Future<SiteInfoResp> getSiteInfo() async {
    return SiteInfoResp.fromJson(await _get(httpConstants.API_SITE_INFO));
  }
}
