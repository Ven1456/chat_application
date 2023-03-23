

import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  // login
  Future loginWithUsernamePassword(String email,String password) async
  {
    try
        {
          User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
          if(user!=null)
            {
              return true;
            }

        }
        on FirebaseAuthException catch(e)
    {
      return e.message;
    }
}  // register
  Future registerWithEmailPass(
      String fullName, String email, String password) async {
    try {
      //
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password)).user!;
      await DatabaseServices(uid: user.uid).updateUserData(fullName, email);
      if(user!=null)
        {
          return true;
        }
    } on FirebaseAuthException catch (e) {

      print(e);
      return(e.message);
    }
  }
  Future signOut() async{
    try{
      await SharedPref.saveUserLoginStatus(false);
      await SharedPref.saveUserName("");
      await SharedPref.saveUserEmail("");
      await firebaseAuth.signOut();

    }
    catch(e)
    {
      return null;
    }
  }


}
