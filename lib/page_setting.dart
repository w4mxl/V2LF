import 'package:fluintl/fluintl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:flutter_app/resources/strings.dart';

// 设置页面
class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(IntlUtil.getString(context, Ids.titleSetting)),
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
                  child: Text(IntlUtil.getString(context, Ids.titleTheme)),
                )
              ],
            ),
            children: <Widget>[
              Wrap(
                children: themeColorMap.keys.map((key) {
                  Color value = themeColorMap[key];
                  return new InkWell(
                    onTap: () {
                      // todo
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
          ListTile(
            title: Row(
              children: <Widget>[
                Icon(
                  Icons.language,
                  color: ColorT.gray_66,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(IntlUtil.getString(context, Ids.titleLanguage)),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('todo'
                    /*SpHelper.getLanguageModel() == null
                        ? IntlUtil.getString(context, Ids.languageAuto)
                        : IntlUtil.getString(context, SpHelper.getLanguageModel().titleId,
                            languageCode: 'zh', countryCode: 'CH'),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: ColorT.gray_99,
                    )*/
                    ),
                Icon(Icons.keyboard_arrow_right)
              ],
            ),
            onTap: () {},
          )
        ],
      ),
    );
  }
}
