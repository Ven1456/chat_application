import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/screens/ui/homeScreen.dart';
import 'package:chat/screens/ui/profile.dart';
import 'package:chat/screens/ui/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/database_services.dart';

class BottomSheetTest extends StatefulWidget {
  const BottomSheetTest({Key? key}) : super(key: key);

  @override
  State<BottomSheetTest> createState() => _BottomSheetTestState();
}

class _BottomSheetTestState extends State<BottomSheetTest> {
  String email = "";
  String phone = "";
  String dob = "";
  String profilePic = "";
  String userName = "";
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  List<Widget> pages = [const HomeScreen(),];

  void buildPages() {
    pages = [
      const HomeScreen(),
      const Search(),
      Profile(
        profilePicTest: profilePic.toString(),
        email: email,
        username: userName,
        phone: phone,
        dob: dob,
      ),
    ];
  }

  getImage() async {
    QuerySnapshot snapshot =
        await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
            .gettingUserEmail(email);
    setState(() {
      profilePic = snapshot.docs[0]["profilePic"];
    });
  }

  getProfile() async {
    await SharedPref.getName().then((value) {
      setState(() {
        userName = value ?? "";
      });
    });
    await SharedPref.getEmail().then((value) {
      setState(() {
        email = value ?? "";
      });
    });
    await SharedPref.getPhone().then((value) {
      setState(() {
        phone = value ?? "";
      });
    });
    await SharedPref.getDob().then((value) {
      setState(() {
        dob = value ?? "";
      });
    });
    await getImage();

    buildPages();

  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTap,
        currentIndex: currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.deepPurple.withOpacity(0.9),
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            label: "Chats",
            icon: Icon(CupertinoIcons.chat_bubble),
          ),
          BottomNavigationBarItem(
            label: "Search",
            icon: Icon(CupertinoIcons.search),
          ),
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(CupertinoIcons.person),
          ),
        ],
      ),
    );
  }
}
