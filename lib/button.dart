import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final text;
  final function;

  MyButton({this.function, this.text});

  @overrride
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: function,
        child: Text(text),
      );
    }