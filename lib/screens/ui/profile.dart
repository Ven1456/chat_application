// ignore_for_file: invalid_use_of_visible_for_testing_member, must_be_immutable

import 'dart:io';
import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  String? username;
  String? email;
  String? phone;
  String? dob;
  String? profilePicTest;

  Profile(
      {Key? key,
      this.dob,
      this.phone,
      this.username,
      this.profilePicTest,
      this.email})
      : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  AuthService authService = AuthService();
  String? image = "";
  String user = "";
  File? imageFile;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.username);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
    dobController = TextEditingController(text: widget.dob);
    setState(() {
      getImage();
    });
/*    getImage();*/
  }

  getImage() async {
    QuerySnapshot snapshot =
        await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
            .gettingUserEmail(widget.email.toString());

    setState(() {
      widget.profilePicTest = snapshot.docs[0]["profilePic"];
    });
  }

  bool isProfile = false;
  bool _isUsernameEditable = false;
  bool _isEmailEditable = false;
  bool _isPhoneEditable = false;
  bool _isDobEditable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ChangeNotifierProvider(
            create: (_) => ProfileController(),
            child: Consumer<ProfileController>(
              builder: (context, provider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Profile",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        const SizedBox(
                          width: 118,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDark = !isDark;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 25.0),
                            child: Icon(
                              isDark ? Icons.dark_mode : Icons.sunny,
                              size: 35,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: provider.image == null
                                ? (widget.profilePicTest ?? "").isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 120,
                                      )
                                    : Image.network(
                                        height: 120,
                                        width: 120,
                                        widget.profilePicTest ?? "",
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      )
                                : Stack(children: [
                                    Image.file(
                                      File(provider.image!.path).absolute,
                                      fit: BoxFit.cover,
                                    ),
                                  ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            provider.pickImage(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 0),
                            child: Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                    color: Colors.blue, shape: BoxShape.circle),
                                child: const Icon(Icons.edit)),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    _buildEditProfileContainer(),

                    const SizedBox(
                      height: 60,
                    ),
                    // USERNAME
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 25.0, bottom: 10),
                          child: Text(
                            "Username",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                    // USERNAME TEXT FIELD
                    Stack(alignment: Alignment.bottomRight, children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                            enabled: _isUsernameEditable,
                            controller: usernameController,
                            decoration: const InputDecoration(
                              suffixIconColor: Colors.grey,
                              errorStyle: TextStyle(color: Colors.red),
                              hintStyle: TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(color: Colors.blueGrey),
                              ),
                            )),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isUsernameEditable = !_isUsernameEditable;
                          });
                        },
                        icon: _isUsernameEditable
                            ? const Icon(Icons.done_sharp)
                            : const Icon(Icons.edit),
                      ),
                    ]),

                    const SizedBox(
                      height: 15,
                    ),
                    // EMAIL
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 25.0, bottom: 10),
                          child: Text(
                            "Email",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                    // EMAIL TEXT FIELD
                    Stack(alignment: Alignment.bottomRight, children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                            enabled: _isEmailEditable,
                            controller: emailController,
                            decoration: const InputDecoration(
                              suffixIconColor: Colors.grey,
                              errorStyle: TextStyle(color: Colors.red),
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(color: Colors.blueGrey),
                              ),
                            )),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEmailEditable = !_isEmailEditable;
                          });
                        },
                        icon: _isEmailEditable
                            ? const Icon(Icons.done_sharp)
                            : const Icon(Icons.edit),
                      ),
                    ]),
                    const SizedBox(
                      height: 15,
                    ),
                    // PHONE
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 25.0, bottom: 10),
                          child: Text(
                            "Phone",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                    // PHONE TEXT FIELD
                    Stack(alignment: Alignment.bottomRight, children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                            enabled: _isPhoneEditable,
                            controller: phoneController,
                            decoration: const InputDecoration(
                              suffixIconColor: Colors.grey,
                              errorStyle: TextStyle(color: Colors.red),
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(color: Colors.blueGrey),
                              ),
                            )),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isPhoneEditable = !_isPhoneEditable;
                          });
                        },
                        icon: _isPhoneEditable
                            ? const Icon(Icons.done_sharp)
                            : const Icon(Icons.edit),
                      ),
                    ]),
                    const SizedBox(
                      height: 15,
                    ),
                    // DOB
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 25.0, bottom: 10),
                          child: Text(
                            "Date Of Birth ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                    // DOB TEXT FIELD
                    Stack(alignment: Alignment.bottomRight, children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                            enabled: _isDobEditable,
                            controller: dobController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2),
                              ),
                              suffixIconColor: Colors.grey,
                              errorStyle: TextStyle(color: Colors.red),
                              hintStyle: TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(color: Colors.blueGrey),
                              ),
                            )),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isDobEditable = !_isDobEditable;
                          });
                        },
                        icon: _isDobEditable
                            ? const Icon(Icons.done_sharp)
                            : const Icon(Icons.edit),
                      ),
                    ]),
                    const SizedBox(
                      height: 20,
                    ),
                    AlertBoxReuse(
                        leaveOnTap: () {
                          authService.signOut();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (route) => false);
                        },
                        titleText: "Log Out",
                        subTitleText: "Are you sure you want Logout ?",
                        leaveTitleText: "Leave",
                        cancelTitleText: "Cancel",
                        cancelOnTap: () {
                          Navigator.pop(context);
                        }, ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  InkWell _buildEditProfileContainer() {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 45,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.yellowAccent[700],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 4), // changes position of shadow
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Edit Profile ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
