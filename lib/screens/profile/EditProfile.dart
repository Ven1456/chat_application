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
import "package:chat/utils/InputFormatters.dart";

import '../../resources/Shared_Preferences.dart';
import '../bottomSheet/BottomSheet.dart';
import 'profilePic.dart';

class EditProfile extends StatefulWidget {
  final String? profilePic;

  const EditProfile({
    Key? key,
    this.profilePic,
  }) : super(key: key);

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
  final editProfileKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getProfileDetails();
  }

  getProfileDetails() async {
    await SharedPref.getName().then((value) {
      setState(() {
        _userName = value;
      });
    });
    await SharedPref.getEmail().then((value) {
      setState(() {
        _email = value;
      });
    });
    await SharedPref.getPhone().then((value) {
      setState(() {
        _phone = value;
      });
    });
    await SharedPref.getGender().then((value) {
      setState(() {
        _gender = value;
      });
    });
    await SharedPref.getDob().then((value) {
      setState(() {
        _dob = value;
      });
    });

    usernameController = TextEditingController(text: _userName);
    emailController = TextEditingController(text: _email);
    phoneController = TextEditingController(text: _phone);
    dobController = TextEditingController(text: _dob);
  }


// function to handle gender selection
  void _handleGenderChange(Gender? value) {
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        titleText: "Edit Profile",
        context: context,
        isBack: true,
        textStyleColor: Colors.black,
        color: Colors.white,
        onBack: () {
          Navigator.pop(context, true);
        },
      ),
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
                    // PROFILE PICTURE
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       ProfilePicWidget(
                         isOnlineCircle: false,
                         isEdit: true,
                         provider: provider,
                         profilePic: widget.profilePic.toString(),
                         userName: _userName,
                       ),
                     ],
                   ),
                    sizeBoxH25(),
                    // USERNAME TEXT
                    profileSubText(text: "Username"),
                    // USERNAME TEXT FIELD
                    ProfileTextField(
                      onChanged: _userNameOnChangedValue,
                      validator: (val) => CustomValidators.fullName(val),
                      isEnable: _isUsernameEditable,
                      textEditingController: usernameController,
                    ),
                    sizeBoxH15(),
                    // EMAIL
                    profileSubText(text: "Email"),
                    // EMAIL TEXT FIELD
                    ProfileTextField(
                      onChanged: _emailOnChanged,
                      validator: (val) => CustomValidators.email(val),
                      isEnable: _isEmailEditable,
                      textEditingController: emailController,
                    ),
                    sizeBoxH15(),
                    // PHONE
                    profileSubText(text: "Phone"),
                    // PHONE TEXT FIELD
                    ProfileTextField(
                      maxLength: 10,
                      textInputType: TextInputType.phone,
                      textInputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (val) => CustomValidators.phone(val),
                      onChanged: _phoneOnChanged,
                      isEnable: _isPhoneEditable,
                      textEditingController: phoneController,
                    ),
                    sizeBoxH15(),
                    // DOB
                    profileSubText(text: "Date Of Birth"),
                    // DOB TEXT FIELD
                    ProfileTextField(
                      isEdit: true,
                      textInputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                        DateTextFormatter(),
                      ],
                      iconColor: Colors.black38,
                      onTap: () async {
                        await _dateOfBirthOnTapped(context);
                      },
                      onChanged: _dobOnChange,
                      isEnable: _isDobEditable,
                      textEditingController: dobController,
                    ),
                    sizeBoxH15(),
                    profileSubText(text: "Gender"),
                    _buildGenderField(context),
                    sizeBoxH45(),
                    _editAndUpdateButton(context),
                    sizeBoxH45(),
                  ],
                );
              })),
        ),
      ),
    );
  }
  // DATE OF BIRTH ON TAPPED EVENT EXTRACT AS METHOD
  Future<void> _dateOfBirthOnTapped(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(const Duration(days: 2555)),
        firstDate: DateTime(1900),
        lastDate: DateTime(2017));

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

      setState(() {
        dobController.text = formattedDate;
        _dob = formattedDate; // store the dob value as a DateTime object
        hasChanges = true;
        //set output date to TextField value.
      });
    }
  }
  // PHONE ON CHANGED EVENT EXTRACT AS METHOD
  _phoneOnChanged(val) {
    setState(() {
      if (val.length <= 10) {
        _phone = val;
        hasChanges = val.length == 10;
      }
    });
  }
  // EMAIL ON CHANGED EVENT EXTRACT AS METHOD
  _emailOnChanged(val) {
    setState(() {
      _email = val;
      hasChanges = true;
    });
  }
  // DOB ON CHANGED EVENT EXTRACT AS METHOD
  _dobOnChange(val) {
    setState(() {
      _dob = val;
      hasChanges = true;
    });
  }


// EDIT AND UPDATE BUTTON EXTRACT AS A METHOD
  InkWell _editAndUpdateButton(BuildContext context) {
    return InkWell(
      onTap: () {
        editProfileKey.currentState!.validate()
            ? _updateProfileButton(context)
            : null;
      },
      child: _buildIsUpdatedButtonText(),
    );
  }

// GENDER EXTRACT AS A METHOD
  SizedBox _buildGenderField(BuildContext context) {
    return SizedBox(
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
              borderSide: BorderSide(
                  color: isEdit ? Colors.grey : Colors.blueGrey,
                  width: isEdit ? 0.5 : 2),
              borderRadius: BorderRadius.circular(15),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blueGrey, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: isEdit ? Colors.grey : Colors.blueGrey,
                  width: isEdit ? 0.5 : 2),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          items: _buildGenderDropdownItems(),
          onChanged: _handleGenderChange,
        ),
      ),
    );
  }

  _userNameOnChangedValue(val) {
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
        await _updateUserProfile(
          usernameController.text,
          emailController.text,
          phoneController.text,
          dobController.text,
          _gender,
        );
        await SharedPref.saveUserName(usernameController.text);
        await SharedPref.saveUserEmail(emailController.text);
        await SharedPref.saveUserGender(_gender);
        await SharedPref.saveUserDob(dobController.text);
        await SharedPref.saveUserPhone(phoneController.text);
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Profile Update Successfully',
            onConfirmBtnTap: () {
              nextPagePushAndRemoveUntil(
                  context,
                  const BottomSheetTest(
                    screenIndex: 2,
                    isProfileScreen: true,
                  ));
            });

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
