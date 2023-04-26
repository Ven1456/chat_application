import 'package:chat/screens/ui/homeScreen.dart';
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
          image: Image.asset ("assets/images/img1.jpg",),
          title: "Music Learning  In Online",
          body:"Music Can Change The World",

          decoration: const PageDecoration(
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
            bodyTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
            imageFlex: 2,
            imagePadding: EdgeInsets.all(75),
            imageAlignment: Alignment.center,

          )

      ),

      PageViewModel(
          image: Image.asset("assets/images/img2.jpg"),
          title: "Music Learning Online",
          body:"Watch to Learn Music",
          footer: const Text("Music Is Good To Listening"),
          decoration: const PageDecoration(
            imagePadding: EdgeInsets.all(75),
            imageFlex: 2,
            imageAlignment: Alignment.center,
          )

      ),
      PageViewModel(
          image: Image.asset("assets/images/img3.jpg",height: 300,
            width: 1000,),
          title: "Music Learning Online",
          body:"Watch to Learn Music",
          footer: const Text("Music Is Good To Listening"),
          decoration: const PageDecoration(
            imagePadding: EdgeInsets.all(75),
            imageFlex: 2,
            imageAlignment: Alignment.center,
          )

      )

    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        done:  Text("Done" ),
        onDone: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        },
        pages:getPages(),
        globalBackgroundColor: Colors.white,
        showNextButton: false,
        showSkipButton: true,
        skip: Text("skip",),

      ),
    );
  }
}
