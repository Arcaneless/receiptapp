

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:receiptapp/com/arcaneless/login/login_button.dart';
import 'package:receiptapp/com/arcaneless/login/password_field.dart';
import 'package:receiptapp/com/arcaneless/login/username_field.dart';
import 'package:receiptapp/com/arcaneless/main.dart';
import 'package:receiptapp/com/arcaneless/overlay-wheel.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';

class Login extends StatefulWidget{

  Login({
    Key key,
    this.onLoggedIn
  }) : super(key: key);

  final Function(UserCredential) onLoggedIn;

  @override
  State createState() => LoginState();
}

class LoginState extends State<Login> {

  String _username = "";
  String _password = "";
  bool _usernameValidate = true;
  bool _passwordValidate = true;
  bool _userNotFound = false;
  String _notFoundText = "";
  bool _isLoading = false;
  SpinWheel _spinWheel = SpinWheel();

  @override
  void initState() {
    super.initState();
    _spinWheel = SpinWheel();
  }

  void onUsernameFieldChange(String value) {
    _username = value;
    toggleUserNotFoundText(false);
    setState(() {
      _usernameValidate = true;
    });
  }

  void onPasswordFieldChange(String value) {
    _password = value;
    toggleUserNotFoundText(false);
    setState(() {
      _passwordValidate = true;
    });
  }

  void onLogin(BuildContext context) async {

    // username
    if (_username == "" || _username.contains(new RegExp(r' [^A-Za-z0-9]*'))) {
      // regex check invalid
      setState(() {
        _usernameValidate = false;
      });
    }
    // password
    if (_password == "" || _password.contains(' ')) {
      setState(() {
        _passwordValidate = false;
      });
    }

    if (!_usernameValidate || !_passwordValidate) return;

    // set spinwheel
    setState(() {
      _isLoading = true;
      _spinWheel.overlaySpinWheel(context);
    });
    await firebaseAuth.signInWithEmailAndPassword(
        email: _username + "@yuentat.com", // username hack tho
        password: _password
    ).then((cred) {
      setState(() {
        _isLoading = false;
        _spinWheel.overlayRemove(context);
      });

      Logger().i('Log-in completed: ${cred.user.uid}');
      firebaseAnalytics.logLogin(loginMethod: 'username');
      widget.onLoggedIn(cred);
    }, onError: (error) {
      setState(() {
        _isLoading = false;
        _spinWheel.overlayRemove(context);
      });

      Logger().i("Error occured ${error.code}");
      if (error.code == "user-not-found" || error.code == "wrong-password") {
        firebaseAnalytics.logEvent(name: 'login_failed');
        toggleUserNotFoundText(true);
      }
    }).timeout(Duration(seconds: 10), onTimeout: () {
      Logger().i("Timed out");
      firebaseAnalytics.logEvent(name: 'login_timeout');
      _spinWheel.overlayRemove(context);
    });

  }

  void toggleUserNotFoundText(bool set) {
    setState(() {
      _userNotFound = set;

      if (_userNotFound) {
        _notFoundText = "不正確用戶名或密碼";
      } else {
        _notFoundText = "";
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(
                bottom: 20,
                right: 20,
              ),
              alignment: Alignment.bottomRight,
              width: size.width,
              height: 200,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Color(0xfff45d27),
                        Color(0xfff5851f)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100)
                  )
              ),
              child: Text(
                Parameters.company_name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
            ),
            Text(
              _notFoundText,
              style: TextStyle(fontSize: 15, color: Colors.red),
            ),
            SizedBox(height: size.height * 0.1,),
            UsernameField(onChange: onUsernameFieldChange, validate: _usernameValidate,),
            SizedBox(height: 10,),
            PasswordField(onChange: onPasswordFieldChange, validate: _passwordValidate,),
            SizedBox(height: 50,),
            LoginButton(
              text: "登入",
              press: () => onLogin(context),
            )
          ],
        ),
      )
    );
  }
}