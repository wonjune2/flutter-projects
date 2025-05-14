import 'package:flutter/material.dart';
import 'package:random_dice/const/colors.dart';
import 'package:random_dice/screen/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        sliderTheme: SliderThemeData(
          thumbColor: primaryColor,
          activeTrackColor: primaryColor,
          inactiveTrackColor: primaryColor.withValues(alpha: 0.3),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: backgroundColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: secondaryColor,
        ),
      ),
      home: HomeScreen(),
    ),
  );
}
