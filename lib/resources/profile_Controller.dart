import 'dart:io';

import 'package:chat/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import 'Shared_Preferences.dart';

class ProfileController extends ChangeNotifier {
  final picker = ImagePicker();
  AuthService authService = AuthService();
  XFile? _image;
  XFile? get image => _image;
  String url = "";
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instanceFor(
          bucket: 'gs://chatapp-4f907.appspot.com');
  // IMAGE PICK FROM GALLERY
  Future pickGalleryImage(BuildContext context) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      _image = await _CropImage(imageFile: _image);
      // ignore: use_build_context_synchronously
      uploadImage(context);
      notifyListeners();
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

    // await FirebaseFirestore.instance.collection('users').doc(userId).update({
    //   'profilePic': downloadUrl,
    // }).then((value) {
    //   ToastContext toastContext = ToastContext();
    //   toastContext.init(context);
    //   Toast.show(
    //     "Profile Pic Update Successfully",
    //     duration: Toast.lengthShort,
    //     rootNavigator: true,
    //     gravity: Toast.bottom,
    //     webShowClose: true,
    //     backgroundColor: Colors.green,
    //   );
    // }).onError((error, stackTrace) {
    //   ToastContext toastContext = ToastContext();
    //   toastContext.init(context);
    //   Toast.show(
    //     "Profile Pic Update Failed",
    //     duration: Toast.lengthShort,
    //     rootNavigator: true,
    //     gravity: Toast.bottom,
    //     webShowClose: true,
    //     backgroundColor: Colors.green,
    //   );
    // });
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
}
