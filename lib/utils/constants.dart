import 'package:flutter/material.dart';

class Constants {
  static String appName = "POLY NOTES";

  //Colors for theme
  static Color lightPrimary = Colors.yellow;
  static Color darkPrimary = Colors.black;
  static Color accentColor = Color(0xffFAFAFA);
  static Color darkAccent = Color(0xffFAFAFA);
  static Color lightBG = Color(0xfffcfcff);
  static Color darkBG = Colors.black;
  static Color textColor = Color(0xff656D79);
  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    accentColor: accentColor,
    cursorColor: accentColor,
    scaffoldBackgroundColor: lightBG,
    bottomAppBarColor: accentColor,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
        caption: TextStyle(color: textColor),
        title: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    cursorColor: darkAccent,
    bottomAppBarColor: darkPrimary,
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      textTheme: TextTheme(
        title: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
