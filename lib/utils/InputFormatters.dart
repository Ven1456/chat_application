// TEXT FORMATTERS
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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

//DOB
class DateTextFormatter extends TextInputFormatter {
  static const _maxChars = 8;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = _format(newValue.text, '-');
    var selection = updateCursorPosition(text);
    var error = _getErrorMessage(newValue.text);

    if (error != null) {
      // Show error message in a snackbar or dialog
      print(error);
    }

    return TextEditingValue(
      text: text,
      selection: selection,
      composing: TextRange.empty,
    );
  }

  String _format(String value, String separator) {
    value = value.replaceAll(separator, '');
    var newString = '';

    for (int i = 0; i < min(value.length, _maxChars); i++) {
      newString += value[i];
      if ((i == 1 || i == 3) && i != value.length - 1) {
        newString += separator;
      }
    }

    return newString;
  }

  TextSelection updateCursorPosition(String text) {
    return TextSelection.fromPosition(TextPosition(offset: text.length));
  }

  String? _getErrorMessage(String value) {
    if (value.length < 8) {
      return null;
    }

    var year = int.tryParse(value.substring(4, 8));
    if (year == null || year < 1900 || year > 2016) {
      return 'Invalid year';
    }

    var month = int.tryParse(value.substring(2, 4));
    if (month == null || month < 1 || month > 12) {
      return 'Invalid month';
    }

    var day = int.tryParse(value.substring(0, 2));
    if (day == null || day < 1 || day > 31) {
      return 'Invalid day';
    }

    var date = DateTime(year, month, day);
    if (date.month != month || date.day != day) {
      return 'Invalid date';
    }

    return null;
  }
}
