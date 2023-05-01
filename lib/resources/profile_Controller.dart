import 'dart:io';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'Shared_Preferences.dart';

class ProfileController extends ChangeNotifier {

  final picker = ImagePicker();
  AuthService authService = AuthService();
  // 21/04/23
  XFile? _messageImage;
  // 21/04/23
  XFile? get messageImage => _messageImage;
  XFile? _groupImage;
  XFile? get groupImage => _groupImage;
  XFile? _image;
  XFile? get image => _image;
  String getId = "";
  String url = "";
  String userName = "";
  String userProfile = "";
  // 21/04/23
  String messageUrl ="";
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instanceFor(bucket: 'gs://chatapp-4f907.appspot.com');
  // IMAGE PICK FROM GALLERY
  Future pickGalleryImage(BuildContext context) async {
    final pickedFile =  await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      _image = await _CropImage(imageFile: _image);
      // ignore: use_build_context_synchronously
      uploadImage(context);
      notifyListeners();
      // ignore: use_build_context_synchronously
    }
  }

  // CROP THE IMAGE
  Future<XFile?> _CropImage({XFile? imageFile}) async {
    if (imageFile == null) return null;
    CroppedFile? croppedImage =
    await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return XFile(croppedImage.path);
  }

  // IMAGE PICK FROM CAMERA
  Future pickCameraImage(BuildContext context) async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      // ignore: use_build_context_synchronously
      uploadImage(context);
      notifyListeners();
    }
  }


  // UPLOADING THE IMAGE FROM YUR DEVICE
  void uploadImage(BuildContext context) async {
    if (image == null) {
      return;
    }
    firebase_storage.Reference reference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child("/profilePic")
        .child(authService.firebaseAuth.currentUser!.uid);
    firebase_storage.UploadTask uploadTask =
    reference.putFile(File(image!.path).absolute);
    await Future.value(uploadTask);
    String downloadUrl = await reference.getDownloadURL();
    String userId = authService.firebaseAuth.currentUser!.uid;
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePic': downloadUrl,
      });
      url = downloadUrl;
      await SharedPref.saveProfilePic(downloadUrl);
    }
  }


  // PICK IMAGE FROM YOUR DEVICE
  void pickImage(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 120,
              width: 120,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                    pickCameraImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.camera),
                    title: const Text("Camera"),
                  ),
                  ListTile(
                    onTap: () {
                       pickGalleryImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.image),
                    title: const Text("Image"),
                  )
                ],
              ),
            ),
          );
        });
  }
  void pickGroupImage(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 120,
              width: 120,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                     pickCameraGroupImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.camera),
                    title: const Text("Camera"),
                  ),
                  ListTile(
                    onTap: () {
                    pickGalleryGroupImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.image),
                    title: const Text("Image"),
                  )
                ],
              ),
            ),
          );
        });
  }
  // IMAGE PICK FROM GALLERY
  Future pickGalleryGroupImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _groupImage = XFile(pickedFile.path);
      _groupImage = await _CropImage(imageFile: _groupImage);
      // ignore: use_build_context_synchronously
      uploadGroupImage(context);
      notifyListeners();
    }
  }

  // IMAGE PICK FROM CAMERA
  Future pickCameraGroupImage(BuildContext context) async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      _groupImage = XFile(pickedFile.path);
      // ignore: use_build_context_synchronously
      uploadGroupImage(context);
      notifyListeners();
    }
  }

  // UPLOAD GROUP IMAGE
  void uploadGroupImage(BuildContext context) async {
    if (_groupImage == null) {
      return;
    }

    getId =(await SharedPref.getGroupId())!;
    firebase_storage.Reference reference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child("/groupIcon")
        .child(getId);
    firebase_storage.UploadTask uploadTask =
    reference.putFile(File(_groupImage!.path).absolute);
    await Future.value(uploadTask);
    String downloadUrl = await reference.getDownloadURL();
    String userId = getId;
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('groups').doc(userId).get();
    if (snapshot.exists) {
      await FirebaseFirestore.instance.collection('groups').doc(userId).update({
      'groupIcon': downloadUrl,
    });
      url = downloadUrl;
     /* await SharedPref.saveGroupPic(downloadUrl);*/
    }
  }

  // 21/04/23
  // MESSAGE UPLOAD IMAGE
  void uploadMessageImage(BuildContext context) async {
    if (_messageImage == null) {
      return;
    }
    // @ 24/04/23
    getId =(await SharedPref.getAllGroupId())!;
    firebase_storage.Reference reference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child("/messagePhoto")
        .child(getId);
    firebase_storage.UploadTask uploadTask =
    reference.putFile(File(_messageImage!.path).absolute);
    await Future.value(uploadTask);
    String downloadUrl = await reference.getDownloadURL();
    String userId = getId;
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('groups').doc(userId).get();
    if (snapshot.exists) {
      await FirebaseFirestore.instance.collection('groups').doc(userId).update({
        'recentMessage': downloadUrl,
      });
      final user = FirebaseAuth.instance.currentUser!.uid;
      final docSnapshot = await FirebaseFirestore.instance.collection("users").doc(user).get();
      userName = docSnapshot.get("fullName");
      notifyListeners();
      userProfile = docSnapshot.get("profilePic");
      notifyListeners();
      messageUrl = downloadUrl;
      Map<String, dynamic> chatMessag = {
        "message": messageUrl,
        "sender":userName,
        "time": DateTime.now().microsecondsSinceEpoch,
        /* "groupPic":groupPicture,*/
        "userProfile": userProfile,
        "Type":"Image",
      };
      DatabaseServices().sendMessage(getId, chatMessag);
      await SharedPref.saveMessageUrl(messageUrl);
      /* await SharedPref.saveGroupPic(downloadUrl);*/
    }
  }
  // 21/04/23
// MESSAGE IMAGE
  void pickMessageImage(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 120,
              width: 120,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      pickCameraMessageImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.camera),
                    title: const Text("Camera"),
                  ),
                  ListTile(
                    onTap: () {
                      pickGalleryMessageImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.image),
                    title: const Text("Image"),
                  )
                ],
              ),
            ),
          );
        });
  }
  // 21/04/23
  // IMAGE PICK FROM GALLERY
  Future pickGalleryMessageImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _messageImage = XFile(pickedFile.path);
      _messageImage = await _CropImage(imageFile: _messageImage);
      // ignore: use_build_context_synchronously
      uploadMessageImage(context);
      notifyListeners();
    }
  }
  // 21/04/23
  // IMAGE PICK FROM CAMERA
  Future pickCameraMessageImage(BuildContext context) async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      _messageImage = XFile(pickedFile.path);
      // ignore: use_build_context_synchronously
      uploadMessageImage(context);
      notifyListeners();
    }
  }
}