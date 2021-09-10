class LanguageModel {
  String languageCode;
  String countryCode;
  bool isSelected;

  LanguageModel(this.languageCode, this.countryCode, {this.isSelected = false});

  LanguageModel.fromJson(Map<String, dynamic> json)
      : languageCode = json['languageCode'],
        countryCode = json['countryCode'],
        isSelected = json['isSelected'];

  Map<String, dynamic> toJson() => {
        'languageCode': languageCode,
        'countryCode': countryCode,
        'isSelected': isSelected,
      };

  @override
  String toString() {
    StringBuffer sb = StringBuffer('{');
    sb.write("\"languageCode\":\"$languageCode\"");
    sb.write(",\"countryCode\":\"$countryCode\"");
    sb.write('}');
    return sb.toString();
  }
}
