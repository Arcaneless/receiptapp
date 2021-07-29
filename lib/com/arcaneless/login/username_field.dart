
import 'package:flutter/material.dart';
import 'package:receiptapp/com/arcaneless/login/input_field.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';

class UsernameField extends StatelessWidget {

  UsernameField({
    Key key,
    this.onChange,
    this.validate
  }) : super(key: key);

  final ValueChanged<String> onChange;
  final bool validate;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InputField(
      child: TextField(
        onChanged: onChange,
        cursorColor: Parameters.themeColor,
        decoration: InputDecoration(
          hintText: "用戶名",
          icon: Icon(Icons.person),
          border: InputBorder.none,
          errorText: !validate ? "用戶名錯誤" : null,
        ),
      ),
    );
  }
}