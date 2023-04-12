import 'package:chat/main.dart';
import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:chat/screens/ui/homeScreen.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:toast/toast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
//  GlobalKey<FormFieldState<String>> _eKey = GlobalKey<FormFieldState<String>>();
//  GlobalKey<FormFieldState<String>> _passwordKey = GlobalKey<FormFieldState<String>>();
//  GlobalKey<FormFieldState<String>> _fullNameKey = GlobalKey<FormFieldState<String>>();

class _RegisterPageState extends State<RegisterPage> {
  String email = "";
  String password = "";
  String fullName = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  final registerFormKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ?  Center(child: SizedBox(
          height: 150,
          width: 100,
          child: Lottie.network("https://assets1.lottiefiles.com/packages/lf20_p8bfn5to.json"))) : SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 65.0),
            child: Form(
              key: registerFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Chats",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Register Now To See What Their Are Talking ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Image.asset(
                    "assets/images/register.jpg",
                    height: 250,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      decoration: textInputDecoration.copyWith(
                        labelText: "Full Name",
                        prefixIcon: const Icon(Icons.account_circle),
                      ),
                      onChanged: (val) {
                        setState(() {
                          fullName = val;
                        });
                      },
                      validator: (val) {
                        if (val!.isNotEmpty && val.length >2) {
                          return null;
                        } else {
                          return "Please Enter Your Full Name ";
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    width: 320,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: !_passwordVisible,
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
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          )),


                      onChanged: (val) {
                        setState(() {
                          password = val;
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
                  SizedBox(
                    width: 310,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21))),
                        onPressed: () {
                          register();
                        },
                        child: const Text("Register Now")),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text.rich(TextSpan(
                      text: "Already Have An Account? ",
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                            text: "Login Now ",
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                nextPage(context, const LoginPage());
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

  void register() async{
    if (registerFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.registerWithEmailPass(fullName, email, password).then((value) async{
        if(value == true)
          {
            await SharedPref.saveUserLoginStatus(true);
            await SharedPref.saveUserName(fullName);
            await SharedPref.saveUserEmail(email);
            // ignore: use_build_context_synchronously
            nextPage(context, const HomeScreen());
          }
        else
          {
        setState(() {
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
          _isLoading = false;
        });
          }
      });
    }
  }
}
