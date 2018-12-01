// 通过爬取网页数据作为返回
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/model/web/Node.dart';
import 'package:flutter_app/model/web/TabTopicItem.dart';

V2exApi v2exApi = new V2exApi();

class V2exApi {
  var httpClient = new HttpClient();

  final v2exUrl = "https://www.v2ex.com";

  static final V2exApi _v2exApi = new V2exApi._internal();

  factory V2exApi() {
    return _v2exApi;
  }

  V2exApi._internal();

  // 获取特定节点下的topics
  Future<List<TabTopicItem>> getTopicsByTabKey(String tabKey) async {
    String content = '';

    List<TabTopicItem> topics = new List<TabTopicItem>();

    final String reg4tag = "<div class=\"cell item\" (.*?)</table></div>";

    final String reg4MidAvatar =
        "<a href=\"/member/(.*?)\"><img src=\"(.*?)\" class=\"avatar\" ";

    final String reg4TRC = "<a href=\"/t/(.*?)#reply(.*?)\">(.*?)</a></span>";

    final String reg4NodeIdName =
        "<a class=\"node\" href=\"/go/(.*?)\">(.*?)</a>";

    final String reg4LastReply =
        "</strong> &nbsp;•&nbsp; (.*?) &nbsp;•&nbsp; 最后回复来自 <strong><a href=\"/member/(.*?)\">";

    var uri = new Uri.http('www.v2ex.com', '/', {'tab': tabKey});
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();

    content = responseBody.replaceAll(new RegExp(r"[\r\n]|(?=\s+</?d)\s+"), '');

    RegExp exp = new RegExp(reg4tag);
    Iterable<Match> matches = exp.allMatches(content);
    for (Match match in matches) {
      String regString = match.group(0);
      TabTopicItem item = new TabTopicItem();
      Match match4MidAvatar = new RegExp(reg4MidAvatar).firstMatch(regString);
      item.memberId = match4MidAvatar.group(1);
      item.avatar = "https:${match4MidAvatar.group(2)}";
      Match match4TRC = new RegExp(reg4TRC).firstMatch(regString);
      item.topicId = match4TRC.group(1);
      item.replyCount = match4TRC.group(2);
      item.topicContent = match4TRC.group(3);
      Match match4NodeIdName = new RegExp(reg4NodeIdName).firstMatch(regString);
      item.nodeId = match4NodeIdName.group(1);
      item.nodeName = match4NodeIdName.group(2);
      if (regString.contains("最后回复来自")) {
        Match match4LastReply = new RegExp(reg4LastReply).firstMatch(regString);
        item.lastReplyTime = match4LastReply.group(1);
        item.lastReplyMId = match4LastReply.group(2);
      }
      /*item.content = (await NetworkApi.getTopicDetails(int.parse(item.topicId)))
          .list[0]
          .content;*/
      topics.add(item);
    }
    return topics;
  }

  // 获取 V2EX / 节点导航
  Future<List<NodeGroup>> getNodes() async {
    List<NodeGroup> nodeGroups = <NodeGroup>[];

    String content = '';

    final String reg4Node =
        "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"right\" width=\"60\"><span class=\"fade\">(.*?)</td></tr></table>";

    final String reg4NodeGroup = "<span class=\"fade\">(.*?)</span></td>";
    final String reg4NodeItem =
        "<a href=\"/go/(.*?)\" style=\"font-size: 14px;\">(.*?)</a>";

    var uri = new Uri.http('www.v2ex.com', '/');
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();

    content = responseBody.replaceAll(new RegExp(r"[\r\n]|(?=\s+</?d)\s+"), '');

    RegExp exp = new RegExp(reg4Node);
    Iterable<Match> matches = exp.allMatches(content);

    for (Match match in matches) {
      NodeGroup nodeGroup = new NodeGroup();
      RegExp exp4GroupName = new RegExp(reg4NodeGroup);
      Match matchGroup = exp4GroupName.firstMatch(match.group(0));
      nodeGroup.nodeGroupName = matchGroup.group(1);

      RegExp exp4Node = new RegExp(reg4NodeItem);
      Iterable<Match> matchNodes = exp4Node.allMatches(match.group(0));
      for (Match matchNode in matchNodes) {
        NodeItem nodeItem = new NodeItem();
        nodeItem.nodeId = matchNode.group(1);
        nodeItem.nodeName = matchNode.group(2);
        nodeGroup.nodes.add(nodeItem);
      }
      nodeGroups.add(nodeGroup);
    }

    return nodeGroups;
  }
}
