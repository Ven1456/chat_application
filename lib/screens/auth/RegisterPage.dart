import 'package:chat/main.dart';
import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:chat/screens/ui/homeScreen.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
final formKey = GlobalKey<FormState>();
// GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
//  GlobalKey<FormFieldState<String>> _eKey = GlobalKey<FormFieldState<String>>();
//  GlobalKey<FormFieldState<String>> _passwordKey = GlobalKey<FormFieldState<String>>();
//  GlobalKey<FormFieldState<String>> _fullNameKey = GlobalKey<FormFieldState<String>>();
String email = "";
String password = "";
String fullName = "";
bool _isLoading = false;
AuthService authService = AuthService();
class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 65.0),
            child: Form(
              key: formKey,
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
                    width: 350,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      decoration: textInputDecoration.copyWith(
                        labelText: "Full Name",
                        prefixIcon: const Icon(Icons.email),
                      ),
                      onChanged: (val) {
                        setState(() {
                          fullName = val;
                        });
                      },
                      validator: (val) {
                        if (val!.isNotEmpty) {
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
                    width: 350,
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
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
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
                    width: 350,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: true,
                      decoration: textInputDecoration.copyWith(
                        labelText: "Password",

                        prefixIcon: const Icon(Icons.security),
                      ),
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
                    width: 350,
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
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.registerWithEmailPass(fullName, email, password).then((value) async{
        if(value == true)
          {
            await SharedPref.saveUserLoginStatus(true);
            await SharedPref.saveUserName(fullName);
            await SharedPref.saveUserEmail(email);
            nextPage(context, HomeScreen());
          }
        else
          {
        setState(() {
          showSnackbar(context, Colors.red, value);
          _isLoading = false;
        });
          }
      });
    }
  }
}
