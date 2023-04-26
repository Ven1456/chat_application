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
import 'package:intl_phone_field/intl_phone_field.dart';
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
  String phoneNumber = "";
  String dob = "";
  String fullName = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  final registerFormKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  @override
  void initState() {
    dateinput.text = "";
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor.fromHex('#FFFFFF'),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 65.0),
                child: Form(
                  key: registerFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //CHAT TEXT
                      boldTitleText("Chats"),
                      sizeBoxH10(),
                      // REGISTER TEXT
                      semiBoldSubTitleText(
                          "Register Now To See What Their Are Talking "),
                      // REGISTER IMAGE
                      imageBuild("assets/images/register.jpg", 180),
                      sizeBoxH15(),
                      // FULL NAME TEXT FIELD
                      ReusableTextField(
                        obSecureText: false,
                        width: MediaQuery.of(context).size.width * 0.85,
                        labelText: "Full Name",
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
                        prefixIcon: const Icon(Icons.account_circle),
                      ),
                      sizeBoxH15(),
                      // EMAIL TEXT FIELD
                      ReusableTextField(
                        obSecureText: false,
                        width: MediaQuery.of(context).size.width * 0.85,
                        labelText: "Email",
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
                        prefixIcon: const Icon(Icons.email),
                      ),
                      // _buildEmailTextField(),
                      sizeBoxH15(),
                      // PASSWORD TEXT FIELD
                      ReusableTextField(
                        obSecureText: !_passwordVisible,
                        width: MediaQuery.of(context).size.width * 0.85,
                        labelText: "Password",
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
                            password = val;
                          });
                        },
                        validator: (val) {
                          return val!.length < 6
                              ? "Please Enter At 6 Characters"
                              : null;
                        },
                        prefixIcon: const Icon(Icons.security),
                      ),
                      sizeBoxH15(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: TextFormField(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now()
                                    .subtract(Duration(days: 2555)),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2017));

                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('dd-MM-yyyy').format(pickedDate);
                              setState(() {
                                dateinput.text = formattedDate;
                                dob =
                                    formattedDate; //set output date to TextField value.
                              });
                            }
                          },
                          readOnly: true,
                          controller: dateinput,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      sizeBoxH15(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: IntlPhoneField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: textInputDecoration.copyWith(
                            labelText: "Phone Number",
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          initialCountryCode: 'IN',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (phone) {
                            setState(() {
                              phoneNumber = phone.completeNumber;
                            });
                          },
                        ),
                      ),

                      sizeBoxH15(),

                      // REGISTER BUTTON
                      reusableButton(
                          50, MediaQuery.of(context).size.width * 0.85, () {
                        register();
                      }, "Register Now "),
                      const SizedBox(
                        height: 15,
                      ),
                      // ALREADY HAVE AN ACCOUNT AND LOGIN TEXT
                      richTextSpan("Already have an Account? ", "Login Now ",
                          () {
                        nextPage(context, const LoginPage());
                      })
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: Lottie.network(
                      "https://assets4.lottiefiles.com/private_files/lf30_fjjj1m44.json",
                      height: 180),
                )),
        ],
      ),
    );
  }

  void register() async {
    if (registerFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerWithEmailPass(fullName, email, password, phoneNumber, dob)
          .then((value) async {
        if (value == true) {
          await SharedPref.saveUserLoginStatus(true);
          await SharedPref.saveUserName(fullName);
          await SharedPref.saveUserEmail(email);
          await SharedPref.saveUserPhone(phoneNumber);
          await SharedPref.saveUserDob(dob);
          // ignore: use_build_context_synchronously
          nextPage(context, const BottomSheetTest());
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
