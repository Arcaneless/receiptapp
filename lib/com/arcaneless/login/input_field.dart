

import 'package:flutter/material.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';

class InputField extends StatelessWidget {

  InputField({
    Key key,
    this.child
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: size.width * 0.8,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(29),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 3
              )
            ]
        ),
        child: child
    );
  }
}