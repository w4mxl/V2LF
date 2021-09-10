class Poem {
  String status;
  String token;
  String ipAddress;
  DataBean data;

  Poem({this.status, this.token, this.ipAddress, this.data});

  Poem.fromJson(Map<String, dynamic> json) {    
    status = json['status'];
    token = json['token'];
    ipAddress = json['ipAddress'];
    data = json['data'] != null ? DataBean.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['token'] = token;
    data['ipAddress'] = ipAddress;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
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

  DataBean({this.id, this.content, this.recommendedReason, this.cacheAt, this.popularity, this.origin, this.matchTags});

  DataBean.fromJson(Map<String, dynamic> json) {    
    id = json['id'];
    content = json['content'];
    recommendedReason = json['recommendedReason'];
    cacheAt = json['cacheAt'];
    popularity = json['popularity'];
    origin = json['origin'] != null ? OriginBean.fromJson(json['origin']) : null;

    List<dynamic> matchTagsList = json['matchTags'];
    matchTags = List();
    matchTags.addAll(matchTagsList.map((o) => o.toString()));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['content'] = content;
    data['recommendedReason'] = recommendedReason;
    data['cacheAt'] = cacheAt;
    data['popularity'] = popularity;
    if (origin != null) {
      data['origin'] = origin.toJson();
    }
    data['matchTags'] = matchTags;
    return data;
  }
}

class OriginBean {
  String title;
  String dynasty;
  String author;
  List<String> content;
  List<String> translate;

  OriginBean({this.title, this.dynasty, this.author, this.content, this.translate});

  OriginBean.fromJson(Map<String, dynamic> json) {    
    title = json['title'];
    dynasty = json['dynasty'];
    author = json['author'];

    List<dynamic> contentList = json['content'];
    content = List();
    content.addAll(contentList.map((o) => o.toString()));

    List<dynamic> translateList = json['translate'];
    if(translateList!=null){
      translate = [];
      translate.addAll(translateList.map((o) => o.toString()));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['dynasty'] = dynasty;
    data['author'] = author;
    data['content'] = content;
    data['translate'] = translate;
    return data;
  }
}
