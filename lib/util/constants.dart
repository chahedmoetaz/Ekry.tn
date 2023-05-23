import 'package:flutter/material.dart';

class Constants {

  //App related strings
  static String appName = "Dak App";


  //Colors for theme
  static Color lightPrimary = Colors.white;
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Colors.teal;
  static Color darkAccent = Colors.teal;
  static Color lightBG = Colors.white;
  static Color darkBG = Colors.black;


  static ThemeData lightTheme = ThemeData(
    fontFamily: "TimesNewRoman",
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    accentColor: lightAccent,
    cursorColor: darkPrimary,
    scaffoldBackgroundColor: lightBG,
    appBarTheme: AppBarTheme(

      elevation: 2,
      textTheme: TextTheme(
        title: TextStyle(
          fontFamily: "TimesNewRoman",
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: "TimesNewRoman",
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    cursorColor: lightPrimary,
    appBarTheme: AppBarTheme(
      color: Colors.grey.withOpacity(0.1),
      elevation: 2,
      textTheme: TextTheme(
        title: TextStyle(
          fontFamily: "TimesNewRoman",
          color: lightBG,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );


}





