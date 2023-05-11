
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/homeScreen/homeScreen.dart';
import 'package:chat/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<PageViewModel> getPages()
  {
    return [
      PageViewModel(
          image: Image.asset ("assets/images/img1.jpg"),
          title:"Welcome to our chat app!",
          body:" Say goodbye to SMS fees and say hello to free and unlimited messaging with our chat app.",
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
            imageFlex: 3,
            imagePadding: EdgeInsets.all(35),
            imageAlignment: Alignment.center,

          )

      ),

      PageViewModel(
          image: Image.asset("assets/images/img2.jpg"),
          title: "Join the conversation and share your thoughts with our vibrant community of users.",
          body:"Discover new people and make new friends with our easy-to-use chat features.",
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
            imagePadding: EdgeInsets.all(35),
            imageFlex: 3,
            imageAlignment: Alignment.center,
          )

      ),
      PageViewModel(
          image: Image.asset("assets/images/img4.jpg",),
          title: "Say goodbye to SMS fees ",
          body:"With end-to-end encryption, you can trust that your conversations are private and secure.",
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
            imagePadding: EdgeInsets.all(35),
            imageFlex: 3,
            imageAlignment: Alignment.center,
          )

      )

    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        done:  const Text("Done" ,style: TextStyle(fontSize: 22,color: Colors.cyan),),
        onDone: () {
        nextPagePushAndRemoveUntil(context, const LoginPage());
        },
        pages:getPages(),
        globalBackgroundColor: Colors.white,
        showNextButton: false,
        showSkipButton: true,
        skip: const Text("Skip",style: TextStyle(fontSize: 22,color: Colors.cyan),),

      ),
    );
  }
}
