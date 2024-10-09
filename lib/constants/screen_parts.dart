import 'package:flutter/material.dart';

class ScreenParts {
  static AppBar appBar(String title) => AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
      );

  static const optionText = Text(
    'Or',
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    textAlign: TextAlign.center,
  );

  static const spacer = SizedBox(
    height: 24,
  );
}
