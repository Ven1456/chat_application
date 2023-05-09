import 'dart:async';
import 'package:chat/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
     setValue();
    Timer(
        const Duration(seconds: 3),
            () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                isLogin ? const BottomSheetTest() : const LoginPage())
            )
    );
  }
  void setValue() async {
    final prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt('counter') ?? 0;
    prefs.setInt('counter', launchCount + 1);
    if (launchCount == 0) {
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
              isLogin ? const BottomSheetTest() : const IntroScreen()));//setState to refresh or move to some other page
    } else {
   return null;
    }
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
                "https://assets10.lottiefiles.com/packages/lf20_SLZG2B.json",
              errorBuilder: (BuildContext context,
                  Object exception,
                  StackTrace? stackTrace) {
                return Image.asset(
                  'assets/images/register.jpg',
                  height: 15,
                  width: 15,
                  fit: BoxFit.cover,
                );
              },
            )),
      ),
    );
  }
}
