class Poem {
  String status;
  String token;
  String ipAddress;
  DataBean data;

  Poem({this.status, this.token, this.ipAddress, this.data});

  Poem.fromJson(Map<String, dynamic> json) {    
    this.status = json['status'];
    this.token = json['token'];
    this.ipAddress = json['ipAddress'];
    this.data = json['data'] != null ? DataBean.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['token'] = this.token;
    data['ipAddress'] = this.ipAddress;
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
    this.id = json['id'];
    this.content = json['content'];
    this.recommendedReason = json['recommendedReason'];
    this.cacheAt = json['cacheAt'];
    this.popularity = json['popularity'];
    this.origin = json['origin'] != null ? OriginBean.fromJson(json['origin']) : null;

    List<dynamic> matchTagsList = json['matchTags'];
    this.matchTags = new List();
    this.matchTags.addAll(matchTagsList.map((o) => o.toString()));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['content'] = this.content;
    data['recommendedReason'] = this.recommendedReason;
    data['cacheAt'] = this.cacheAt;
    data['popularity'] = this.popularity;
    if (this.origin != null) {
      data['origin'] = this.origin.toJson();
    }
    data['matchTags'] = this.matchTags;
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
    this.title = json['title'];
    this.dynasty = json['dynasty'];
    this.author = json['author'];

    List<dynamic> contentList = json['content'];
    this.content = new List();
    this.content.addAll(contentList.map((o) => o.toString()));

    List<dynamic> translateList = json['translate'];
    if(translateList!=null){
      this.translate = new List();
      this.translate.addAll(translateList.map((o) => o.toString()));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['dynasty'] = this.dynasty;
    data['author'] = this.author;
    data['content'] = this.content;
    data['translate'] = this.translate;
    return data;
  }
}
