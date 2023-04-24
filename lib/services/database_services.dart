import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;
  String? groupId;

  DatabaseServices({this.uid,this.groupId});

  // reference from our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // update user data
  Future updateUserData(String? fullName, String? email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }
  Future gettingUserPic() async {
    QuerySnapshot snapshot =
    await groupCollection.get();
    return snapshot;
  }
  // getting user email data
  Future gettingUserEmail(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }
  //
  Future gettingGroupPic(String groupName)async{
    QuerySnapshot snapshot =  await groupCollection.where("groupName",isEqualTo: groupName).get();
    return snapshot;
  }

  // get user groups

  Future getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

// creating Group Collection
  Future createGroup(String username, String id, String groupName) async {
    QuerySnapshot querySnapshot = await groupCollection
        .where("groupName", isEqualTo: groupName)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // A group with the same name already exists, so return null to indicate failure
      return null;
    }
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$username",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
      // 24/04/23
      "userProfile":"",
      "Type":"",
    });
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${id}_$username"]),
      "groupId": groupDocumentReference.id,
    });
    DocumentReference userDocumentReference = userCollection.doc(id);
    return await userDocumentReference.update({
      "groups":
      FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }


// GETTING CHARTS
  Future getCharts(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  // delete user data
  Future deleteUserData(String uid) async {
    await userCollection.doc(uid).update({
      "fullName": FieldValue.delete(),
      "groups": FieldValue.delete(),
    });
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot["admin"];
  }
  Future getGroupIcon(String? groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot["groupIcon"];
  }
//get group members
  Future getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search group name
  Future getSearchByName(String groupName) async {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }
  // search group not found
  Future searchByNameNotFound(String groupName) async {
    return groupCollection.where("groupName", isNotEqualTo: groupName).get();
  }
  // search groups
  Future<QuerySnapshot> getSearchByTextFieldName(String searchField) async {
    return await FirebaseFirestore.instance
        .collection("groups")
        .where("groupName", isGreaterThanOrEqualTo: searchField)
        .where("groupName", isLessThan: '$searchField\uf8ff')
        .get();
  }

// delete the group name
  Future deleteGroupName(String uid) async {
     await groupCollection.doc(uid).update({
      "groupId": FieldValue.delete(),
      "groupName": FieldValue.delete(),
    });
  }

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userdocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userdocumentReference.get();
    List<dynamic> groups = await documentSnapshot["groups"];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // Toggled joined
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot["groups"];

    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData["message"],
      "recentMessageSender": chatMessageData["sender"],
      "recentMessageTime": chatMessageData["time"].toString(),
      /*"groupIcon": chatMessageData["groupPic"].toString(),*/
      "messageUserIcon": chatMessageData["userProfile"].toString(),
      // ignore: unrelated_type_equality_checks
      // 24/04/23
      "Type": chatMessageData["Type"].toString(),
    });
  }
}
