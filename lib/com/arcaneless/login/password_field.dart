

import 'package:flutter/material.dart';
import 'package:receiptapp/com/arcaneless/login/input_field.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';

class PasswordField extends StatefulWidget {

  PasswordField({
    Key key,
    this.onChange,
    this.validate
  }) : super(key: key);

  final ValueChanged<String> onChange;
  final bool validate;

  @override
  State createState() => PasswordFieldState();


}

class PasswordFieldState extends State<PasswordField> {

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _visible = false;
  }
  void onVisibility() {
    setState(() {
      _visible = !_visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InputField(
      child: TextField(
        obscureText: !_visible,
        onChanged: widget.onChange,
        cursorColor: Parameters.themeColor,
        decoration: InputDecoration(
            hintText: "密碼",
            icon: Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_visible ? Icons.visibility : Icons.visibility_off),
              onPressed: onVisibility,
            ),
            errorText: !widget.validate ? "密碼錯誤" : null
        ),
      ),
    );
  }
}