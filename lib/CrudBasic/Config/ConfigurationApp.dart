import 'dart:math';

import 'package:flutter/material.dart';

class ConfigurationApp {
  static const colorInput = Color.fromARGB(255, 223, 242, 255);
  static const colorBtn = Color.fromARGB(255, 0, 96, 100);
  static const primaryColor = Color(0xFF390da0);
  static const successColor = Color.fromARGB(255, 0, 96, 100);

  static const backgroundColor = Color(0xFFcfe0fa);
  static const whiteColor = Colors.white;
  static const blackColor = Colors.black;
  static const dangerColor = Colors.red;
  static const warningColor = Colors.orange;

  static randomColor() {
    return Color(Random().nextInt(0xffffffff));
  }
}
