import 'dart:convert' show json;

class SiteInfoResp {
  String description;
  String domain;
  String slogan;
  String title;

  factory SiteInfoResp(jsonStr) => jsonStr is String
      ? SiteInfoResp.fromJson(json.decode(jsonStr))
      : SiteInfoResp.fromJson(jsonStr);

  SiteInfoResp.fromJson(jsonRes) {
    try {
      description = jsonRes['description'];
      domain = jsonRes['domain'];
      slogan = jsonRes['slogan'];
      title = jsonRes['title'];
    } catch (e) {
      print(e);
    }
  }

  @override
  String toString() {
    return super.toString() +
        '\n' +
        '{"description": ${description != null ? json.encode(description) : 'null'},"domain": ${domain != null ? json.encode(domain) : 'null'},"slogan": ${slogan != null ? json.encode(slogan) : 'null'},"title": ${title != null ? json.encode(title) : 'null'}}';
  }
}
