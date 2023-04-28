// ignore_for_file: invalid_use_of_visible_for_testing_member, must_be_immutable

import 'dart:io';
import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/login/login_screen.dart';
import 'package:chat/screens/profile/EditProfile.dart';
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
  AuthService authService = AuthService();
  String? image = "";
  String user = "";
  File? imageFile;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      getImage();
    });
/*    getImage();*/
  }

  getImage() async {
    QuerySnapshot snapshot = await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
            .gettingUserEmail(widget.email.toString());
    final user = FirebaseAuth.instance.currentUser!.uid;
    final docSnapshot = await FirebaseFirestore.instance.collection("users").doc(user).get();
    setState(() {
      widget.profilePicTest = snapshot.docs[0]["profilePic"];
      widget.username = docSnapshot.get("fullName");
    });
  }

  bool isProfile = false;

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
                    sizeBoxH25(),
                    ListTile(
                      title: Text("Edit Profile"),
                      trailing: Icon(Icons.arrow_forward_ios_sharp),
                      onTap: () {
                        nextPage(
                            context,
                            EditProfile(
                              username: widget.username!,
                              email: widget.email!,
                              phone: widget.phone!,
                              dob: widget.dob!,
                              profilePic: widget.profilePicTest!,
                            ));
                      },
                    ),
                    ListTile(
                      title: Text("Change Password"),
                      trailing: Icon(Icons.arrow_forward_ios_sharp),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text("Logout"),
                      trailing: Icon(Icons.arrow_forward_ios_sharp),
                      onTap: () {
                        alertBoxReuse(context,
                                // CANCEL BUTTON
                                () {
                          Navigator.pop(context);
                        },
                            // LEAVE
                                () {
                          authService.signOut();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (route) => false);
                        }, "Log Out", "Are you sure you want Logout ?", "Leave",
                            "Cancel");

                      },
                    ),

                    sizeBoxH60(), // USERNAME

                    sizeBoxH15(),
                    sizeBoxH20(),
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
      ],
    );
  }

  Container _buildEditProfileContainer() {
    return Container(
      height: 35,
      width: 180,
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
      child: Center(
        child: Text(
          widget.username!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
