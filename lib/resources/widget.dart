import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
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

class AlertBoxReuse extends StatelessWidget {
  final String titleText;
  final String subTitleText;
  final String leaveTitleText;
  final String cancelTitleText;
  final VoidCallback leaveOnTap;
  final VoidCallback cancelOnTap;

  const AlertBoxReuse({
    Key? key,
    required this.leaveOnTap,
    required this.titleText,
    required this.subTitleText,
    required this.leaveTitleText,
    required this.cancelTitleText,
    required this.cancelOnTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  titleText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  subTitleText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21))),
                      onPressed: () {
                        cancelOnTap();
                      },
                      child: Text(
                        cancelTitleText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21))),
                      onPressed: () {
                        leaveOnTap();
                      },
                      child: Text(
                        leaveTitleText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                ],
              );
            });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: 40,
              width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  color: Colors.blueGrey),
              child: const Icon(Icons.logout)),
          const SizedBox(
            width: 10,
          ),
          const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )
        ],
      ),
    );
  }
}

class IconButtonAlertReuse extends StatelessWidget {
  final String titleText;
  final String subTitleText;
  final String leaveTitleText;
  final String cancelTitleText;
  final VoidCallback leaveOnTap;
  final VoidCallback cancelOnTap;

  const IconButtonAlertReuse({
    Key? key,
    required this.leaveOnTap,
    required this.titleText,
    required this.subTitleText,
    required this.leaveTitleText,
    required this.cancelTitleText,
    required this.cancelOnTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    titleText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    subTitleText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21))),
                        onPressed: () {
                          cancelOnTap();
                        },
                        child: Text(
                          cancelTitleText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21))),
                        onPressed: () {
                          leaveOnTap();
                        },
                        child: Text(
                          leaveTitleText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                  ],
                );
              });
        },
        child: const Icon(Icons.exit_to_app));
  }
}

reusableButton(double height, double width, VoidCallback onTap, String text) {
  return SizedBox(
    height: height,
    width: width,
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21))),
        onPressed: () {
          onTap();
        },
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        )),
  );
}

class ReusableTextField extends StatefulWidget {
  final double width;
  final String labelText;
  final bool? obSecureText;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? textInputFormatter;
  final TextEditingController? textEditingController;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const ReusableTextField(
      {Key? key,
      required this.width,
      this.textEditingController,
      required this.labelText,
      this.onChanged,
      this.validator,
      this.obSecureText,
      this.suffixIcon,
      this.prefixIcon,
      this.textInputType,
      this.textInputFormatter,
      this.onTap})
      : super(key: key);

  @override
  State<ReusableTextField> createState() => _ReusableTextFieldState();
}

class _ReusableTextFieldState extends State<ReusableTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextFormField(
          obscureText: (widget.obSecureText!) ? true : false,
          controller: widget.textEditingController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: widget.textInputType,
          inputFormatters: widget.textInputFormatter,
          // key: _emailKey,
          decoration: textInputDecoration.copyWith(
            suffixIcon: widget.suffixIcon,
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon,
          ),
          onChanged: widget.onChanged,
          validator: widget.validator),
    );
  }
}

boldTitleText(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  );
}

semiBoldSubTitleText(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
  );
}

imageBuild(String path) {
  return Image.asset(
    path,
    height: 180,
  );
}

navLinkText(VoidCallback onTap, String text) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(left: 180.0),
      child: Text.rich(TextSpan(
        text: text,
        style: const TextStyle(color: Colors.purpleAccent, fontSize: 14),
      )),
    ),
  );
}

richTextSpan(String text1, String text2, VoidCallback onTap) {
  return Text.rich(TextSpan(
      text: text1,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      children: <TextSpan>[
        TextSpan(
            text: text2,
            style: const TextStyle(color: Colors.purpleAccent, fontSize: 14),
            recognizer: TapGestureRecognizer()..onTap = onTap)
      ]));
}
