import 'package:chat/resources/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);
  static const String id = 'ForgetPassword';
  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}
class _ForgetPasswordState extends State<ForgetPassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  var emailController = TextEditingController();
  var passTextController = TextEditingController();
  var nameController = TextEditingController();
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  bool isEmail = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(emailController != null)
    {
      emailController.text = userEmail.toString();
    }
    else if(emailController == null)  {
      emailController = " your email".toString() as TextEditingController;
    }
    emailController.text = userEmail.toString();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 20),
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color:Colors.black,
                              )),
                        ),
                      ],
                    ),
                    Container(
                      width: 335,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         const Text("reset Password"),
                          const SizedBox(height: 20,),
                         TextFormField(
                           decoration: textInputDecoration.copyWith(

                           ),

                         )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                  ElevatedButton(onPressed: () async{
                    await _CreateanaccountBuildMethod(context);
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: emailController.text)
                        .then((value) => Navigator.of(context).pop());
                    if (emailController.text.isNotEmpty) {
                      showErrorSnackBar("please check your email");
                    }
                  }, child: const Text("reset Password "))
                    // reset password button

                  ],
                ),
              )),
        ));
  }
  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      duration: const Duration(milliseconds: 350),
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  Future<void> _CreateanaccountBuildMethod(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      // await _signup.Signupservice(
      //     email: emailController.text,
      //     password: passTextController.text,
      //     name: nameController.text,
      //     context: context);
      setState(() {
        isLoading = false;
      });
    }
  }
}