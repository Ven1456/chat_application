import 'dart:async';

import 'package:chat/resources/widget.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:toast/toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  String email = "";
  bool _isLoading = false;
  bool isEmail = true;
  bool isButton = false;
  bool isCenter = false;

  Timer? _timer;
  int _start = 180;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            Navigator.pop(context);
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor.fromHex('#FFFFFF'),
      // APP BAR
      appBar: _buildAppBar(),
      body:  Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    sizeBoxH80(),
                    // IMAGE
                    imageBuild("assets/images/forgot.jpg", 200),
                   sizeBoxH100(),

                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: isButton
                            ? Container()
                            :
                        // EMAIL  TEXT FIELD
                        ReusableTextField(
                          width: MediaQuery.of(context).size.width * 0.85,
                          obSecureText: false,
                          labelText: "Enter Your Email",
                          prefixIcon: Icon(Icons.email),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                          validator: (val) {
                            return RegExp(
                                r"^[a-zA-Z\d.a-zA-Z!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z\d]+\.[a-zA-Z]+")
                                .hasMatch(val!)
                                ? null
                                : "Please Enter Correct Email";
                          },
                        )),
                   sizeBoxH15(),
                    isButton
                        ? Container()
                        :
                    // SEND REQUEST BUTTON
                    reusableButton(40, 180, () {
                      forgot();
                    }, "Send Request"),
                    isButton
                        ? Column(
                      children: [
                        // TIMER ICON
                        _buildTimerIcon(),
                        // TIMER START ICON
                        _buildTimeStartText(),
                        sizeBoxH10(),
                        // DESCRIPTION TEXT
                        semiBoldSubTitleText(
                          "                   Please Check Your Email "
                              "\n If Link is Not Their Please Check Spam Box"
                              "\n            Set Must 6 Character Password",
                        ),
                        sizeBoxH10(),
                        // CLOSE ICON
                        reusableButton(40, 100, () {
                          Navigator.pop(context);
                        }, "Close"),
                      ],
                    )
                        : Container()
                  ],
                ),
              ),
            ),
          ),
          if(_isLoading)
            _buildLoadingAnimation()
        ],
      ),
    );
  }


  // TIMER START TEXT  EXTRACT AS A METHOD
  Text _buildTimeStartText() {
    return Text(
      "$_start",
      style: const TextStyle(fontSize: 25),
    );
  }

  // TIMER ICON  EXTRACT AS A METHOD
  Center _buildTimerIcon() {
    return const Center(
        child: Icon(
      Icons.timer,
      size: 150,
    ));
  }

  // LOADING ANIMATION   EXTRACT AS A METHOD
  Container _buildLoadingAnimation() {
    return Container(
        color: Colors.black.withOpacity(0.1),
        child: Center(
          child: Lottie.network(
              "https://assets4.lottiefiles.com/private_files/lf30_fjjj1m44.json", height: 180),
        ));
  }

  // APP BAR  EXTRACT AS A METHOD
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Reset Password"),
      centerTitle: true,
    );
  }

  forgot() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      authService.resetEmail(email).then((value) {
        if (value == null) {
          ToastContext toastContext = ToastContext();
          toastContext.init(context);
          Toast.show(
            "Reset Password link sent to Email Successfully",
            duration: Toast.lengthShort,
            rootNavigator: true,
            gravity: Toast.bottom,
            webShowClose: true,
            backgroundColor: Colors.green,
          );
          setState(() {
            isButton = true;
            startTimer();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ToastContext toastContext = ToastContext();
          toastContext.init(context);
          Toast.show(
            value.toString(),
            duration: Toast.lengthShort,
            rootNavigator: true,
            gravity: Toast.bottom,
            webShowClose: true,
            backgroundColor: Colors.red,
          );
        }
      });
    }
  }
}
