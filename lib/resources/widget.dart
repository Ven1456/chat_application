import 'package:flutter/material.dart';
const textInputDecoration = InputDecoration(
labelStyle: TextStyle(color:Colors.black),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue)
  ),
  focusedBorder: OutlineInputBorder(
borderSide: BorderSide(color: Colors.blue)
  ),
    errorBorder: OutlineInputBorder(
borderSide: BorderSide(color: Colors.red),
),
  focusedErrorBorder:  OutlineInputBorder(
borderSide: BorderSide(color: Colors.red),
),

);

void nextPage (context,page){
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}
void replaceScreen (context,page){
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
}

void showSnackbar(context, color , message ) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar (

    content : Text(message),
    backgroundColor : color,
    action: SnackBarAction(
      label: "close",
      onPressed: () {},

    ),
    duration: Duration(seconds: 2),

  ));
}

