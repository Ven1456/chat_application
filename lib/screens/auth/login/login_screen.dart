import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/fogot_Password/Forgot_Password_screen.dart';
import 'package:chat/screens/auth/register/RegisterPage.dart';
import 'package:chat/screens/bottomSheet/BottomSheet.dart';
import 'package:chat/services/authentication_services/auth_service.dart';
import 'package:chat/services/database_services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../../../utils/CustomValidators.dart';

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
            child:Column(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                     sizeBoxH80(),
                      // CHAT TEXT
                      boldTitleText("Chats"),
                     sizeBoxH10(),
                      // SUB TITLE TEXT
                      semiBoldSubTitleText(
                          "Login Now To See What Their Are Talking "),
                      sizeBoxH45(),
                      // IMAGE
                      imageBuild("assets/images/chat.jpg",180),
                      sizeBoxH80(),
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
                        validator:(val)=> CustomValidators.email(val)
                      ),
                      sizeBoxH15(),
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
                        validator: (val)=> CustomValidators.password(val),
                      ),
                     sizeBoxH15(),
                      // FORGOT PASSWORD  TEXT
                      navLinkText(() {
                        nextPage(context, const ForgotPasswordScreen());
                      }, "Forgot Password?"),
                      sizeBoxH10(),
                      // SIGN IN BUTTON
                      reusableButton(
                          50, MediaQuery.of(context).size.width * 0.85, () {
                        login();
                      }, "Sign in "),
                      sizeBoxH10(),
                      // REGISTER AND DON'T HAVE AN ACCOUNT BUTTON TEXT
                      richTextSpan("Don't have An Account? ", "Register ",
                              () {
                           nextPagePushAndRemoveUntil(context, const RegisterPage());
                          })
                    ],
                  ),
                ),
              ],
            ),
        ),
          ),
          if(_isLoading)
            loadingAnimation()
        ],
      ),
    );
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
          nextPagePushAndRemoveUntil(context, const BottomSheetTest());
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
