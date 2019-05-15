import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/web/login_form_data.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/theme/theme_data.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'page_web.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey = GlobalKey<FormFieldState<String>>();

  FocusNode passwordTextFieldNode, captchaTextFieldNode;

  int _loginState = 0; //登录按钮状态，0 默认初始状态；1 登录中；2 登录结束

  @override
  void initState() {
    super.initState();
    refreshCaptcha();
    passwordTextFieldNode = FocusNode();
    captchaTextFieldNode = FocusNode();
  }

  // 刷新（首次获取）验证码
  Future refreshCaptcha() async {
    var formData = await DioWeb.parseLoginForm();
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
      backgroundColor: MyTheme.isDark ? Colors.grey[850] : Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: MyTheme.isDark ? Brightness.dark : Brightness.light,
        iconTheme: IconThemeData(
          color: MyTheme.isDark ? Colors.white : Colors.black,
        ),
        backgroundColor: MyTheme.isDark ? Colors.grey[850] : Colors.white,
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

                          // hintText: MyLocalizations.of(context).enterAccount,
                        ),
                        // 校验用户名
                        validator: (v) {
                          return v.trim().length > 0 ? null : "用户名不能为空";
                        }),
                    SizedBox(
                      height: 18.0,
                    ),
                    PasswordField(_passwordFieldKey, _pwdController, passwordTextFieldNode, captchaTextFieldNode),
                    SizedBox(
                      height: 18.0,
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
                                // hintText: MyLocalizations.of(context).enterCaptcha,
                              ),
                              //校验密码
                              validator: (v) {
                                return v.trim().length > 3 ? null : "验证码不能少于4位";
                              }),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: loginFormData != null && loginFormData.bytes.length > 0
                                ? GestureDetector(
                                    child: new ClipRRect(
                                      child: Image.memory(
                                        loginFormData.bytes,
                                        height: 55.0,
                                        width: 160.0,
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                    ),
                                    onTap: () {
                                      // 点击刷新验证码
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
                      height: 40.0,
                    ),
                    ButtonTheme(
                      child: RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            if (loginFormData != null) {
                              // 让登录按钮有loading效果
                              setState(() {
                                _loginState = 1;
                              });

                              loginFormData.usernameInput = _accountController.text;
                              loginFormData.passwordInput = _pwdController.text;
                              loginFormData.captchaInput = _captchaController.text;
                              //var formData = bloc.submit(loginFormData);
                              print(loginFormData.toString());
                              bool loginResult = await DioWeb.loginPost(loginFormData);
                              if (loginResult) {
                                // 登录成功
                                // 让登录按钮有完成✅效果
                                setState(() {
                                  _loginState = 2;
                                });
                                Fluttertoast.showToast(
                                    msg: MyLocalizations.of(context).toastLoginSuccess(SpHelper.sp.getString(SP_USERNAME)),
                                    timeInSecForIos: 2,
                                    gravity: ToastGravity.CENTER);
                                Timer(Duration(milliseconds: 800), () {
                                  Navigator.of(context).pop(true);
                                });
                              } else {
                                // 登录失败
                                refreshCaptcha();
                                // 让登录按钮恢复初始状态
                                setState(() {
                                  _loginState = 0;
                                });
                              }
                            }
                          }
                        },
                        child: buildButtonProgressChild(context),
                      ),
                      height: 55.0,
                      minWidth: 400.0,
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          child: Text(
                            MyLocalizations.of(context).signup,
                            style:
                                TextStyle(color: MyTheme.isDark ? Theme.of(context).unselectedWidgetColor : Colors.black54),
                          ),
                          // 注册 -> 跳转到注册web页面
                          onTap: () => launch("https://www.v2ex.com/signup",
                              statusBarBrightness: Platform.isIOS ? Brightness.light : null),
                        ),
                        InkWell(
                          child: Text(
                            MyLocalizations.of(context).forgetPassword,
                            style:
                                TextStyle(color: MyTheme.isDark ? Theme.of(context).unselectedWidgetColor : Colors.black54),
                          ),
                          // 忘记密码 -> 跳转到重置密码web页面
                          onTap: () => launch("https://www.v2ex.com/forgot",
                              statusBarBrightness: Platform.isIOS ? Brightness.light : null),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    InkWell(
                      child: Image(
                        image: AssetImage(
                          'assets/images/btn_google_signin.png',
                        ),
                        height: 40,
                      ),
                      onTap: () {
                        if (loginFormData != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                WebviewPage('https://www.v2ex.com/auth/google?once=' + loginFormData.once),
                          ));
                        }
                      },
                    ),
                  ],
                ),
              )),
        ),
        behavior: MyBehavior(),
      ),
    );
  }

  Widget buildButtonProgressChild(BuildContext context) {
    if (_loginState == 0) {
      return Text(MyLocalizations.of(context).login, style: TextStyle(color: Colors.white));
    } else if (_loginState == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
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

class PasswordField extends StatefulWidget {
  final Key fieldKey;
  final TextEditingController _pwdController;
  final FocusNode passwordTextFieldNode, captchaTextFieldNode;

  PasswordField(this.fieldKey, this._pwdController, this.passwordTextFieldNode, this.captchaTextFieldNode);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        key: widget.fieldKey,
        controller: widget._pwdController,
        focusNode: widget.passwordTextFieldNode,
        textInputAction: TextInputAction.next,
        onEditingComplete: () => FocusScope.of(context).requestFocus(widget.captchaTextFieldNode),
        decoration: InputDecoration(
            labelText: MyLocalizations.of(context).password,
            // hintText: MyLocalizations.of(context).enterPassword,
            suffixIcon: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                semanticLabel: _obscureText ? 'show password' : 'hide password',
              ),
            )),
        obscureText: _obscureText,
        //校验密码
        validator: (v) {
          return v.trim().length > 0 ? null : "密码不能为空";
        });
  }
}
