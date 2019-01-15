import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bloc/bloc_login.dart';
import 'package:flutter_app/model/web/login_form_data.dart';
import 'package:flutter_app/network/dio_singleton.dart';

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
  @override
  void initState() {
    super.initState();
    refreshCaptcha();
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
    // 全屏
    SystemChrome.setEnabledSystemUIOverlays([]);
    final bloc = BlocLogin();
    final logo = Image.asset("assets/images/logo_v2lf.png");

    final userName = StreamBuilder<String>(
      stream: bloc.account,
      builder: (context, snapshot) => TextField(
            onChanged: (text) {
              bloc.accountChanged(text);
              fieldAccount = text;
            },
            autofocus: false,
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
            autofocus: false,
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
                      autofocus: false,
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
      builder: (context, snapshot) => RaisedButton(
            color: Colors.blueGrey,
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 40.0, right: 40.0),
            onPressed: snapshot.hasData
                ? () {
                    if (loginFormData != null &&
                        fieldAccount != null &&
                        fieldPassword != null &&
                        fieldCaptcha != null) {
                      loginFormData.usernameInput = fieldAccount;
                      loginFormData.passwordInput = fieldPassword;
                      loginFormData.captchaInput = fieldCaptcha;
                      //var formData = bloc.submit(loginFormData);
                      print(loginFormData.toString());
                      dioSingleton.loginPost(loginFormData);
                      // Fluttertoast.showToast(msg: '$loginPost');
                    }
                  }
                : null,
            child: Text('Log In', style: TextStyle(color: Colors.white)),
          ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        // todo 忘记密码 -> 跳转到重置密码web页面
      },
    );

    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                logo,
                SizedBox(
                  height: 60.0,
                ),
                userName,
                SizedBox(
                  height: 20.0,
                ),
                password,
                SizedBox(
                  height: 20.0,
                ),
                captcha,
                SizedBox(
                  height: 40.0,
                ),
                loginButton,
                forgotLabel,
              ],
            )),
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () {
                // bloc.dispose(); // todo
                Navigator.of(context).pop();
              },
              backgroundColor: Colors.grey[400],
              mini: true,
              child: Icon(Icons.close),
            )
          : null,
    );
  }

  @override
  void dispose() {
    // 取消全屏
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}
