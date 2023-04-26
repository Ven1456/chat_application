import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/RegisterPage.dart';
import 'package:chat/screens/ui/BottomSheet.dart';
import 'package:chat/screens/ui/Forgot_Password_screen.dart';
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
      backgroundColor: HexColor.fromHex('#FFFFFF'),
      body: SafeArea(
        child: Center(
          child: _isLoading
              // LOADING ANIMATION
              ? Stack(children: [_buildLoadingAnimation()])
              : Stack(
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          // CHAT TEXT
                          boldTitleText("Chats"),
                          const SizedBox(
                            height: 10,
                          ),
                          // SUB TITLE TEXT
                          semiBoldSubTitleText(
                              "Login Now To See What Their Are Talking "),
                          const SizedBox(
                            height: 40,
                          ),
                          // IMAGE
                          imageBuild("assets/images/chat.jpg"),
                          const SizedBox(
                            height: 60,
                          ),
                          // EMAIL TEXT FIELD
                          ReusableTextField(
                            obSecureText: false,
                            width: MediaQuery.of(context).size.width * 0.85,
                            textEditingController: emailTextEditingController,
                            labelText: "Email",
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                            prefixIcon: const Icon(Icons.email),
                            validator: (val) {
                              return RegExp(
                                          r"^[a-zA-Z\d.a-zA-Z!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z\d]+\.[a-zA-Z]+")
                                      .hasMatch(val!)
                                  ? null
                                  : "Please Enter Correct Email";
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          // PASSWORD TEXT FIELD
                          ReusableTextField(
                            obSecureText: !_passwordVisible,
                            width: MediaQuery.of(context).size.width * 0.85,
                            textEditingController: passTextEditingController,
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.security),
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              child: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                pass = val;
                              });
                            },
                            validator: (val) {
                              return val!.length < 6
                                  ? "Please Enter Atleast 6 Characters"
                                  : null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          // FORGOT PASSWORD  TEXT
                          navLinkText(() {
                            nextPage(context, const ForgotPasswordScreen());
                          }, "Forgot Password?"),
                          const SizedBox(
                            height: 10,
                          ),
                          // SIGN IN BUTTON
                          reusableButton(
                              50, MediaQuery.of(context).size.width * 0.85, () {
                            login();
                          }, "Sign in "),
                          const SizedBox(
                            height: 10,
                          ),
                          // REGISTER AND DON'T HAVE AN ACCOUNT BUTTON TEXT
                          richTextSpan("Don't have An Account? ", "Register ",
                              () {
                            nextPage(context, const RegisterPage());
                          })
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
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
          await SharedPref.saveUserPhone(snapshot.docs[0]["phone"]);
          await SharedPref.saveUserDob(snapshot.docs[0]["dob"]);
          /*   await SharedPref.saveProfilePic(snapshot.docs[0]["profilePic"]);*/
          // ignore: use_build_context_synchronously
          nextPage(context, const BottomSheetTest());
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
