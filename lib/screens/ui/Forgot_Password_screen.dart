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
  String imagePath =
      "https://img.freepik.com/free-vector/secure-login-concept-illustration_114360-4685.jpg?w=740&t=st=1681119046~exp=1681119646~hmac=30b8f90d889d274933a6493c9dfe8a01fedb390b4891e2b32c1d7e4769f6ab22";

  bool _isLoading = false;
  bool isEmail = true;
  bool isButton = false;

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
      // APP BAR
      appBar: _buildAppBar(),
      body: _isLoading
          ?
          // LOADING ANIMATION
          _buildLoadingAnimation()
          : Form(
              key: formKey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // IMAGE
                    _buildImage(),
                    const SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      width: 320,
                      child: isButton
                          ? Container()
                          :
                          // EMAIL  TEXT FIELD
                          _buildEmailTextFormField(),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    isButton
                        ? Container()
                        :
                        // SEND REQUEST BUTTON
                        _buildSendRequestButton(),
                    isButton
                        ? Column(
                            children: [
                              // TIMER ICON
                              _buildTimerIcon(),
                              // TIMER START ICON
                              _buildTimeStartText(),
                              const SizedBox(
                                height: 10,
                              ),
                              // DESCRIPTION TEXT
                              _buildDescriptionText(),
                              const SizedBox(
                                height: 10,
                              ),
                              // CLOSE ICON
                              _buildCloseButton(context),
                            ],
                          )
                        : Container()
                  ],
                ),
              ),
            ),
    );
  }

  // CLOSE BUTTON EXTRACT AS A METHOD
  ElevatedButton _buildCloseButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Close"));
  }

  // DESCRIPTION TEXT  EXTRACT AS A METHOD
  Text _buildDescriptionText() {
    return const Text(
      "                   Please Check Your Email "
      "\n If Link is Not Their Please Check Spam Box"
      "\n            Set Must 6 Character Password",
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  // SEND REQUEST BUTTON  EXTRACT AS A METHOD
  ElevatedButton _buildSendRequestButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21))),
        onPressed: () {
          forgot();
        },
        child: const Text("Send Request"));
  }

  // EMAIL  TEXT FIELD  EXTRACT AS A METHOD
  TextFormField _buildEmailTextFormField() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
      decoration: textInputDecoration.copyWith(
          labelText: "Enter Your Email", prefixIcon: const Icon(Icons.email)),
    );
  }

  // IMAGE EXTRACT AS A METHOD
  ClipRRect _buildImage() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(250),
        child: Image.asset(
          "assets/images/reset.jpg",
          height: 300,
        ));
  }

  // LOADING ANIMATION   EXTRACT AS A METHOD
  Center _buildLoadingAnimation() {
    return Center(
        child: SizedBox(
            height: 150,
            width: 100,
            child: Lottie.network(
                "https://assets1.lottiefiles.com/packages/lf20_p8bfn5to.json")));
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
