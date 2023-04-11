// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';

import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:chat/screens/ui/homeScreen.dart';
import 'package:chat/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  String? username;

  String? email;

  Profile({Key? key, this.username, this.email}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AuthService authService = AuthService();
  String? image = "";
  File? imageFile;

  Future<void> setProfilePicture() async {
    final pickedFile = await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return; // user canceled the image picker
    }

    final file = File(pickedFile.path);

    if (!file.existsSync()) {
      return; // file does not exist
    }

    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('profile_picture.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    setState(() {
     /* FirebaseFirestore.instance.collection('users').doc(authService.firebaseAuth.currentUser!.uid).update({
        'profilePic': url,

      });
     */ image = url;
      imageFile = file;
    });
    final user = authService.firebaseAuth.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'profilePic': url,
    });
  }

  Future<void> _getProfileData() async {
    String userId = authService.firebaseAuth.currentUser!.uid;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      setState(() {
        image = snapshot.get('profilePic');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }
  /*AuthService authService = AuthService();
  String? image = "";
  File?imageXFile;

  Future<void> setProfilePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return; // user canceled the image picker
    }

    final file = File(pickedFile.path);

    if (!file.existsSync()) {
      return; // file does not exist
    }

    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('profile_picture.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL().then((value) {
      setState(() {
        FirebaseFirestore.instance.collection('users').doc().update({
          'profilePic': value,
        });
      });
    });
    setState(() {
      FirebaseFirestore.instance.collection('users').doc().update({
        'profilePic': url,
      });
    });
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'profilePic': url});
  }
  Future<void> _getProfileData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      setState(() {
        image = snapshot.get('profilePic');
      });
    }
  }
  Future<void> _getImageFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String downloadUrl = await _uploadImageToFirebaseStorage(file);
      String userId = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePic': downloadUrl,
      });
      setState(() {
        imageXFile = file;
      });
    }
  }
  Future<String> _uploadImageToFirebaseStorage(File file) async {
    String fileName = file.path.split('/').last;
    Reference ref =
    FirebaseStorage.instance.ref().child('profilePic').child(fileName);
    TaskSnapshot uploadTask = await ref.putFile(file);
    String downloadUrl = Uri.encodeFull(await uploadTask.ref.getDownloadURL());
    return downloadUrl;
  }
  @override
  void initState() {
    super.initState();
    _getProfileData();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("profile"),
      ),
      drawer: _buildDrawer(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 75,
          ),
          GestureDetector(
            onTap: () {
              setProfilePicture();
            },
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.black,
              child:Icon(Icons.person_outline,size: 150,)
            ),
          ),
        /*  GestureDetector(
            onTap: () {
              _getImageFile(); // add parentheses here
              setProfilePicture();
            },
            child: CircleAvatar(
              radius: 100,
              backgroundImage: imageXFile == null
                  ? NetworkImage(Uri.encodeFull(image!))
                  : Image.file(imageXFile!).image,
            ),
          ),*/

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
      ),
    );
  }

  Container _buildUsernameContainer() {
    return Container(
      height: 60,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(21),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Text(
        widget.username!,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Container _buildEmailContainer() {
    return Container(
      height: 60,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(21),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Text(
        widget.email!,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.black,
          ),
          Text(
            widget.username.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            height: 5,
          ),
          ListTile(
            onTap: () {
              replaceScreen(context, const HomeScreen());
            },
            leading: const Icon(Icons.group),
            title: const Text(
              "Chats",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.person),
            title: const Text(
              "Profile",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        "LogOut",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        "Are you sure you want Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            )),
                        IconButton(
                            onPressed: () {
                              authService.signOut();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false);
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            )),
                      ],
                    );
                  });
            },
            leading: const Icon(Icons.logout),
            title: const Text(
              "Log Out",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
