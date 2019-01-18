import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bloc/bloc_login.dart';
import 'package:flutter_app/model/web/login_form_data.dart';
import 'package:flutter_app/network/dio_singleton.dart';
import 'package:flutter_app/utils/eventbus.dart';
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
String fieldAccount;
String fieldPassword;
String fieldCaptcha;

class _LoginPageState extends State<LoginPage> {
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
    final bloc = BlocLogin();
    final logo = Image.asset(
      "assets/images/logo_v2lf.png",
      width: 10.0,
    );

    final userName = StreamBuilder<String>(
      stream: bloc.account,
      builder: (context, snapshot) => TextField(
            onChanged: (text) {
              bloc.accountChanged(text);
              fieldAccount = text;
            },
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(passwordTextFieldNode);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                labelText: "Account",
                hintText: 'Enter account',
                errorText: snapshot.error,
                border: OutlineInputBorder()),
          ),
    );

    final password = StreamBuilder<String>(
      stream: bloc.password,
      builder: (context, snapshot) => TextField(
            onChanged: (text) {
              bloc.passwordChanged(text);
              fieldPassword = text;
            },
            onEditingComplete: () {
              //passwordTextFieldNode.unfocus();
              FocusScope.of(context).requestFocus(captchaTextFieldNode);
            },
            textInputAction: TextInputAction.next,
            focusNode: passwordTextFieldNode,
            obscureText: true,
            decoration: InputDecoration(
                labelText: "Password",
                hintText: 'Enter password',
                errorText: snapshot.error,
                border: OutlineInputBorder()),
          ),
    );

    final captcha = Row(
      children: <Widget>[
        Flexible(
            child: StreamBuilder<String>(
                stream: bloc.captcha,
                builder: (context, snapshot) => TextField(
                      onChanged: (text) {
                        bloc.captchaChanged(text);
                        fieldCaptcha = text;
                      },
                      onEditingComplete: () {
                        // 收起键盘
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      focusNode: captchaTextFieldNode,
                      decoration: InputDecoration(
                          labelText: "Captcha",
                          hintText: 'Enter right captcha',
                          errorText: snapshot.error,
                          border: OutlineInputBorder()),
                    ))),
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
    );

    final loginButton = StreamBuilder<bool>(
      stream: bloc.submitCheck,
      builder: (context, snapshot) => ButtonTheme(
            child: RaisedButton(
              color: Colors.blueGrey,
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 40.0, right: 40.0),
              onPressed: snapshot.hasData
                  ? () async {
                      if (loginFormData != null &&
                          fieldAccount != null &&
                          fieldPassword != null &&
                          fieldCaptcha != null) {
                        loginFormData.usernameInput = fieldAccount;
                        loginFormData.passwordInput = fieldPassword;
                        loginFormData.captchaInput = fieldCaptcha;
                        //var formData = bloc.submit(loginFormData);
                        print(loginFormData.toString());
                        bool loginResult = await dioSingleton.loginPost(loginFormData);
                        if (loginResult) {
                          print("wml success!!!!");
                          bus.emit("login");
                          Navigator.of(context).pop();
                        } else {
                          refreshCaptcha();
                        }
                      }
                    }
                  : null,
              child: Text('Log In', style: TextStyle(color: Colors.white)),
            ),
            height: 50.0,
            minWidth: 300.0,
          ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        // 忘记密码 -> 跳转到重置密码web页面
        launch("https://www.v2ex.com/forgot", forceWebView: true);
      },
    );

    return Scaffold(
      appBar: AppBar(),
      body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
          child: ListView(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              logo,
              SizedBox(
                height: 20.0,
              ),
              userName,
              SizedBox(
                height: 15.0,
              ),
              password,
              SizedBox(
                height: 15.0,
              ),
              captcha,
              SizedBox(
                height: 30.0,
              ),
              loginButton,
              forgotLabel,
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
