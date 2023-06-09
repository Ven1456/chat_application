import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/services/database_services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // login
  Future loginWithUsernamePassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  } // register

  Future registerWithEmailPass(

String fullName, String email, String password,String phone ,String dob ,) async {
    try {
      //
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      await DatabaseServices(uid: user.uid).updateUserData(fullName, email,phone,dob);
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return (e.message);
    }
  }

  Future signOut() async {
    try {
      await SharedPref.saveUserLoginStatus(false);
      await SharedPref.saveUserName("");
      await SharedPref.saveUserEmail("");
      await SharedPref.saveUserDob("");
      await SharedPref.saveUserPhone("");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }

  Future resetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
