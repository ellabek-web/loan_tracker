import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: Color(0xFFFFFFFF),
      drawerTheme: DrawerThemeData(
        
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Color(0xFFDBE2EF), // Background color of the TextField
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            color: Colors.black, // Set focused border color
            width: 2.0, // Optional: you can set a custom width
          ),
        ),

        suffixIconColor: Color(0xFF737070), // Color of the suffix icon
        labelStyle: TextStyle(
          color: Color(0xFF737070), // Color of the label text
        ),

        floatingLabelStyle: TextStyle(
          color: Color(0xFF265A97), // Input text color, same as label
        ),

        // style: TextStyle(
        //       color: Colors.black, // Change this to your desired text color
        //       fontSize: 16, // Optional: set your desired font size
        //     ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Color(0xFF265A97), // Sets text color to black
        ),
      ),

      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFFFFFFFF),
        onPrimary: Colors.black, //tex color
        secondary: Color(0xFF71B2FF),
        onSecondary: Color(0xFF737070),
        error: Color(0xFFCF6679,),
        onError: Color(0xFF71B2FF),
        surface: Colors.white, //app background color
        onSurface: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        color: Color(0xFF265A97),
        titleTextStyle: TextStyle(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF265A97),
          textStyle: TextStyle(color: Colors.white),

          // minimumSize: Size(150, 50),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      inputDecorationTheme: InputDecorationTheme(
        // fillColor: Color(0xFFDBE2EF), // Background color of the TextField
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            color: Color(0xFFFFFFFF), // Set focused border color
            width: 2.0, // Optional: you can set a custom width
          ),
        ),

        // suffixIconColor: Color(0xFF737070), // Color of the suffix icon
        // labelStyle: TextStyle(
        //   color: Color(0xFF737070), // Color of the label text
        // ),

        // floatingLabelStyle: TextStyle(
        //   color: Color(0xFF265A97), // Input text color, same as label
        // ),

        // style: TextStyle(
        //       color: Colors.black, // Change this to your desired text color
        //       fontSize: 16, // Optional: set your desired font size
        //     ),
      ),
      colorScheme: ColorScheme(
        //primary: Color(0xFF71B2FF), // Main primary color (default purple)
        primary: Color(0xFFFFFFFF),
        secondary: Color(0xFF71B2FF), // Secondary color (default teal)
        surface: Color(0xFF121212), // Background color for the app (dark gray)
        error: Color(0xFFCF6679,), // Error color for error messages (default red)
        onPrimary: Color(
          0xFF000000,
        ), // Text color on primary background (black)
        onSecondary: Color(
          0xFF000000,
        ), // Text color on secondary background (black)
        onSurface: Color(0xFFFFFFFF), // Text color on background (white)
        onError: Color(0xFF000000), // Text color on error background (black)
        brightness: Brightness.dark, // Brightness setting
      ),
      appBarTheme: AppBarTheme(
        color: Color(0xFF265A97),
        titleTextStyle: TextStyle(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF265A97),
          textStyle: TextStyle(color: Colors.white),
        ),
      ),
      useMaterial3: true,
    );
  }
}

// Primary 265A97
// second(card) 71B2FF
// insind search 737070
//inside search text + icons  737070
//text in login 737070
