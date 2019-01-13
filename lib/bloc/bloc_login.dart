import 'dart:async';

import 'package:flutter_app/model/web/login_form_data.dart';
import 'package:flutter_app/utils/validators_login.dart';
import 'package:rxdart/rxdart.dart';

class BlocLogin extends Object with LoginValidators {
  final _accountController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _captchaController = BehaviorSubject<String>();

  Function(String) get accountChanged => _accountController.sink.add;

  Function(String) get passwordChanged => _passwordController.sink.add;

  Function(String) get captchaChanged => _captchaController.sink.add;

  //Another way
  // StreamSink<String> get accountChanged => _accountController.sink;
  // StreamSink<String> get passwordChanged => _passwordController.sink;

  Stream<String> get account => _accountController.stream.transform(accountValidator);

  Stream<String> get password => _passwordController.stream.transform(passwordValidator);

  Stream<String> get captcha => _captchaController.stream.transform(captchaValidator);

  Stream<bool> get submitCheck =>
      Observable.combineLatest3(account, password, captcha, (a, p, c) => true);

  dispose() {
    // todo close
    _accountController?.close();
    _passwordController?.close();
    _captchaController?.close();
  }
}
