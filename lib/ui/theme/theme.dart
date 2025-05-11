import 'package:flutter/material.dart';

///
/// Definition of App colors.
///
class RaceColors {
  static const Color primary = Color(0xFF5D63D1);
  static const Color secondary = Color(0xFFCFD1F2);

  static Color lightGrey = const Color(0xFFEDEDED);

  static Color darkGrey = const Color.fromARGB(255, 97, 95, 97);
  static Color neutral = const Color.fromARGB(255, 163, 161, 163);

  static Color grey = const Color(0xFFE2E2E2);

  static Color white = Colors.white;
  static Color black = Colors.black;

  static Color red = Colors.red;

  static Color get backGroundColor {
    return RaceColors.primary;
  }

  static Color get textNormal {
    return RaceColors.darkGrey;
  }

  static Color get iconNormal {
    return RaceColors.neutral;
  }

  static Color get disabled {
    return RaceColors.grey;
  }
}

///
/// Definition of App text styles.
///
class RaceTextStyles {
  static TextStyle heading =
      TextStyle(fontSize: 32, fontWeight: FontWeight.w500);

  static TextStyle title = TextStyle(fontSize: 24, fontWeight: FontWeight.w400);

  static TextStyle subtitle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w400);

  static TextStyle body = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle subbody =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle label = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
}

///
/// Definition of App spacings, in pixels.
/// Bascially small (S), medium (m), large (l), extra large (x), extra extra large (xxl)
///
class RaceSpacings {
  static const double xs = 15;

  static const double s = 20;
  static const double m = 26;
  static const double l = 30;
  static const double xl = 60;
  static const double xxl = 94;

  static const double radius = 10;
  //static const double radiusLarge = 24;
}

class BlaSize {
  static const double icon = 30;
}

///
/// Definition of App Theme.
///
ThemeData appTheme = ThemeData(
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: Colors.white,
);
