import 'dart:io';

import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/ui/homeScreen.dart';
import 'package:chat/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GroupInfo extends StatefulWidget {
  String groupName;
  String groupId;
  String adminName;
  String? groupPic;

  GroupInfo(
      {Key? key,
      this.groupPic,
      required this.adminName,
      required this.groupName,
      required this.groupId})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  @override
  void initState() {
    SharedPref.saveGroupId(widget.groupId);
    // TODO: implement initState
    super.initState();
    getMembers();
    setState(() {});
  }

  getImage() async {
    DatabaseServices().getGroupIcon(widget.groupId).then((value) {
      setState(() {
        widget.groupPic = value;
      });
    });
  }

  getMembers() {
    DatabaseServices().getGroupMembers(widget.groupId).then((value) {
      setState(() {
        members = value;
        getImage();
      });
    });
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(1, res.indexOf("_") - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ChangeNotifierProvider(
        create: (_) => ProfileController(),
        child: Consumer<ProfileController>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // GROUP IMAGE
                    _buildGroupImage(provider, context),
                    const SizedBox(
                      height: 20,
                    ),
                    // GROUP AND ADMIN NAME
                    _buildGroupAndAdminNameText(),
                    const SizedBox(height: 20),
                    // MEMBERS IN THAT GROUP
                    memberList()
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // GROUP AND ADMIN NAME TEXT EXTRACT AS A METHOD
  Container _buildGroupAndAdminNameText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: Colors.blue.withOpacity(0.2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              widget.groupName.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Group : ${widget.groupName}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Admin : ${getName(widget.adminName)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // GROUP IMAGE  EXTRACT AS A METHOD
  Stack _buildGroupImage(ProfileController provider, BuildContext context) {
    return Stack(
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
            child: provider.groupImage == null
                ? (widget.groupPic ?? "").isEmpty
                    ? Container(
                        color: Colors.orange,
                        child: Center(
                          child: Text(
                            widget.groupName.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Image.network(
                        height: 150,
                        width: 150,
                        widget.groupPic ?? "",
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
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
                      File(provider.groupImage!.path).absolute,
                      fit: BoxFit.cover,
                    ),
                  ]),
          ),
        ),
        GestureDetector(
          onTap: () {
            provider.pickGroupImage(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit),
          ),
        )
      ],
    );
  }

  // APP BAR  EXTRACT AS A METHOD
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text(
        "Group Info",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.exit_to_app,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    "Leave Group?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  content: const Text(
                    "Are you sure you want to leave this group?",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DatabaseServices(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .toggleGroupJoin(
                          widget.groupId,
                          getName(widget.adminName),
                          widget.groupName,
                        )
                            .whenComplete(() {
                          nextPage(context, const HomeScreen());
                        });
                      },
                      child: const Text(
                        "LEAVE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  // MEMBERS LIST METHOD
  memberList() {
    return StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data["members"] != null) {
              if (snapshot.data["members"].length != 0) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data["members"].length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 5),
                        child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                getName(snapshot.data["members"][index])
                                    .substring(0, 2)
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                                getName(
                                  snapshot.data["members"][index],
                                ),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              "Your Are In ${widget.groupName} Group",
                              /*   getId(snapshot.data["members"][index]),*/
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            )),
                      );
                    });
              } else {
                return const Center(
                  child: Text("NO MEMBERS"),
                );
              }
            } else {
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
