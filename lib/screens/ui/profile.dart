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
                        sizeBoxW118(),
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

                    sizeBoxH25(),
                    _buildProfilePic(provider, context),
                    const SizedBox(
                      height: 5,
                    ),

                    sizeBoxH10(),
                    _buildEditProfileContainer(),

                    sizeBoxH60(),// USERNAME
                    profileSubText("Username"),
                    // USERNAME TEXT FIELD
                    ProfileTextField(
                      isEnable: _isUsernameEditable,
                      textEditingController: usernameController,
                      onTap: () {
                        setState(() {
                          _isUsernameEditable = !_isUsernameEditable;
                        });
                      },
                    ),

                    sizeBoxH15(),
                    // EMAIL
                    profileSubText("Email"),
                    // EMAIL TEXT FIELD
                    ProfileTextField(
                      isEnable: _isEmailEditable,
                      textEditingController: emailController,
                      onTap: () {
                        setState(() {
                          _isEmailEditable = !_isEmailEditable;
                        });
                      },
                    ),
                sizeBoxH15(),
                    // PHONE
                    profileSubText("Phone"),
                    // PHONE TEXT FIELD
                    ProfileTextField(
                      isEnable: _isPhoneEditable,
                      textEditingController: phoneController,
                      onTap: () {
                        setState(() {
                          _isPhoneEditable = !_isPhoneEditable;
                        });
                      },
                    ),
                    sizeBoxH15(),
                    // DOB
                    profileSubText("Date Of Birth"),
                    // DOB TEXT FIELD
                    ProfileTextField(
                      isEnable: _isDobEditable,
                      textEditingController: dobController,
                      onTap: () {
                        setState(() {
                          _isDobEditable = !_isDobEditable;
                        });
                      },
                    ),

                   sizeBoxH15(),
                    sizeBoxH20(),
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
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  // PROFILE PIC EXTRACT AS A METHOD
  Stack _buildProfilePic(ProfileController provider, BuildContext context) {
    return Stack(
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
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
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
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
            child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.edit)),
          ),
        )
      ],
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
