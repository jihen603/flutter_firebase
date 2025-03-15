import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled123/src/utils/theme/widget_themes/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: CustomTextTheme.lightTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style:ElevatedButton.styleFrom() ),
  );

  static ThemeData darkTheme = ThemeData
    (brightness: Brightness.dark,
    textTheme: CustomTextTheme.darkTextTheme,
  );
}