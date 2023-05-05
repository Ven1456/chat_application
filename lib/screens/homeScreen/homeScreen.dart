
import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/screens/groups/group_Tile.dart';
import 'package:chat/services/authentication_services/auth_service.dart';
import 'package:chat/services/database_services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:toast/toast.dart';

import '../../resources/widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  String email = "";
  String profilePic = "";
  Stream? groups;
  QuerySnapshot? searchSnapshot;
  AuthService authService = AuthService();
  bool _isLoading = false;
  String groupName = "";
  String userProfile = "";
  String groupPic = "";
  final TextEditingController textEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
    textEditingController;
      gettingUserData();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getGroupImage() async {
    DatabaseServices().getGroupIcon(groupPic).then((value) {
      setState(() {
        groupPic= value;
      });
    });
  }

  gettingUserData() async {
    await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
    await SharedPref.getName().then((value) {
      setState(() {
        username = value;
      });
    });
    await SharedPref.getEmail().then((value) {
      setState(() {
        email = value;
       // getGroupImage();
      });
    });
  }

  final valFormKey = GlobalKey<FormState>();
  bool isGroup = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _buildAppBar(context),
      body: groupList(),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }


  // APP BAR  EXTRACT AS A METHOD
  AppBar _buildAppBar(BuildContext context) {
    return appBar(
      titleText: "Chats",
      context: context,
      isBack: false,
      textStyleColor: Colors.white,
      color: Colors.blue,
    );
  }

  // FLOATING ACTION BUTTON  EXTRACT AS A METHOD
  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        popUpDialog(context);
      },
      elevation: 0,
      child: const Icon(Icons.add),
    );
  }

  // GROUP LIST  METHOD
  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data["groups"] != null) {
              if (snapshot.data["groups"].length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data["groups"].length,
                  itemBuilder: (BuildContext context, int index) {

                    // reverse the index value
                    int reverseIndex = snapshot.data["groups"].length - index - 1;
                    return GroupTile(
                        groupName: getName(snapshot.data["groups"][reverseIndex]),
                        userProfile: snapshot.data["profilePic"],
                        userId: snapshot.data["uid"],
                        username: snapshot.data["fullName"],
                        // groupPic: groupPic,
                        groupId: getId(snapshot.data["groups"][reverseIndex]));
                  },
                );
              } else {
                return noGroupWidget();
              }
            } else {
              return noGroupWidget();
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  // POP UP DIALOG   METHOD
  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          textEditingController.clear();
          _isLoading = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Create A Group",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 35,
                  maxHeight: 85,
                  maxWidth: 150,
                ),
                child: Column(
                  children: [
                    _isLoading
                        ? Center(
                            child: SizedBox(
                                height: 50,
                                width: 50,
                                child: Lottie.network(
                                    "https://assets1.lottiefiles.com/packages/lf20_p8bfn5to.json")),
                          )
                        : Form(
                            key: valFormKey,
                            child: TextFormField(
                              /*inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                    RegExp(r"^\s+|\s+$")),
                              ],*/
                              controller: textEditingController,
                              onChanged: (val) {
                                setState(() {
                                  groupName = val.trim();
                                });
                              },
                              validator: (val) {
                                if (val!.length < 2) {
                                  return "Please Enter AtLeast 2 Characters";
                                } else if (val.trim().isEmpty) {
                                  return "Please Create A Group Without Spaces";
                                } else if (val
                                    .trim()
                                    .replaceAll(' ', '')
                                    .isEmpty) {
                                  return "Please Create A Group That Contains Text";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                /*     errorText: isGroup ? _groupNameError : null,*/
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(21),
                                    borderSide:
                                        const BorderSide(color: Colors.blue)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(21),
                                    borderSide:
                                        const BorderSide(color: Colors.red)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(21),
                                    borderSide:
                                        const BorderSide(color: Colors.blue)),
                              ),
                            ),
                          )
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
                ElevatedButton(
                    onPressed: () async {
                      if (valFormKey.currentState!.validate() &&
                          groupName != "" &&
                          groupName.isNotEmpty &&
                          groupName.length >= 2) {
                        setState(() {
                          /*groupName.toString().isEmpty ?_validate=true : _validate=false;*/
                          _isLoading = true;
                        });

                        QuerySnapshot querySnapshot = await DatabaseServices()
                            .groupCollection
                            .where("groupName", isEqualTo: groupName)
                            .get();
                        if (querySnapshot.docs.isNotEmpty) {
                          ToastContext toastContext = ToastContext();
                          // ignore: use_build_context_synchronously
                          toastContext.init(context);
                          Toast.show(
                            "Group with the same name already exists",
                            duration: Toast.lengthShort,
                            rootNavigator: true,
                            gravity: Toast.bottom,
                            webShowClose: true,
                            backgroundColor: Colors.red,
                          );
                          // A group with the same name already exists, so show error message
                          setState(() {
                            _isLoading = false;
                          });
                          return;
                        }

                        DatabaseServices(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .createGroup(
                                username,
                                FirebaseAuth.instance.currentUser!.uid,
                                groupName)
                            .whenComplete(() {
                          _isLoading = false;
                          groupName = "";
                        });
                        //
                        ToastContext toastContext = ToastContext();
                        // ignore: use_build_context_synchronously
                        toastContext.init(context);
                        Toast.show(
                          "Group Created Successfully",
                          duration: Toast.lengthShort,
                          rootNavigator: true,
                          gravity: Toast.bottom,
                          webShowClose: true,
                          backgroundColor: Colors.green,
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        /*
                        showSnackbar(context, Colors.green,
                            "Group Created Successfully");*/
                      }
                    },
                    child: const Text(
                      "Create",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
              ],
            );
          });
        });
  }

  // NO GROUP WIDGET  METHOD
  noGroupWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: () {
                popUpDialog(context);
              },
              child: const Icon(
                Icons.add_circle_outline_outlined,
                size: 60,
              )),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "You are not created any Group not yet",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )
        ],
      ),
    );
  }
}
