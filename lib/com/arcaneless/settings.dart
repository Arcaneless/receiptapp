

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:receiptapp/com/arcaneless/main.dart';
import 'package:receiptapp/com/arcaneless/overlay-wheel.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';

class Settings extends StatefulWidget {

  Settings({
    Key key,
    this.onLogout
  }) : super(key: key);

  final Function onLogout;

  @override
  State createState() => SettingsState();
}


class SettingsState extends State<Settings> {

  SpinWheel _spinWheel = SpinWheel();

  @override
  void initState() {
    super.initState();
    _spinWheel = SpinWheel();
  }

  void onLogout(BuildContext context) {
    _spinWheel.overlaySpinWheel(context);

    firebaseAuth.signOut().then((value) {
      _spinWheel.overlayRemove(context);

      Logger().i("Logged out");
      firebaseAnalytics.logEvent(name: 'sign_out');

      widget.onLogout();
    }, onError: (error) {
      _spinWheel.overlayRemove(context);
      Logger().e(error);
    }).timeout(Duration(seconds: 5), onTimeout: () {
      _spinWheel.overlayRemove(context);

      Logger().i("Timed out");
      firebaseAnalytics.logEvent(name: 'sign_out_timed_out');
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.symmetric(vertical: 10),
            width: size.width * 0.8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: FlatButton(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                color: Parameters.themeColor,
                onPressed: () => onLogout(context),
                child: Text(
                  "登出",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}