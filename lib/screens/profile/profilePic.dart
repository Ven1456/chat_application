import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../resources/profile_Controller.dart';

class ProfilePicWidget extends StatelessWidget {
  const ProfilePicWidget({
    Key? key,
    required this.provider,
    required this.profilePic,
    this.userName,
    required this.isEdit,
    this.isOnline,
    required this.isOnlineCircle,
  }) : super(key: key);
  final ProfileController provider;
  final String profilePic;
  final String? userName;
  final bool isEdit;
  final bool isOnlineCircle;
  final bool? isOnline;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black),
            color: Colors.grey.withOpacity(0.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: provider.image == null
                ? (profilePic).isEmpty
                    ? Center(
                        child: Text(
                        userName!.isNotEmpty
                            ? userName!.toUpperCase().substring(0, 2)
                            : "",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ))
                    : Image.network(
                        height: 120,
                        width: 120,
                        profilePic,
                        fit: BoxFit.cover,
                        errorBuilder: (context, url, error) => Image.asset(
                            'assets/images/404.jpg',
                            fit: BoxFit.cover),
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
        isEdit
            ? GestureDetector(
                onTap: () {
                  provider.pickImage(context);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
                  child: Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                          color: Colors.blue, shape: BoxShape.circle),
                      child: const Icon(Icons.edit)),
                ),
              )
            : Container(),
        isOnlineCircle
            ? Positioned(
                right: 25,
                bottom: 2,
                child: isOnline != null && isOnline!
                    ? Icon(Icons.circle, color: Colors.green)
                    : Icon(Icons.circle_outlined, color: Colors.black),
              )
            : Container(),
      ],
    );
  }
}
