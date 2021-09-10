import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/common/v2ex_client.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/models/web/login_form_data.dart';
import 'package:flutter_app/network/dio_web.dart';
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

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final TextEditingController _2faController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();

  FocusNode passwordTextFieldNode, captchaTextFieldNode;

  int _loginState = 0; //登录按钮状态，0 默认初始状态；1 登录中；2 登录结束
  Animation _animation;
  AnimationController _controller;
  final GlobalKey _globalKey = GlobalKey();
  double _width = double.maxFinite;

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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: Form(
              autovalidateMode: AutovalidateMode.disabled,
              key: _formKey, //开启自动校验
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    // 用户名
                    TextFormField(
                        autofillHints: [AutofillHints.username],
                        autofocus: true,
                        controller: _accountController,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(passwordTextFieldNode),
                        decoration: InputDecoration(
                          labelText: S.of(context).account,

                          // hintText: S.of(context).enterAccount,
                        ),
                        // 校验用户名
                        validator: (v) {
                          return v.trim().isNotEmpty ? null : '用户名不能为空';
                        }),
                    SizedBox(
                      height: 18.0,
                    ),
                    PasswordField(_passwordFieldKey, _pwdController,
                        passwordTextFieldNode, captchaTextFieldNode),
                    SizedBox(
                      height: 18.0,
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                              controller: _captchaController,
                              focusNode: captchaTextFieldNode,
                              onEditingComplete: () => FocusScope.of(context)
                                  .requestFocus(FocusNode()),
                              decoration: InputDecoration(
                                labelText: S.of(context).captcha,
                                // hintText: S.of(context).enterCaptcha,
                              ),
                              //校验密码
                              validator: (v) {
                                return v.trim().length > 3 ? null : '验证码不能少于4位';
                              }),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: loginFormData != null &&
                                    loginFormData.bytes.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      // 点击刷新验证码
                                      refreshCaptcha();
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      child: Image.memory(
                                        loginFormData.bytes,
                                        height: 55.0,
                                        width: 160.0,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(Icons.sync),
                                    onPressed: () {
                                      refreshCaptcha();
                                    })),
                      ],
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    ButtonTheme(
                      key: _globalKey,
                      height: 48.0,
                      minWidth: _width,
                      child: RaisedButton(
                        animationDuration: Duration(milliseconds: 1000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.all(0),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            if (loginFormData != null) {
                              animateButton();

                              // 让登录按钮有loading效果
                              setState(() {
                                _loginState = 1;
                              });

                              loginFormData.usernameInput =
                                  _accountController.text;
                              loginFormData.passwordInput = _pwdController.text;
                              loginFormData.captchaInput =
                                  _captchaController.text;
                              //var formData = bloc.submit(loginFormData);
                              print(loginFormData.toString());
                              var loginResult =
                                  await DioWeb.loginPost(loginFormData);
                              if (loginResult == 'true') {
                                // 登录成功
                                // 让登录按钮有完成✅效果
                                setState(() {
                                  _loginState = 2;
                                });
                                Timer(Duration(milliseconds: 800), () {
                                  Navigator.of(context).pop(true);
                                  Fluttertoast.showToast(
                                      msg: S.of(context).toastLoginSuccess(
                                          SpHelper.sp.getString(SP_USERNAME)),
                                      timeInSecForIosWeb: 2,
                                      gravity: ToastGravity.CENTER);
                                });
                              } else if (loginResult == '2fa') {
                                // 让登录按钮恢复初始状态
                                setState(() {
                                  _loginState = 0;
                                });
                                // 弹出两步验证对话框
                                Platform.isIOS
                                    ? await showCupertinoDialog(
                                        context: context,
                                        builder: (BuildContext contextDialog) {
                                          return CupertinoAlertDialog(
                                            title: Text('两步验证登录'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                    '你的 V2EX 账号已经开启了两步验证，请输入验证码继续'),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                CupertinoTextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 6,
                                                  placeholder: '验证码',
                                                  controller: _2faController,
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              CupertinoButton(
                                                  onPressed: () async {
                                                    Navigator.pop(
                                                        contextDialog);
                                                    await V2exClient.logout();
                                                  },
                                                  child: Text('取消')),
                                              CupertinoButton(
                                                  onPressed: () async {
                                                    var twoFAResult =
                                                        await DioWeb.twoFALogin(
                                                            _2faController
                                                                .text);
                                                    if (twoFAResult) {
                                                      Navigator.pop(
                                                          contextDialog);
                                                      await Fluttertoast
                                                          .showToast(
                                                        msg: S
                                                            .of(context)
                                                            .toastLoginSuccess(
                                                                SpHelper.sp
                                                                    .getString(
                                                                        SP_USERNAME)),
                                                        timeInSecForIosWeb: 2,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                      );
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    } else {
                                                      await Fluttertoast
                                                          .showToast(
                                                        msg: '验证失败，请重新输入验证码',
                                                        timeInSecForIosWeb: 2,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                      );
                                                    }
                                                  },
                                                  child: Text('确定')),
                                            ],
                                          );
                                        })
                                    : showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext contextDialog) {
                                          return AlertDialog(
                                            title: Text('两步验证登录'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                    '你的 V2EX 账号已经开启了两步验证，请输入验证码继续'),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                CupertinoTextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 6,
                                                  placeholder: '验证码',
                                                  controller: _2faController,
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              CupertinoButton(
                                                  onPressed: () async {
                                                    Navigator.pop(
                                                        contextDialog);
                                                    await V2exClient.logout();
                                                  },
                                                  child: Text('取消')),
                                              CupertinoButton(
                                                  onPressed: () async {
                                                    var twoFAResult =
                                                        await DioWeb.twoFALogin(
                                                            _2faController
                                                                .text);
                                                    if (twoFAResult) {
                                                      Navigator.pop(
                                                          contextDialog);
                                                      await Fluttertoast
                                                          .showToast(
                                                        msg: S
                                                            .of(context)
                                                            .toastLoginSuccess(
                                                                SpHelper.sp
                                                                    .getString(
                                                                        SP_USERNAME)),
                                                        timeInSecForIosWeb: 2,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                      );
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    } else {
                                                      await Fluttertoast
                                                          .showToast(
                                                        msg: '验证失败，请重新输入验证码',
                                                        timeInSecForIosWeb: 2,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                      );
                                                    }
                                                  },
                                                  child: Text('确定')),
                                            ],
                                          );
                                        });
                              } else {
                                // 登录失败
                                await refreshCaptcha();
                                // 让登录按钮恢复初始状态
                                setState(() {
                                  _loginState = 0;
                                });
                              }
                            }
                          }
                        },
                        onLongPress: () {
                          if (loginFormData != null) {
                            var future =
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => WebviewPage(
                                  'https://www.v2ex.com/auth/google?once=' +
                                      loginFormData.once),
                            ));
                            future.then((value) {
                              // 直接close登录页则value为null；登录成功 value 为 true
                              if (value != null && value) {
                                Navigator.of(context).pop(true);
                              }
                            });
                          } else {
                            Fluttertoast.showToast(
                                msg: '登录遇到一些问题...',
                                timeInSecForIosWeb: 2,
                                gravity: ToastGravity.CENTER);
                          }
                        },
                        child: buildButtonProgressChild(context),
                      ),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () => launch(
                            'https://www.v2ex.com/signup',
                            statusBarBrightness:
                                Platform.isIOS ? Brightness.light : null,
                          ),
                          child: Text(
                            S.of(context).signup,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        InkWell(
                          onTap: () => launch(
                            'https://www.v2ex.com/forgot',
                            statusBarBrightness:
                                Platform.isIOS ? Brightness.light : null,
                          ),
                          child: Text(
                            S.of(context).forgetPassword,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget buildButtonProgressChild(BuildContext context) {
    if (_loginState == 0) {
      return Text(S.of(context).login, style: TextStyle(color: Colors.white));
    } else if (_loginState == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      print('wml:$_loginState');
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void animateButton() {
    var initialWidth = _globalKey.currentContext.size.width;

    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animation = Tween(begin: 0.0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48) * _animation.value);
        });
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _pwdController.dispose();
    _captchaController.dispose();
    _2faController.dispose();
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }
}

// 去除拖拽时的波纹效果
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class PasswordField extends StatefulWidget {
  final Key fieldKey;
  final TextEditingController _pwdController;
  final FocusNode passwordTextFieldNode, captchaTextFieldNode;

  const PasswordField(this.fieldKey, this._pwdController, this.passwordTextFieldNode,
      this.captchaTextFieldNode);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        autofillHints: [AutofillHints.password],
        key: widget.fieldKey,
        controller: widget._pwdController,
        focusNode: widget.passwordTextFieldNode,
        textInputAction: TextInputAction.next,
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(widget.captchaTextFieldNode),
        decoration: InputDecoration(
            labelText: S.of(context).password,
            // hintText: S.of(context).enterPassword,
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
          return v.trim().isNotEmpty ? null : '密码不能为空';
        });
  }
}
