import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/web/login_form_data.dart';
import 'package:flutter_app/network/dio_singleton.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

// 2018/12/30 21:23
// 用 Charles 分析了一下 V2ex 网站登录的过程
// 通过模拟网站登录的过程，实现登录。登录后保存cookie，为了后面实现评论和回复作准备
// name password captcha once next

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

LoginFormData loginFormData;

class _LoginPageState extends State<LoginPage> {
  TextEditingController _accountController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _captchaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  FocusNode passwordTextFieldNode, captchaTextFieldNode;

  @override
  void initState() {
    super.initState();
    refreshCaptcha();
    passwordTextFieldNode = FocusNode();
    captchaTextFieldNode = FocusNode();
  }

  // 刷新（首次获取）验证码
  Future refreshCaptcha() async {
    var formData = await dioSingleton.parseLoginForm();
    setState(() {
      loginFormData = formData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      "assets/images/logo_v2lf.png",
      width: 48.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: logo,
//        title: Row(
//          children: <Widget>[
//            logo,
//            Padding(
//              padding: const EdgeInsets.only(left: 4.0),
//              child: Text(MyLocalizations.of(context).login),
//            ),
//          ],
//        ),
      ),
      body: ScrollConfiguration(
        child: SingleChildScrollView(
          child: Form(
              key: _formKey, //设置globalKey，用于后面获取FormState
              autovalidate: false, //开启自动校验
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    // 用户名
                    TextFormField(
                        autofocus: true,
                        controller: _accountController,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context).requestFocus(passwordTextFieldNode),
                        decoration: InputDecoration(
                          labelText: MyLocalizations.of(context).account,
                          hintText: MyLocalizations.of(context).enterAccount,
                          border: OutlineInputBorder(),
                        ),
                        // 校验用户名
                        validator: (v) {
                          return v.trim().length > 0 ? null : "用户名不能为空";
                        }),
                    SizedBox(
                      height: 12.0,
                    ),
                    // 密码
                    TextFormField(
                        controller: _pwdController,
                        focusNode: passwordTextFieldNode,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context).requestFocus(captchaTextFieldNode),
                        decoration: InputDecoration(
                          labelText: MyLocalizations.of(context).password,
                          hintText: MyLocalizations.of(context).enterPassword,
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        //校验密码
                        validator: (v) {
                          return v.trim().length > 0 ? null : "密码不能为空";
                        }),
                    SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                              controller: _captchaController,
                              focusNode: captchaTextFieldNode,
                              onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
                              decoration: InputDecoration(
                                labelText: MyLocalizations.of(context).captcha,
                                hintText: MyLocalizations.of(context).enterCaptcha,
                                border: OutlineInputBorder(),
                              ),
                              //校验密码
                              validator: (v) {
                                return v.trim().length > 3 ? null : "验证码不能少于4位";
                              }),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: loginFormData != null && loginFormData.bytes.length > 0
                                ? GestureDetector(
                                    child: Image.memory(
                                      loginFormData.bytes,
                                      height: 55.0,
                                      width: 160.0,
                                      fit: BoxFit.fill,
                                    ),
                                    onTap: () {
                                      refreshCaptcha();
                                    },
                                  )
                                : IconButton(
                                    icon: Icon(Icons.sync),
                                    onPressed: () {
                                      refreshCaptcha();
                                    })),
                      ],
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    ButtonTheme(
                      child: RaisedButton(
//                        color: Colors.blueGrey,
//                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 40.0, right: 40.0),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            if (loginFormData != null) {
                              loginFormData.usernameInput = _accountController.text;
                              loginFormData.passwordInput = _pwdController.text;
                              loginFormData.captchaInput = _captchaController.text;
                              //var formData = bloc.submit(loginFormData);
                              print(loginFormData.toString());
                              bool loginResult = await dioSingleton.loginPost(loginFormData);
                              if (loginResult) {
                                Fluttertoast.showToast(
                                    msg: MyLocalizations.of(context).toastLoginSuccess(SpHelper.sp.getString(SP_USERNAME)));
                                Navigator.of(context).pop();
                              } else {
                                refreshCaptcha();
                              }
                            }
                          }
                        },
                        child: Text(MyLocalizations.of(context).login, style: TextStyle(color: Colors.white)),
                      ),
                      height: 55.0,
                      minWidth: 400.0,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            '注册',
                            style: TextStyle(color: Colors.black54),
                          ),
                          onPressed: () {
                            // 注册 -> 跳转到注册web页面
                            launch("https://www.v2ex.com/signup",
                                statusBarBrightness: Platform.isIOS ? Brightness.light : null);
                          },
                        ),
                        FlatButton(
                          child: Text(
                            MyLocalizations.of(context).forgetPassword,
                            style: TextStyle(color: Colors.black54),
                          ),
                          onPressed: () {
                            // 忘记密码 -> 跳转到重置密码web页面
                            launch("https://www.v2ex.com/forgot",
                                statusBarBrightness: Platform.isIOS ? Brightness.light : null);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )),
        ),
        behavior: MyBehavior(),
      ),
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _pwdController.dispose();
    _captchaController.dispose();
    super.dispose();
  }
}

// 去除拖拽时的波纹效果
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
