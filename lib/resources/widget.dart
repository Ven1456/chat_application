import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TEXT INPUT DECORATION
const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black),
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
  ),
);
// GO TO NEXT PAGE
nextPage(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

// REPLACE THE SCREEN
void replaceScreen(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

// SNACK BAR
void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: color,
    action: SnackBarAction(
      label: "close",
      disabledTextColor: Colors.white,
      onPressed: () {},
    ),
    duration: const Duration(seconds: 2),
  ));
}

// TEXT FORMATTERS
class TrimTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.startsWith(" ")
            ? newValue.text.replaceAll(" ", "")
            : newValue.text,
        selection: newValue.text.startsWith(" ")
            ? TextSelection.collapsed(
                offset: newValue.text.replaceAll(" ", "").length)
            : newValue.selection);
  }
}

// TEXT FORMATTERS
class NewLineTrimTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.startsWith(RegExp('[\n]'))
            ? newValue.text.trim()
            : newValue.text,
        selection: newValue.text.startsWith(RegExp('[\n]'))
            ? TextSelection.collapsed(offset: newValue.text.trim().length)
            : newValue.selection);
  }
}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
// 21/04/23

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}