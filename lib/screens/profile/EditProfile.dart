import 'dart:io';

import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/utils/CustomValidators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../utils/InputFormatters.dart';
import 'edit_ProfilePic.dart';

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
  String _gender = "";
  FocusNode isFocus = FocusNode();
  bool hasChanges = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    setState(() {
      widget.profilePic;
    });
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
      _gender = docSnapshot.get("gender");
      usernameController = TextEditingController(text: _userName);
      emailController = TextEditingController(text: _email);
      phoneController = TextEditingController(text: _phone);
      dobController = TextEditingController(text: _dob);
    });
  }

  Gender? _selectedGender; // default selected gender

// function to handle gender selection
  void _handleGenderChange(Gender? value) {
    setState(() {
      _selectedGender = value;
      hasChanges = true;
    });
    _gender = value.toString().split('.').last;
  }

// create dropdown list items for gender selection
  List<DropdownMenuItem<Gender>> _buildGenderDropdownItems() {
    return Gender.values.map((gender) {
      return DropdownMenuItem<Gender>(
        value: gender,
        child: Text(gender.toString().split('.').last),
      );
    }).toList();
  }

  final editProfileKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          "Edit Profile", context, true, Colors.transparent, Colors.black),
      body: Form(
        key: editProfileKey,
        child: SingleChildScrollView(
          child: ChangeNotifierProvider(
              create: (_) => ProfileController(),
              child: Consumer<ProfileController>(
                  builder: (context, provider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    sizeBoxH25(),
                    EditProfilePic(
                      provider: provider,
                      profilePic: widget.profilePic ?? "",
                      userName: widget.username,
                    ),
                    sizeBoxH25(),
                    profileSubText("Username"),
                    // USERNAME TEXT FIELD
                    ProfileTextField(
                      onChanged: _userNameOnchangedValue,
                      validator: (val) => CustomValidators.fullName(val),
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
                      validator: (val) => CustomValidators.email(val),
                      isEnable: _isEmailEditable,
                      textEditingController: emailController,
                    ),
                    sizeBoxH15(),

                    // PHONE
                    profileSubText("Phone"),
                    // PHONE TEXT FIELD
                    ProfileTextField(
                      maxLength: 10,
                      textInputType: TextInputType.phone,
                      textInputFormatter: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (val) => CustomValidators.phone(val),
                      onChanged: (val) {
                        setState(() {
                          if (val.length <= 10) {
                            _phone = val;
                            hasChanges = val.length == 10;
                          }
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
                      textInputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                        DateTextFormatter()
                      ],

                      iconColor: Colors.black38,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(const Duration(days: 2555)),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2017));

                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('dd-MM-yyyy').format(pickedDate);

                          setState(() {
                            dobController.text = formattedDate;
                            _dob =
                                formattedDate; // store the dob value as a DateTime object
                            hasChanges = true;
                            _selectedDate = formattedDate.toString() as DateTime?;

                            //set output date to TextField value.
                          });
                        }
                      },
                      validator: (value){
                    var year = int.tryParse(value!.substring(4, 8));
                    if (year == null || year < 1900 || year > (DateTime.now().year - 14)) {
                      return 'Please select a year below ${(DateTime.now().year - 14)}';
                    }
                      },
                      onChanged: _dobOnChange,
                      isEnable: _isDobEditable,
                      textEditingController: dobController,
                    ),
                    sizeBoxH15(),
                    profileSubText("Gender"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 60,
                      child: IgnorePointer(
                        ignoring: isEdit ? true : false,
                        child: DropdownButtonFormField(
                          focusNode: isFocus,
                          hint: Text(
                            _gender.isEmpty ? "Select Gender" : _gender,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.7)),
                          ),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueGrey, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueGrey, width: 2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          items: _buildGenderDropdownItems(),
                          onChanged: _handleGenderChange,
                        ),
                      ),
                    ),

                    sizeBoxH45(),

                    InkWell(
                      onTap: () {
                        editProfileKey.currentState!.validate()
                            ? _updateProfileButton(context)
                            : null;
                      },
                      child: _buildIsUpdatedButtonText(),
                    ),

                    sizeBoxH45(),
                  ],
                );
              })),
        ),
      ),
    );
  }

  _userNameOnchangedValue(val) {
    setState(() {
      _userName = val;
      hasChanges = true;
    });
  }

  Container _buildIsUpdatedButtonText() {
    return Container(
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
            offset: const Offset(0, 4), // changes position of shadow
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
    );
  }

  _dobOnChange(val) {
    setState(() {
      _dob = val;
      hasChanges = true;
    });
  }

  Future<void> _updateProfileButton(BuildContext context) async {
    if (isEdit) {
      setState(() {
        isEdit = !isEdit;
        _isUsernameEditable = !_isUsernameEditable;
        _isEmailEditable = !_isEmailEditable;
        _isPhoneEditable = !_isPhoneEditable;
        _isDobEditable = !_isDobEditable;
        isFocus.requestFocus();
        editProfileKey.currentState!.validate() ? hasChanges : !hasChanges;
      });
    } else {
      if (hasChanges) {
        await _updateUserProfile(_userName, _email, _phone, _dob, _gender);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Profile Update Successfully',
        );
        setState(() {
          isEdit = !isEdit;
          _isUsernameEditable = !_isUsernameEditable;
          _isEmailEditable = !_isEmailEditable;
          _isPhoneEditable = !_isPhoneEditable;
          _isDobEditable = !_isDobEditable;
          isFocus.unfocus();
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'No Changes Have Been Made',
        );
      }
    }
    hasChanges = false;
  }

  Future<void> _updateUserProfile(String userName, String email, String phone,
      String dob, String gender) async {
    final user = FirebaseAuth.instance.currentUser;
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);

    await docRef.update({
      "fullName": userName,
      "email": email,
      "phone": phone,
      "dob": dob,
      "gender": gender,
    });
  }
}

enum Gender { Male, Female, Others }
