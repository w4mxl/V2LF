import 'package:flutter/material.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/language.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:flutter_app/utils/constants.dart';
import 'package:flutter_app/utils/eventbus.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/utils.dart';
/*import 'package:flame/animation.dart' as animation;
import 'package:flame/flame.dart';
import 'package:flame/position.dart';*/

// 设置页面
class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<LanguageModel> _list = new List();
  LanguageModel _currentLanguage;

  @override
  void initState() {
    super.initState();

    _list.add(LanguageModel('', ''));
    _list.add(LanguageModel('zh', 'Hans'));
    _list.add(LanguageModel('zh', 'Hant'));
    _list.add(LanguageModel('en', 'US'));

    _currentLanguage = SpHelper.getLanguageModel();
    if (_currentLanguage == null) {
      _currentLanguage = _list[0];
    }

    _updateData();
  }

  void _updateData() {
    print(_currentLanguage.toString());
    String language = _currentLanguage.scriptCode;
    for (int i = 0, length = _list.length; i < length; i++) {
      _list[i].isSelected = (_list[i].scriptCode == language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyLocalizations.of(context).titleSetting),
      ),
      body: ListView(
        children: <Widget>[
          // 主题设置
          ExpansionTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.color_lens, color: ColorT.gray_66),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(MyLocalizations.of(context).titleTheme),
                )
              ],
            ),
            children: <Widget>[
              Wrap(
                children: themeColorMap.keys.map((key) {
                  Color value = themeColorMap[key];
                  return new InkWell(
                    onTap: () {
                      SpHelper.sp.setString(KEY_THEME_COLOR, key);
                      bus.emit(EVENT_NAME_SETTING);
                    },
                    child: new Container(
                      margin: EdgeInsets.all(5.0),
                      width: 36.0,
                      height: 36.0,
                      color: value,
                    ),
                  );
                }).toList(),
              )
            ],
          ),
          // 多语言设置
          ExpansionTile(
            title: Row(
              children: <Widget>[
                Icon(
                  Icons.language,
                  color: ColorT.gray_66,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(MyLocalizations.of(context).titleLanguage),
                ),
                Expanded(
                  child: Text(
                    SpHelper.getLanguageModel() == null
                        ? MyLocalizations.of(context).languageAuto
                        : Utils.getLanguageName(
                            context, SpHelper.getLanguageModel().languageCode, SpHelper.getLanguageModel().scriptCode),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: ColorT.gray_99,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            children: <Widget>[
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _list.length,
                  itemBuilder: (BuildContext context, int index) {
                    LanguageModel model = _list[index];
                    return new ListTile(
                      title: new Text(
                        (model.languageCode.isEmpty
                            ? MyLocalizations.of(context).languageAuto
                            : Utils.getLanguageName(context, model.languageCode, model.scriptCode)),
                        style: new TextStyle(fontSize: 13.0),
                      ),
                      trailing: new Radio(
                          value: true,
                          groupValue: model.isSelected == true,
                          //activeColor: Colors.indigoAccent,
                          onChanged: (value) {
                            setState(() {
                              updateLanguage(model);
                            });
                          }),
                      onTap: () {
                        setState(() {
                          updateLanguage(model);
                        });
                      },
                    );
                  }),
            ],
          ),
          /*Center(
            child: Flame.util.animationAsWidget(
                Position(256.0, 256.0), animation.Animation.sequenced('minotaur.png', 19, textureWidth: 96.0)),
          ),*/
        ],
      ),
    );
  }

  void updateLanguage(LanguageModel model) {
    _currentLanguage = model;
    _updateData();
    SpHelper.putObject(KEY_LANGUAGE, _currentLanguage.languageCode.isEmpty ? null : _currentLanguage);
    bus.emit(EVENT_NAME_SETTING);
  }
}
