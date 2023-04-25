import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:chat/screens/ui/BottomSheet.dart';
import 'package:chat/screens/ui/homeScreen.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:toast/toast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController dateinput = TextEditingController();
  String email = "";
  String password = "";
  String phone = "";
  String dob = "";
  String fullName = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  final registerFormKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
@override
  void initState() {
  dateinput.text="";
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: SizedBox(
                  height: 150,
                  width: 100,
                  child: Lottie.network(
                      "https://assets1.lottiefiles.com/packages/lf20_p8bfn5to.json")))
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 65.0),
                  child: Form(
                    key: registerFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //CHAT TEXT
                        _buildChatText(),
                        const SizedBox(
                          height: 10,
                        ),
                        // REGISTER TEXT
                        _buildRegisterText(),
                        // REGISTER IMAGE
                        _buildImage(),
                        const SizedBox(
                          height: 15,
                        ),
                        // FULL NAME TEXT FIELD
                        _buildFullNameTextField(),
                        const SizedBox(
                          height: 15,
                        ),
                        // EMAIL TEXT FIELD
                        _buildEmailTextField(),
                        const SizedBox(
                          height: 15,
                        ),
                        _buildPasswordTextField(),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TextFormField(
                            keyboardType:TextInputType.phone,

                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: textInputDecoration.copyWith(
                              labelText: "Phone Number",
                              prefixIcon: const Icon(Icons.phone),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (val) {
                              setState(() {
                                phone = val;
                              });
                            },
                            validator: (val) {
                              return val!.length < 10
                                  ? "Please Enter Correct Phone Number"
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TextFormField(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900), //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime(2040));

                              if (pickedDate != null) {
                                print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                String formattedDate =
                                DateFormat('dd-MM-yyyy').format(pickedDate);
                                print("dhfsghfd:$formattedDate"); //formatted date output using intl package =>  2021-03-16
                                //you can implement different kind of Date Format here according to your requirement

                                setState(() {
                                  dateinput.text = formattedDate;
                                  dob = formattedDate;//set output date to TextField value.
                                });
                              } else {
                                print("Date is not selected");
                              }
                            },
                            readOnly: true,
                            controller: dateinput,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            decoration: textInputDecoration.copyWith(
                              labelText: "Date Of Birth",
                              prefixIcon: const Icon(Icons.calendar_month),
                            ),
                            validator: (val) {
                              return val!.isEmpty
                                  ? "Please Enter Your Date Of Birth"
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                        // REGISTER BUTTON
                        _buildRegisterButton(),
                        const SizedBox(
                          height: 15,
                        ),
                        // ALREADY HAVE AN ACCOUNT AND LOGIN TEXT
                        _buildAlreadyHaveAccountAndLoginText(context)
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
  // ALREADY HAVE AN ACCOUNT AND LOGIN TEXT EXTRACT AS A METHOD
  Text _buildAlreadyHaveAccountAndLoginText(BuildContext context) {
    return Text.rich(TextSpan(
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
        ]));
  }
// REGISTER BUTTON EXTRACT AS A METHOD
  SizedBox _buildRegisterButton() {
    return SizedBox(
      width: 310,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21))),
          onPressed: () {
            register();
          },
          child: const Text("Register Now")),
    );
  }
// PASSWORD TEXT FIELD EXTRACT AS A METHOD
  SizedBox _buildPasswordTextField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
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
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
            )),
        onChanged: (val) {
          setState(() {
            password = val;
          });
        },
        validator: (val) {
          return val!.length < 6 ? "Please Enter At 6 Characters" : null;
        },
      ),
    );
  }
// EMAIL TEXT FIELD EXTRACT AS A METHOD
  SizedBox _buildEmailTextField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
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
    );
  }
// FULL NAME TEXT FIELD EXTRACT AS A METHOD
  SizedBox _buildFullNameTextField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
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
          if (val!.isNotEmpty && val.length > 2) {
            return null;
          } else {
            return "Please Enter Your Full Name ";
          }
        },
      ),
    );
  }
// IMAGE EXTRACT AS A METHOD
  Image _buildImage() {
    return Image.asset(
      "assets/images/register.jpg",
      height: 250,
    );
  }
// REGISTER TEXT EXTRACT AS A METHOD
  Text _buildRegisterText() {
    return const Text(
      "Register Now To See What Their Are Talking ",
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }
// CHAT TEXT EXTRACT AS A METHOD
  Text _buildChatText() {
    return const Text(
      "Chats",
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
  // REGISTER METHOD
  void register() async {
    if (registerFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.registerWithEmailPass(fullName, email, password,phone,dob).then((value) async {
        if (value == true) {
          await SharedPref.saveUserLoginStatus(true);
          await SharedPref.saveUserName(fullName);
          await SharedPref.saveUserEmail(email);
          await SharedPref.saveUserPhone(phone);
          await SharedPref.saveUserDob(dob);
          // ignore: use_build_context_synchronously
          nextPage(context,  const BottomSheetTest());
        } else {
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
