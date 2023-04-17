import 'dart:async';

import 'package:chat/screens/auth/login_screen.dart';
import 'package:chat/screens/ui/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../resources/Shared_Preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLogin = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isUserLogin();
    Timer(
        const Duration(seconds: 3),
            () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                isLogin ?  HomeScreen() : const LoginPage())));
  }
  isUserLogin() async {
    await SharedPref.isUserLogin().then((value) {
      if (value != null) {
        isLogin = value;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
            height: 850,
            width: 550,
            child: Lottie.network(
                "https://assets10.lottiefiles.com/packages/lf20_SLZG2B.json")),
      ),
    );
  }
}
