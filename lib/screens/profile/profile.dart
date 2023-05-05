// ignore_for_file: invalid_use_of_visible_for_testing_member, must_be_immutable

import 'dart:io';
import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/changePassword/change_password.dart';
import 'package:chat/screens/auth/login/login_screen.dart';
import 'package:chat/screens/profile/EditProfile.dart';
import 'package:chat/screens/profile/components.dart';
import 'package:chat/services/authentication_services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../resources/Shared_Preferences.dart';
import '../feedback/feedback.dart';

class Profile extends StatefulWidget {
  Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AuthService authService = AuthService();
  String? image = "";
  String username = "";
  File? imageFile;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  getImage() async {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final docSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(user).get();
    setState(() {
      image = docSnapshot.get("profilePic");
    });
  }

  getUsername() async {
    await SharedPref.getName().then((value) {
      setState(() {
        username = value;
        getImage();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        titleText: "Profile",
        context: context,
        isBack: false,
        textStyleColor: Colors.white,
        color: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ChangeNotifierProvider(
            create: (_) => ProfileController(),
            child: Consumer<ProfileController>(
              builder: (context, provider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    sizeBoxH25(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // PROFILE PICTURE
                        ProfilePicWidget(
                          userName: username,
                          provider: provider,
                          profilePic: image.toString(),
                          isEdit: false,
                        ),
                      ],
                    ),
                    sizeBoxH15(),
                    // USERNAME CONTAINER
                    usernameContainer(text: username),
                    sizeBoxH25(),
                    // EDIT PROFILE
                    listTile(
                        text: "Edit Profile",
                        onTap: () async {
                          bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context_) => EditProfile(
                                        profilePic: image,
                                      )));
                          if (result != null) {
                            if (result) {
                              setState(() {
                                getUsername();
                                getImage();
                              });
                            }
                          }
                        }),
                    // CHANGE PASSWORD
                    listTile(
                      text: "Change Password",
                      onTap: () =>
                          nextPage(context, const ChangePasswordScreen()),
                    ),
                    // FEEDBACK SCREEN
                    listTile(
                        text: "Feedback",
                        onTap: () {
                          nextPage(
                              context,
                              FeedBackScreen(
                                userName: username,
                              ));
                        }),
                    // LOG OUT SCREEN
                    listTile(
                        text: "Logout",
                        onTap: () {
                          alertBoxReuse(
                            context: context,
                            // CANCEL BUTTON
                            cancelOnTap: () {
                              Navigator.pop(context);
                            },
                            // LEAVE
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
                            leaveTitleText: "LogOut",
                            cancelTitleText: "Cancel",
                          );
                        }),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
