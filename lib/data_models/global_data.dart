import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

ValueNotifier<String> errorCode = ValueNotifier<String>("Well");

showToast(BuildContext context, String message) {
  Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.TOP,
    textColor: (Theme.of(context).brightness == Brightness.dark)
        ? Colors.black
        : Colors.white,
    backgroundColor: (Theme.of(context).brightness == Brightness.dark)
        ? Colors.white
        : Colors.black,
  );
}

List<String> emailProviders = [
  "@gmail.com",
  "@yahoo.com",
  "@hotmail.com",
  "@hotmail.co.uk",
  "@msn.com",
  "@yahoo.co.uk",
  "@yahoo.co.in",
  "@live.com",
  "@outlook.com",
  "@live.co.uk",
  "@googlemail.com",
  "@yahoo.in",
  ".co.uk",
];

List<Color> notesThemeColors = const [
  Color(0xFFC8CCCF),
  Color(0xFFDFEBF5),
  Color(0xFFEFE7D5),
  Color(0xFFE3CFD3),
  Color(0xFFF4CBC6),
  Color(0xFFF4BEAF),
  Color(0xFFEACCBD),
  Color(0xFFF4BEAF),
  Color(0xFFE7E5DA),
];

List<Color> notesDarkThemeColors = const [
  Color(0xFF825D70),
  Color(0xFF7E5C70),
  Color(0xFF2D2F40),
  Color(0xFF343A40),
  Color(0xFF002513),
  Color(0xFF002B47),
  Color(0xFF33415C),
  Color(0xFF393D3F),
  Color(0xFF021B2B),
];
