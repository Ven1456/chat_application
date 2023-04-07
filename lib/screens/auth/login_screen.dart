import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/RegisterPage.dart';
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

  // final GlobalKey<FormFieldState<String>> _emailKey = GlobalKey<FormFieldState<String>>();
  // final GlobalKey<FormFieldState<String>> _passkey = GlobalKey<FormFieldState<String>>();
  String pass = "";
  String email = "";
  bool _isLoading = false;
  AuthService authService= AuthService();
/*  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passTextEditingController = TextEditingController();*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ?Center(child: SizedBox(
            height: 150,
            width: 100,
            child: Lottie.network("https://assets1.lottiefiles.com/packages/lf20_p8bfn5to.json")))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 65.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "Chats",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Login Now To See What Their Are Talking ",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Image.asset(
                          "assets/images/chat.jpg",
                          height: 350,
                        ),
                        SizedBox(
                          width: 310,
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: 310,
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            obscureText: true,
                            // key: _passkey,
                            decoration: textInputDecoration.copyWith(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.security),
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
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                       /* Padding(
                          padding: const EdgeInsets.only(left:200.0),
                          child: GestureDetector(
                              onTap: (){

                              },
                              child: const Text("Forgot Password ? ",style: TextStyle(fontWeight: FontWeight.bold),)),
                        ),*/
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: 310,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(21))),
                              onPressed: () {
                                login();
                              },
                              child: const Text("Sign in ")),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text.rich(TextSpan(
                            text: "Don't Have An Account? ",
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Register ",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextPage(context, const RegisterPage());
                                    })
                            ]))
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // login() async {
  //   if (formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     await authService
  //         .loginWithUsernamePassword(email, password)
  //         .then((value) async {
  //       if (value == true) {
  //         QuerySnapshot snapshot =
  //         await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
  //             .gettingUserEmail(email);
  //         // saving the values to our shared preferences
  //         await SharedPref.saveUserLoginStatus(true);
  //         await SharedPref.saveUserEmail(email);
  //         await SharedPref.saveUserName(snapshot.docs[0]['fullName']);
  //         nextPage(context, HomeScreen());
  //       } else {
  //         showSnackbar(context, Colors.red, value);
  //         setState(() {
  //           _isLoading = false;
  //         });
  //       }
  //     });
  //   }
  // }
   login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.loginWithUsernamePassword(email, pass).then((value) async{
        if(value==true){
        QuerySnapshot snapshot = await DatabaseServices(uid:FirebaseAuth.instance.currentUser!.uid).gettingUserEmail(email);

        await SharedPref.saveUserLoginStatus(true);
        await SharedPref.saveUserEmail(email);
        await SharedPref.saveUserName(
          snapshot.docs[0]["fullName"]
        );
        nextPage(context, const HomeScreen());

        }
        else
          {
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
              _isLoading =false;
            });
          }
      });
    }
  }
}
