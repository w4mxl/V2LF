/// @author: wml
/// @date  : 2019/3/20 12:39
/// @email : mxl1989@gmail.com
/// @desc  : 借助 sov2ex 搜索

class Sov2ex {
  bool timed_out;
  int took;
  int total;
  List<HitsListBean> hits;

  static Sov2ex fromMap(Map<String, dynamic> map) {
    Sov2ex sov2ex = Sov2ex();
    sov2ex.timed_out = map['timed_out'];
    sov2ex.took = map['took'];
    sov2ex.total = map['total'];
    sov2ex.hits = HitsListBean.fromMapList(map['hits']);
    return sov2ex;
  }

  static List<Sov2ex> fromMapList(dynamic mapList) {
    List<Sov2ex> list = List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }
}

class HitsListBean {
  String index;
  String type;
  String id;
  double score;
  SourceBean source;
  HighlightBean highlight;

  static HitsListBean fromMap(Map<String, dynamic> map) {
    HitsListBean hitsListBean = HitsListBean();
    hitsListBean.index = map['_index'];
    hitsListBean.type = map['_type'];
    hitsListBean.id = map['_id'];
    hitsListBean.score = map['_score'];
    hitsListBean.source = SourceBean.fromMap(map['_source']);
    hitsListBean.highlight = HighlightBean.fromMap(map['highlight']);
    return hitsListBean;
  }

  static List<HitsListBean> fromMapList(dynamic mapList) {
    List<HitsListBean> list = List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }
}

class SourceBean {
  String created;
  String member;
  String title;
  String content;
  int node;
  int replies;
  int id;

  static SourceBean fromMap(Map<String, dynamic> map) {
    SourceBean _sourceBean = SourceBean();
    _sourceBean.created = map['created'];
    _sourceBean.member = map['member'];
    _sourceBean.title = map['title'];
    _sourceBean.content = map['content'];
    _sourceBean.node = map['node'];
    _sourceBean.replies = map['replies'];
    _sourceBean.id = map['id'];
    return _sourceBean;
  }

  static List<SourceBean> fromMapList(dynamic mapList) {
    List<SourceBean> list = List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }
}

class HighlightBean {
  List<String> content;
  List<String> postscript_list;
  List<String> reply_list;
  List<String> title;

  static HighlightBean fromMap(Map<String, dynamic> map) {
    HighlightBean highlightBean = HighlightBean();

    if (map['content'] != null) {
      List<dynamic> dynamicList0 = map['content'];
      highlightBean.content = List();
      highlightBean.content.addAll(dynamicList0.map((o) => o.toString()));
    }

    if (map['postscript_list.content'] != null) {
      List<dynamic> dynamicList1 = map['postscript_list.content'];
      highlightBean.postscript_list = List();
      highlightBean.postscript_list.addAll(dynamicList1.map((o) => o.toString()));
    }

    if (map['reply_list.content'] != null) {
      List<dynamic> dynamicList2 = map['reply_list.content'];
      highlightBean.reply_list = [];
      highlightBean.reply_list.addAll(dynamicList2.map((o) => o.toString()));
    }

    if (map['title'] != null) {
      List<dynamic> dynamicList3 = map['title'];
      highlightBean.title = List();
      highlightBean.title.addAll(dynamicList3.map((o) => o.toString()));
    }

    return highlightBean;
  }

  static List<HighlightBean> fromMapList(dynamic mapList) {
    List<HighlightBean> list = List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }
}
