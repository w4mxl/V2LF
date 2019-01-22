import 'package:fluintl/fluintl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/language.dart';
import 'package:flutter_app/resources/strings.dart';
import 'package:flutter_app/utils/constants.dart';
import 'package:flutter_app/utils/eventbus.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:quiver/strings.dart';

class LanguagePageSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanguagePageSettingState();
  }
}

class _LanguagePageSettingState extends State<LanguagePageSetting> {
  List<LanguageModel> _list = new List();

  LanguageModel _currentLanguage;

  @override
  void initState() {
    super.initState();

    _list.add(LanguageModel(Ids.languageAuto, '', ''));
    _list.add(LanguageModel(Ids.languageZH, 'zh', 'CH'));
    _list.add(LanguageModel(Ids.languageTW, 'zh', 'TW'));
    _list.add(LanguageModel(Ids.languageHK, 'zh', 'HK'));
    _list.add(LanguageModel(Ids.languageEN, 'en', 'US'));

    _currentLanguage = SpHelper.getLanguageModel();
    if (_currentLanguage == null) {
      _currentLanguage = _list[0];
    }

    _updateData();
  }

  void _updateData() {
    String language = _currentLanguage.countryCode;
    for (int i = 0, length = _list.length; i < length; i++) {
      _list[i].isSelected = (_list[i].countryCode == language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          IntlUtil.getString(context, Ids.titleLanguage),
          style: new TextStyle(fontSize: 16.0),
        ),
        actions: [
          new Padding(
            padding: EdgeInsets.all(12.0),
            child: new SizedBox(
              width: 64.0,
              child: new RaisedButton(
                textColor: Colors.white,
                color: Colors.indigoAccent,
                child: Text(
                  IntlUtil.getString(context, Ids.save),
                  style: new TextStyle(fontSize: 12.0),
                ),
                onPressed: () {
                  SpHelper.putObject(KEY_LANGUAGE,
                      isEmpty(_currentLanguage.languageCode) ? null : _currentLanguage);
                  bus.emit(EVENT_NAME_SETTING);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
      body: new ListView.builder(
          itemCount: _list.length,
          itemBuilder: (BuildContext context, int index) {
            LanguageModel model = _list[index];
            return new ListTile(
              title: new Text(
                (model.titleId == Ids.languageAuto
                    ? IntlUtil.getString(context, model.titleId)
                    : IntlUtil.getString(context, model.titleId,
                        languageCode: 'zh', countryCode: 'CH')),
                style: new TextStyle(fontSize: 13.0),
              ),
              trailing: new Radio(
                  value: true,
                  groupValue: model.isSelected == true,
                  activeColor: Colors.indigoAccent,
                  onChanged: (value) {
                    setState(() {
                      _currentLanguage = model;
                      _updateData();
                    });
                  }),
              onTap: () {
                setState(() {
                  _currentLanguage = model;
                  _updateData();
                });
              },
            );
          }),
    );
  }
}
