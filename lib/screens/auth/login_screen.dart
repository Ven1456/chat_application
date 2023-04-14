import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/RegisterPage.dart';
import 'package:chat/screens/ui/Forgot_Password_screen.dart';
import 'package:chat/screens/ui/homeScreen.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:toast/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String pass = "";
  String email = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  bool _passwordVisible = false;

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
        // LOADING ANIMATION
            ? _buildLoadingAnimation()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 65.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // CHAT TEXT
                        _buildChatText(),
                        const SizedBox(
                          height: 10,
                        ),
                        // SUB TITLE TEXT
                        _buildSubTitleText(),
                        // IMAGE
                        _buildImage(),
                        // EMAIL TEXT FIELD
                        _buildEmailTextField(),
                        const SizedBox(
                          height: 15,
                        ),
                        // PASSWORD TEXT FIELD
                        _buildPasswordTextField(),
                        const SizedBox(
                          height: 15,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        // FORGOT PASSWORD  TEXT
                        _buildForgotPassword(context),
                        const SizedBox(
                          height: 5,
                        ),
                        // SIGN IN BUTTON
                        _buildSignInButton(),
                        const SizedBox(
                          height: 5,
                        ),
                        // REGISTER AND DON'T HAVE AN ACCOUNT BUTTON TEXT
                        _buildRegisterAndDoNotHaveAccountText(context)
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // REGISTER AND DON'T HAVE AN ACCOUNT BUTTON TEXT EXTRACT AS A METHOD
  Text _buildRegisterAndDoNotHaveAccountText(BuildContext context) {
    return Text.rich(TextSpan(
        text: "Don't Have An Account? ",
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: <TextSpan>[
          TextSpan(
              text: "Register ",
              style: const TextStyle(color: Colors.black, fontSize: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  nextPage(context, const RegisterPage());
                })
        ]));
  }

  // SIGN IN BUTTON EXTRACT AS A METHOD
  SizedBox _buildSignInButton() {
    return SizedBox(
      width: 320,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21))),
          onPressed: () {
            login();
          },
          child: const Text("Sign in ")),
    );
  }

  // FORGOT PASSWORD EXTRACT AS A METHOD
  GestureDetector _buildForgotPassword(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextPage(context, const ForgotPasswordScreen());
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 180.0),
        child: Text.rich(TextSpan(
          text: "Forgot Password? ",
          style: TextStyle(color: Colors.black, fontSize: 14),
        )),
      ),
    );
  }

  // PASSWORD TEXT FIELD EXTRACT AS A METHOD
  SizedBox _buildPasswordTextField() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: passTextEditingController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: !_passwordVisible,
        // key: _passkey,
        decoration: textInputDecoration.copyWith(
            labelText: "Password",
            prefixIcon: const Icon(Icons.security),
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
              child: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
            )),
        onChanged: (val) {
          setState(() {
            pass = val;
          });
        },
        validator: (val) {
          return val!.length < 6 ? "Please Enter Atleast 6 Characters" : null;
        },
      ),
    );
  }

  // EMAIL TEXT FIELD  EXTRACT AS A METHOD
  SizedBox _buildEmailTextField() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: emailTextEditingController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // key: _emailKey,
        decoration: textInputDecoration.copyWith(
          labelText: "Email",
          prefixIcon: const Icon(Icons.email),
        ),
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
      ),
    );
  }

  // IMAGE EXTRACT AS A METHOD
  Image _buildImage() {
    return Image.asset(
      "assets/images/chat.jpg",
      height: 350,
    );
  }

  // SUB TITLE EXTRACT AS A METHOD
  Text _buildSubTitleText() {
    return const Text(
      "Login Now To See What Their Are Talking ",
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  // CHAT TEXT  EXTRACT AS A METHOD
  Text _buildChatText() {
    return const Text(
      "Chats",
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }

  // LOADING ANIMATION  EXTRACT AS A METHOD
  Center _buildLoadingAnimation() {
    return Center(
        child: SizedBox(
            height: 150,
            width: 100,
            child: Lottie.network(
                "https://assets1.lottiefiles.com/packages/lf20_p8bfn5to.json")));
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithUsernamePassword(email, pass)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot = await DatabaseServices(
                  uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserEmail(email);

          await SharedPref.saveUserLoginStatus(true);

          await SharedPref.saveUserEmail(email);
          await SharedPref.saveUserName(snapshot.docs[0]["fullName"]);
          await SharedPref.saveProfilePic(snapshot.docs[0]["profilePic"]);
          // ignore: use_build_context_synchronously
          nextPage(context, const HomeScreen());
        } else {
          ToastContext toastContext = ToastContext();
          toastContext.init(context);
          Toast.show(
            value,
            duration: Toast.lengthShort,
            rootNavigator: true,
            gravity: Toast.bottom,
            webShowClose: true,
            backgroundColor: Colors.red,
          );
          /*  showSnackbar(context, Colors.red, value);*/
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
