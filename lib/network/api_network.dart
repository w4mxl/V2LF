import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/model/jinrishici.dart';
import 'package:flutter_app/model/resp_replies.dart';
import 'package:flutter_app/model/resp_site_info.dart';
import 'package:flutter_app/model/resp_topics.dart';
import 'package:flutter_app/utils/constants.dart' as Constants;
import 'package:flutter_app/utils/constants.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NetworkApi {
  static Future _read(String url) {
    return http.read(url);
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
    return TopicsResp.fromJson(await _get(Constants.API_TOPIC_DETAILS + '?id=' + id.toString()));
  }

  static Future<RepliesResp> getReplies(int topicId) async {
    return RepliesResp.fromJson(
        await _get(Constants.API_TOPIC_REPLY + '?topic_id=' + topicId.toString()));
  }

  static Future<SiteInfoResp> getSiteInfo() async {
    return SiteInfoResp.fromJson(await _get(Constants.API_SITE_INFO));
  }

  /*static Future<Token> getPoemToken() async {
    return Token.fromMap(await _get(httpConstants.API_JINRISHICI_TOKEN));
  }*/

  static Future<Poem> getPoem() async {
    SharedPreferences sp = await getSp();
    var spJinrishiciToken = sp.getString(SP_JINRISHICI_TOKEN);
    print('wml:$spJinrishiciToken');
    Map<String, String> headers = {'X-User-Token': spJinrishiciToken};
    String response = await http.read(Constants.API_JINRISHICI_ONE,
        headers: spJinrishiciToken != null ? headers : null);
    var poem = Poem.fromMap(json.decode(response));
    if (poem.status == 'success') {
      if (spJinrishiciToken == null) sp.setString(SP_JINRISHICI_TOKEN, poem.token);
      return poem;
    }
    return null;
  }
}
