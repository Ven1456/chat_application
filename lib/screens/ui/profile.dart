// ignore_for_file: invalid_use_of_visible_for_testing_member, must_be_immutable

import 'dart:io';
import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  String? username;
  String? email;
  String? profilePicTest;
  Profile({Key? key, this.username, this.profilePicTest, this.email})
      : super(key: key);
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AuthService authService = AuthService();
  String? image = "";
  String user = "";
  File? imageFile;
  @override
  void initState() {
    super.initState();
    getImage();
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
  /* getImage() async
  {
    await SharedPref.getProfilePic().then((value) {
      setState(() {
        widget.profilePicTest = value ?? "";
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("profile"),
      ),
      body: ChangeNotifierProvider(
        create: (_) => ProfileController(),
        child: Consumer<ProfileController>(
          builder: (context, provider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 75,
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 200,
                      width: 200,
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
                                    size: 150,
                                  )
                                : Image.network(
                                    height: 150,
                                    width: 150,
                                    widget.profilePicTest ?? "",
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loading) {
                                      if (loading == null) return child;
                                      return const Center(
                                          child: CircularProgressIndicator());
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
                            horizontal: 35.0, vertical: 0),
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                            child: const Icon(Icons.edit)),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    SizedBox(
                      width: 50,
                    ),
                    Text(
                      "Username",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 33,
                    ),
                  ],
                ),
                _buildUsernameContainer(),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    SizedBox(
                      width: 50,
                    ),
                    Text(
                      "Email",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 33,
                    ),
                  ],
                ),
                _buildEmailContainer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildUsernameContainer() {
    return Container(
      height: 60,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Container _buildEmailContainer() {
    return Container(
      height: 60,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
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
          widget.email!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
