import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey =  GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:Padding(
        padding:  EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Text("Chats",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)

            ],
          ),
        ),
      ),
    );
  }
}
