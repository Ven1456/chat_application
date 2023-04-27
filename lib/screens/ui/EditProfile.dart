import 'dart:io';

import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/ui/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class EditProfile extends StatefulWidget {
  final String username;
  final String email;
  final String phone;
  final String dob;
  final String? profilePic;

  const EditProfile(
      {Key? key,
      required this.username,
      required this.email,
      required this.phone,
      required this.dob,
      this.profilePic})
      : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  bool _isUsernameEditable = false;
  bool _isEmailEditable = false;
  bool _isPhoneEditable = false;
  bool _isDobEditable = false;
  bool isEdit = true;
  String _userName = "";
  String _email = "";
  String _phone = "";
  String _dob = "";
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() async {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final docSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(user).get();
    setState(() {
      _userName = docSnapshot.get("fullName");
      _email = docSnapshot.get("email");
      _phone = docSnapshot.get("phone");
      _dob = docSnapshot.get("dob");
      usernameController = TextEditingController(text: _userName);
      emailController = TextEditingController(text: _email);
      phoneController = TextEditingController(text: _phone);
      dobController = TextEditingController(text: _dob);
    });
  }

  final editProfileKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: editProfileKey,
        child: SafeArea(
            child: ChangeNotifierProvider(
                create: (_) => ProfileController(),
                child: Consumer<ProfileController>(
                    builder: (context, provider, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 25,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back_ios)),
                          const SizedBox(
                            width: 100,
                          ),
                          const Text(
                            "Edit Profile",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ],
                      ),
                      sizeBoxH45(),
                      _buildProfilePic(provider, context),
                      sizeBoxH45(),
                      profileSubText("Username"),
                      // USERNAME TEXT FIELD
                      ProfileTextField(
                        onChanged: (val) {
                          setState(() {
                            _userName = val;
                            hasChanges = true;
                          });
                        },
                        validator: (val) {
                          if (val!.isNotEmpty && val.length > 2) {
                            return null;
                          } else {
                            return "Please Enter Your Full Name ";
                          }
                        },
                        isEnable: _isUsernameEditable,
                        textEditingController: usernameController,
                      ),

                      sizeBoxH15(),
                      // EMAIL
                      profileSubText("Email"),
                      // EMAIL TEXT FIELD
                      ProfileTextField(
                        onChanged: (val) {
                          setState(() {
                            _email = val;
                            hasChanges = true;
                          });
                        },
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z\d.a-zA-Z!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z\d]+\.[a-zA-Z]+")
                                  .hasMatch(val!)
                              ? null
                              : "Please Enter Correct Email";
                        },
                        isEnable: _isEmailEditable,
                        textEditingController: emailController,
                      ),
                      sizeBoxH15(),
                      // PHONE
                      profileSubText("Phone"),
                      // PHONE TEXT FIELD
                      ProfileTextField(
                        textInputType: TextInputType.phone,
                        textInputFormatter: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (val) {
                          return val!.isEmpty ||
                                  val.length < 10 ||
                                  val.length > 10
                              ? "Please Enter Correct Phone Number"
                              : null;
                        },
                        onChanged: (val) {
                          setState(() {
                            _phone = val;
                            hasChanges = true;
                          });
                        },
                        isEnable: _isPhoneEditable,
                        textEditingController: phoneController,
                      ),
                      sizeBoxH15(),
                      // DOB
                      profileSubText("Date Of Birth"),
                      // DOB TEXT FIELD
                      ProfileTextField(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now().subtract(Duration(days: 2555)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2017));

                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('dd-MM-yyyy').format(pickedDate);
                            setState(() {
                              dobController.text = formattedDate;
                              _dob =
                                  formattedDate; //set output date to TextField value.
                            });
                          }
                        },
                        onChanged: (val) {
                          setState(() {
                            _dob = val;
                            hasChanges = true;
                          });
                        },
                        isEnable: _isDobEditable,
                        textEditingController: dobController,
                      ),
                      sizeBoxH45(),

                      InkWell(
                        onTap: () async {
                          if (isEdit) {
                            setState(() {
                              isEdit = !isEdit;
                              _isUsernameEditable = !_isUsernameEditable;
                              _isEmailEditable = !_isEmailEditable;
                              _isPhoneEditable = !_isPhoneEditable;
                              _isDobEditable = !_isDobEditable;
                            });
                          }
                          if (hasChanges) {
                            editProfileKey.currentState!.validate();
                            await updateUserProfile(_userName, _email, _phone, _dob);
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              text: 'Profile Update Successfully',
                            );
                          }
                          else
                            {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Oops...',
                                text: 'No Changes Has Done',
                              );
                            }
                          hasChanges = false;
                        },
                        child: Container(
                          height: 35,
                          width: 110,
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isEdit ? "Edit" : "Update",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                }))),
      ),
    );
  }

  Future<void> updateUserProfile(
      String userName, String email, String phone, String dob) async {
    final user = FirebaseAuth.instance.currentUser;
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);

    await docRef.update({
      "fullName": userName,
      "email": email,
      "phone": phone,
      "dob": dob,
    });
  }

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
                ? (widget.profilePic ?? "").isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 120,
                      )
                    : Image.network(
                        height: 120,
                        width: 120,
                        widget.profilePic ?? "",
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
}
