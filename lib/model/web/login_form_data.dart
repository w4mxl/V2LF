// node 下的item
import 'dart:typed_data';

class LoginFormData {
  String username = '';
  String password = '';
  String once = '';
  String captcha = '';
  Uint8List bytes;

  String usernameInput = '';
  String passwordInput = '';
  String captchaInput = '';

  @override
  String toString() {
    return '\n$username:$usernameInput,\n$password:$passwordInput,\n$captcha:$captchaInput\nonce:$once\nnext:/';
  }
}
