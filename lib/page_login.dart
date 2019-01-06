import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_login.dart';
import 'package:flutter_app/model/web/login_form_data.dart';
import 'package:flutter_app/network/api_web.dart';

// 2018/12/30 21:23
// 用 Charles 分析了一下 V2ex 网站登录的过程
// 通过模拟网站登录的过程，实现登录。登录后保存cookie，为了后面实现评论和回复作准备
// name password captcha once

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

LoginFormData loginFormData;

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    refreshCaptcha();
  }

  // 刷新（首次获取）验证码
  Future refreshCaptcha() async {
    var formData = await v2exApi.parseLoginForm();
    setState(() {
      loginFormData = formData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocLogin();
    final logo = Image.asset("assets/images/logo_v2lf.png");

    final userName = StreamBuilder<String>(
      stream: bloc.account,
      builder: (context, snapshot) => TextField(
            onChanged: bloc.accountChanged,
            autofocus: false,
            decoration: InputDecoration(
                errorText: snapshot.error,
                hintText: 'account',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
          ),
    );

    final password = StreamBuilder<String>(
      stream: bloc.password,
      builder: (context, snapshot) => TextField(
            onChanged: bloc.passwordChanged,
            autofocus: false,
            obscureText: true,
            decoration: InputDecoration(
                errorText: snapshot.error,
                hintText: 'password',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
          ),
    );

    final captcha = Row(
      children: <Widget>[
        Flexible(
            child: StreamBuilder<String>(
                stream: bloc.captcha,
                builder: (context, snapshot) => TextField(
                      onChanged: bloc.captchaChanged,
                      autofocus: false,
                      decoration: InputDecoration(
                          errorText: snapshot.error,
                          hintText: 'captcha',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
                    ))),
        Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: loginFormData != null && loginFormData.bytes.length > 0
                ? GestureDetector(
                    child: Image.memory(
                      loginFormData.bytes,
                      width: 145.0,
                      height: 40.0,
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
      builder: (context, snapshot) => Material(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(30.0),
            shadowColor: Colors.blueGrey.shade100,
            elevation: 5.0,
            child: MaterialButton(
              color: Colors.blueGrey,
              minWidth: double.infinity,
              height: 48.0,
              disabledColor: Colors.grey,
              onPressed: snapshot.hasData
                  ? () {
                      // 登录
                      // todo 非空检查-登录判断结果
                      print("xxx");
                    }
                  : null,
              child: Text('Log In', style: TextStyle(color: Colors.white)),
            ),
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

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: Colors.red[300],
          mini: true,
          child: Icon(Icons.close),
        ),
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  logo,
                  SizedBox(
                    height: 70.0,
                  ),
                  userName,
                  SizedBox(
                    height: 10.0,
                  ),
                  password,
                  SizedBox(
                    height: 10.0,
                  ),
                  captcha,
                  SizedBox(
                    height: 40.0,
                  ),
                  loginButton,
                  forgotLabel,
                ],
              )),
        ));
  }
}
