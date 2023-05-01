import 'package:chat/resources/widget.dart';
import 'package:chat/utils/CustomValidators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String newPass="";
  String confirmPass="";
  TextEditingController currentPassTextEditingController =  TextEditingController();
  TextEditingController newPassTextEditingController =  TextEditingController();
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  final _resetKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor.fromHex('#FFFFFF'),
      appBar: appBar("", context, true),
      body: Form(
        key: _resetKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                sizeBoxH45(),
                imageBuild("assets/images/reset.jpg", 220),
                sizeBoxH25(),
                boldTitleText("Reset Password"),
                sizeBoxH25(),
                ReusableTextField(
                  obSecureText: !_currentPasswordVisible,
                  width: MediaQuery.of(context).size.width * 0.85,
                  textEditingController: currentPassTextEditingController,
                  labelText: "Current Password",
                  prefixIcon: const Icon(Icons.security),
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _currentPasswordVisible = !_currentPasswordVisible;
                      });
                    },
                    child: Icon(
                      _currentPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      newPass = val;
                    });
                  },
                    validator: (val) => CustomValidators.validatePassword(val)
                ),
                sizeBoxH15(),

               ReusableTextField(
                  obSecureText: !_newPasswordVisible,
                  width: MediaQuery.of(context).size.width * 0.85,
                  textEditingController: newPassTextEditingController,
                  labelText: "new Password",
                  prefixIcon: const Icon(Icons.security),
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _newPasswordVisible = !_newPasswordVisible;
                      });
                    },
                    child: Icon(
                      _newPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      confirmPass = val;
                    });
                  },
                  validator: (val) => CustomValidators.password(val)

                ),
                sizeBoxH25(),
                reusableButton(50, MediaQuery.of(context).size.width*0.85, () {
                  _resetKey.currentState!.validate();
                  _changePassword();

                }, "Update Password")

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final currentPassword = currentPassTextEditingController.text;
    final newPassword = newPassTextEditingController.text;

    try {
      // Prompt the user to reauthenticate
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update the user's password
      await user.updatePassword(newPassword);
      currentPassTextEditingController.clear();
      newPassTextEditingController.clear();

      // Show a success message
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Password Update Successfully',
      );
    } on FirebaseAuthException catch (e) {

      // Handle errors
      if (e.code == 'wrong-password') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error...',
          text: 'The current password is incorrect',
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error...',
          text: 'Error changing password: ${e.message}',
        );
      }
    } catch (e) {
      // Handle other errors
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error...',
        text: 'Error changing password: $e',
      );
    }
  }


}

