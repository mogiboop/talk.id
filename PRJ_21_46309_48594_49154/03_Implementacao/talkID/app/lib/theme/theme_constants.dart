import 'package:flutter/material.dart';

const color1 = Color.fromRGBO(255, 245, 225, 1);
const color2 = Color.fromRGBO(255, 105, 105, 1);
const color3 = Color.fromRGBO(200, 0, 54, 1);
const color4 = Color.fromRGBO(12, 24, 68, 1);
const iconColor = Color.fromRGBO(12, 24, 68, 1);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: color1,
    primary: color3,
    secondary: color4,
    primaryContainer: color2,
    shadow: color3,
    outline: iconColor,
  ),
  iconTheme: const IconThemeData(
    color: iconColor,
  ),
  textTheme: const TextTheme(
    displayMedium: TextStyle(color: color4),
    displaySmall: TextStyle(color: color4),
    titleLarge: TextStyle(color: color4, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: color4, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: color4),
    headlineSmall: TextStyle(color: color4),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: color1,
    selectedItemColor: iconColor,
    unselectedItemColor: color3,
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: color3,
    inactiveTrackColor: iconColor,
    thumbColor: color3,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    backgroundColor: iconColor,
    foregroundColor: color3,
  )),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: iconColor)),
  inputDecorationTheme: const InputDecorationTheme(
    iconColor: iconColor,
    counterStyle: TextStyle(color: color4),
    hintStyle: TextStyle(color: Colors.grey),
    labelStyle: TextStyle(color: color4),
    floatingLabelStyle: TextStyle(color: color4),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide: BorderSide(
          color: iconColor,
          style: BorderStyle.solid,
          width: 2.0,
        )),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
      borderSide: BorderSide(
        color: color4,
        style: BorderStyle.solid,
        width: 2.0,
      ),
    ),
  ),
);

const dColor1 = Color.fromRGBO(45, 50, 80, 1);
const dColor2 = Color.fromRGBO(66, 71, 105, 1);
const dColor3 = Color.fromRGBO(112, 119, 161, 1);
const dColor4 = Color.fromRGBO(238, 237, 235, 1);
const dIconColor = Color.fromRGBO(238, 237, 235, 1);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    background: dColor1,
    primary: dColor3,
    secondary: dColor4,
    primaryContainer: dColor3,
    shadow: dColor4,
    outline: dIconColor,
  ),
  iconTheme: const IconThemeData(
    color: dIconColor,
  ),
  textTheme: const TextTheme(
    displayMedium: TextStyle(color: dColor4),
    displaySmall: TextStyle(color: dColor4),
    titleLarge: TextStyle(color: dColor4, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: dColor4, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: dColor4),
    headlineSmall: TextStyle(color: dColor4),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: dColor1,
    selectedItemColor: iconColor,
    unselectedItemColor: dColor4,
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: dColor3,
    inactiveTrackColor: dIconColor,
    thumbColor: dColor3,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    backgroundColor: dColor3,
    foregroundColor: dIconColor,
  )),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: dIconColor)),
);
