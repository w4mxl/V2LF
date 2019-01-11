import 'dart:async';

mixin LoginValidators {
  var accountValidator =
      StreamTransformer<String, String>.fromHandlers(handleData: (account, sink) {
    if (account.length > 0) {
      sink.add(account);
    } else {
      sink.addError("Account can't be null.");
    }
  });

  var passwordValidator =
      StreamTransformer<String, String>.fromHandlers(handleData: (password, sink) {
    if (password.length > 0) {
      sink.add(password);
    } else {
      sink.addError("Password can't be null.");
    }
  });

  var captchaValidator =
      StreamTransformer<String, String>.fromHandlers(handleData: (captcha, sink) {
    if (captcha.length > 3) {
      sink.add(captcha);
    } else {
      sink.addError("Captcha length should be greater than 3 chars.");
    }
  });
}
