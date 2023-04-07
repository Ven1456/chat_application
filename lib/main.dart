import 'dart:async';

import 'package:chat/resources/Constants.dart';
import 'package:chat/screens/ui/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId));
  }
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogin = false;

  // This widget is the root of your application.
  @override
  /*void initState() {
    // TODO: implement initState
    super.initState();
    isUserLogin();
  }*/

  /*isUserLogin() async {
    await SharedPref.isUserLogin().then((value) {
      if (value != null) {
        isLogin = value;
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
     home: const SplashScreen(),
    );
  }
}
