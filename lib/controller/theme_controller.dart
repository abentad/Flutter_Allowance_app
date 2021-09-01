import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  //status bar
  Color _statusBarColor = Colors.white;
  Brightness _statusBarIconBrightness = Brightness.dark;
  Color get statusBarColor => _statusBarColor;
  Brightness get statusBarIconBrghtness => _statusBarIconBrightness;

  //main default theme
  ThemeData _defaultThemeData = ThemeData(
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
  );
  ThemeData get defaultThemeData => _defaultThemeData;

  //colors
  Color _primaryColor = Colors.black;
  Color get primaryColor => _primaryColor;
}
