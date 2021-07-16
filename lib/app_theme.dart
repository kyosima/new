import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Utils/Colors.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: white_color,
    primaryColor: primaryColor,
    primaryColorDark: primaryColor,
    errorColor: Colors.red,
    hoverColor: Colors.grey,
    fontFamily: GoogleFonts.nunito().fontFamily,
    appBarTheme: AppBarTheme(color: app_Background, iconTheme: IconThemeData(color: textColorPrimary)),
    colorScheme: ColorScheme.light(primary: primaryColor, primaryVariant: primaryColor),
    cardTheme: CardTheme(color: Colors.white),
    iconTheme: IconThemeData(color: textColorPrimary),
    textTheme: TextTheme(
      button: TextStyle(color: primaryColor),
      headline6: TextStyle(color: textColorPrimary),
      subtitle2: TextStyle(color: textColorSecondary),
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.white),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: appBackGroundColor,
    highlightColor: app_background_black,
    errorColor: Color(0xFFCF6676),
    appBarTheme: AppBarTheme(color: app_background_black, iconTheme: IconThemeData(color: white_color)),
    primaryColor: color_primary_black,
    accentColor: white_color,
    primaryColorDark: color_primary_black,
    hoverColor: Colors.black,
    fontFamily: GoogleFonts.nunito().fontFamily,
    colorScheme: ColorScheme.light(primary: app_background_black, onPrimary: card_background_black, primaryVariant: color_primary_black),
    cardTheme: CardTheme(color: scaffoldBakGroundColor),
    cardColor: scaffoldBakGroundColor,
    iconTheme: IconThemeData(color: white_color),
    textTheme: TextTheme(
      button: TextStyle(color: color_primary_black),
      headline6: TextStyle(color: white_color),
      subtitle2: TextStyle(color: Colors.white54),
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
  );
}
