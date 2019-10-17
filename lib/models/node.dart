class Node {
  String avatarLarge;
  String name;
  String avatarNormal;
  String title;
  String url;
  String footer;
  String header;
  String titleAlternative;
  String avatarMini;
  String parentNodeName;
  bool root;
  int topics;
  int stars;
  int id;

  Node({this.avatarLarge, this.name, this.avatarNormal, this.title, this.url, this.footer, this.header, this.titleAlternative, this.avatarMini, this.parentNodeName, this.root, this.topics, this.stars, this.id});

  Node.fromJson(Map<String, dynamic> json) {    
    this.avatarLarge = json['avatar_large'];
    this.name = json['name'];
    this.avatarNormal = json['avatar_normal'];
    this.title = json['title'];
    this.url = json['url'];
    this.footer = json['footer'];
    this.header = json['header'];
    this.titleAlternative = json['title_alternative'];
    this.avatarMini = json['avatar_mini'];
    this.parentNodeName = json['parent_node_name'];
    this.root = json['root'];
    this.topics = json['topics'];
    this.stars = json['stars'];
    this.id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar_large'] = this.avatarLarge;
    data['name'] = this.name;
    data['avatar_normal'] = this.avatarNormal;
    data['title'] = this.title;
    data['url'] = this.url;
    data['footer'] = this.footer;
    data['header'] = this.header;
    data['title_alternative'] = this.titleAlternative;
    data['avatar_mini'] = this.avatarMini;
    data['parent_node_name'] = this.parentNodeName;
    data['root'] = this.root;
    data['topics'] = this.topics;
    data['stars'] = this.stars;
    data['id'] = this.id;
    return data;
  }

}
