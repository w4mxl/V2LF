import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/model/web/node.dart';

// 通过爬取网页数据作为返回

V2exApi v2exApi = new V2exApi();

class V2exApi {
  var httpClient = new HttpClient();

  static final V2exApi _v2exApi = new V2exApi._internal();

  factory V2exApi() {
    return _v2exApi;
  }

  V2exApi._internal();

  // 获取 V2EX / 节点导航
  Future<List<NodeGroup>> getNodes() async {
    List<NodeGroup> nodeGroups = <NodeGroup>[];

    String content = '';

    final String reg4Node =
        "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"right\" width=\"60\"><span class=\"fade\">(.*?)</td></tr></table>";

    final String reg4NodeGroup = "<span class=\"fade\">(.*?)</span></td>";
    final String reg4NodeItem = "<a href=\"/go/(.*?)\" style=\"font-size: 14px;\">(.*?)</a>";

    var uri = new Uri.https('www.v2ex.com', '/');
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
        NodeItem nodeItem = new NodeItem(matchNode.group(1), matchNode.group(2));
        /*nodeItem.nodeId = matchNode.group(1);
        nodeItem.nodeName = matchNode.group(2);*/
        nodeGroup.nodes.add(nodeItem);
      }
      nodeGroups.add(nodeGroup);
    }

    return nodeGroups;
  }

}
