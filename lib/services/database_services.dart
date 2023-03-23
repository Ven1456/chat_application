import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;

  DatabaseServices({this.uid});

  // reference from our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // update user data
  Future updateUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set(
      {
        "fullName":fullName,
        "email":email,
        "groups":[],
        "profilePic":"",
        "uid":uid,
      }
    );

  }
  Future gettingUserEmail(String email)async{
    QuerySnapshot snapshot =  await userCollection.where("email",isEqualTo: email).get();
    return snapshot;
  }
  // get user groups

Future getUserGroups()async{
    return userCollection.doc(uid).snapshots();
}
}
