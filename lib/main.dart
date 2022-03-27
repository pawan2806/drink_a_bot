
import 'package:drink_a_bot/landing_page.dart';
import 'package:flutter/material.dart';

import './MainPage.dart';

void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
            fontFamily: 'Circular',
            primaryColor: Color(0xFF7579E7),
            accentColor:Color(0xFF7579E7),
            cursorColor: Color(0xFF7579E7),
            textSelectionHandleColor:Color(0xFF7579E7)),
      home: LandingPage()
        );
  }
}