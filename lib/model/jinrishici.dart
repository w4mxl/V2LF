class Poem {
  String status;
  String token;
  String ipAddress;
  DataBean data;

  static Poem fromMap(Map<String, dynamic> map) {
    Poem temp = new Poem();
    temp.status = map['status'];
    temp.token = map['token'];
    temp.ipAddress = map['ipAddress'];
    temp.data = DataBean.fromMap(map['data']);
    return temp;
  }

  static List<Poem> fromMapList(dynamic mapList) {
    List<Poem> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }
}

class OriginBean {
  String title;
  String dynasty;
  String author;
  List<String> content;
  List<String> translate;

  static OriginBean fromMap(Map<String, dynamic> map) {
    OriginBean originBean = new OriginBean();
    originBean.title = map['title'];
    originBean.dynasty = map['dynasty'];
    originBean.author = map['author'];

    List<dynamic> dynamicList0 = map['content'];
    originBean.content = new List();
    originBean.content.addAll(dynamicList0.map((o) => o.toString()));

    List<dynamic> dynamicList1 = map['translate'];
    originBean.translate = new List();
    if (dynamicList1 != null) originBean.translate.addAll(dynamicList1.map((o) => o.toString()));

    return originBean;
  }

  static List<OriginBean> fromMapList(dynamic mapList) {
    List<OriginBean> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }
}

class DataBean {
  String id;
  String content;
  String recommendedReason;
  String cacheAt;
  int popularity;
  OriginBean origin;
  List<String> matchTags;

  static DataBean fromMap(Map<String, dynamic> map) {
    DataBean dataBean = new DataBean();
    dataBean.id = map['id'];
    dataBean.content = map['content'];
    dataBean.recommendedReason = map['recommendedReason'];
    dataBean.cacheAt = map['cacheAt'];
    dataBean.popularity = map['popularity'];
    dataBean.origin = OriginBean.fromMap(map['origin']);

    List<dynamic> dynamicList0 = map['matchTags'];
    dataBean.matchTags = new List();
    if (dynamicList0 != null) dataBean.matchTags.addAll(dynamicList0.map((o) => o.toString()));

    return dataBean;
  }

  static List<DataBean> fromMapList(dynamic mapList) {
    List<DataBean> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }
}
