
import 'package:flutter/material.dart';

class FormSubtitle extends StatelessWidget {

  FormSubtitle(this.text, {Key key}) : super(key : key);

  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold
      ),
    );
  }
}

class FormBigTitle extends StatelessWidget {

  FormBigTitle(this.text, {Key key}) : super(key : key);

  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold
      ),
    );
  }
}

class FormSpacer extends SizedBox {
  FormSpacer() : super(height : 10); // width changable
}