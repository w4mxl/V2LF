class Token {
  String status;
  String data;

  static Token fromMap(Map<String, dynamic> map) {
    Token temp = new Token();
    temp.status = map['status'];
    temp.data = map['data'];
    return temp;
  }
}
