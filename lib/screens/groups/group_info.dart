import 'dart:io';

import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/bottomSheet/BottomSheet.dart';
import 'package:chat/services/database_services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

// ignore: must_be_immutable
class GroupInfo extends StatefulWidget {
  String groupName;
  String currentUser;
  String sender;
  String groupId;
  String adminName;
  String userProfile;
  String? groupPic;

  GroupInfo(
      {Key? key,
      this.groupPic,
      required this.adminName,
      required this.sender,
      required this.currentUser,
      required this.userProfile,
      required this.groupName,
      required this.groupId})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  String isAdmin = "";
  String username = "";
  bool? isOnline;
  bool isDelete = false;
  @override
  void initState() {
    SharedPref.saveGroupId(widget.groupId);
    // TODO: implement initState
    super.initState();
    isAdmin = getName(widget.adminName);
    print("fghjgfh ${widget.userProfile}");
    getMembers();
    isDelete = true;
    setState(() {});
  }

  getImage() async {
    DatabaseServices().getGroupIcon(widget.groupId).then((value) {
      setState(() {
        widget.groupPic = value;
      });
    });
    await SharedPref.getName().then((value) {
      setState(() {
        username = value;
      });
    });
  }

  Stream<bool> getOnlineStatus(String userId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .snapshots()
        .map((doc) => doc.get("onlineStatus") ?? false);
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
                    isDelete ? memberList() : Container()
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
                        errorBuilder: (context, url, error) => Image.asset(
                            'assets/images/404.jpg',
                            fit: BoxFit.cover),
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
        isAdmin == username
            ? GestureDetector(
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
            : Container(
                margin: const EdgeInsets.all(8),
                height: 40,
                width: 40,
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
        isAdmin == username
            ? IconButtonAlertReuse(
                icon: Icons.delete,
                leaveOnTap: () {
                  setState(() {
                    isDelete = false;
                  });
                  DatabaseServices()
                      .deleteGroup(
                    widget.groupId,
                    widget.groupName,
                  )
                      .whenComplete(() {
                    QuickAlert.show(
                        context: context,
                        type: QuickAlertType.success,
                        text: 'Group Deleted Successfully',
                        onConfirmBtnTap: () {
                          nextPagePushAndRemoveUntil(
                              context, const BottomSheetTest());
                        });
                  });
                  DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
                      .toggleGroupJoin(
                    widget.groupId,
                    getName(widget.adminName),
                    widget.groupName,
                  );
                },
                titleText: "Delete Group?",
                subTitleText: "Are you sure you want to delete this group ?",
                leaveTitleText: "DELETE",
                cancelTitleText: "CANCEL",
                cancelOnTap: () {
                  Navigator.pop(context);
                })
            : SizedBox(),
        isAdmin == username
            ? const SizedBox(
                width: 10,
              )
            : const SizedBox(
                width: 0,
              ),
        IconButtonAlertReuse(
            icon: Icons.exit_to_app,
            leaveOnTap: () {
              DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
                  .toggleGroupJoin(
                widget.groupId,
                getName(widget.adminName),
                widget.groupName,
              )
                  .whenComplete(() {
                nextPage(context, const BottomSheetTest());
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  text: 'Group Leave Successfully',
                );
              });
            },
            titleText: "Leave Group?",
            subTitleText: "Are you sure you want to leave this group ?",
            leaveTitleText: "LEAVE",
            cancelTitleText: "CANCEL",
            cancelOnTap: () {
              Navigator.pop(context);
            }),
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
                      String memberName = getName(snapshot.data["members"][index]);
                      bool isCurrentUser = memberName == widget.currentUser; // replace with your own matching criteria
                      String userProfileUrl = isCurrentUser ? widget.userProfile:"";
                      print(widget.userProfile);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 5),
                        child: ListTile(
                          leading: Stack(children: [
                            CircleAvatar(
                              child: userProfileUrl.isEmpty
                                  ? Text(
                                    memberName
                                          .substring(0, 2)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : ClipRRect(
                                borderRadius: BorderRadius.circular(150),
                                    child: Image.network(
                                      userProfileUrl,
                                        height: 35,
                                        width: 35,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Image.asset(
                                            'assets/images/404.jpg',
                                            height: 35,
                                            width: 35,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                  ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 2,
                              child: StreamBuilder<bool>(
                                stream: getOnlineStatus(
                                    snapshot.data["members"][index]),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data == true
                                        ? const Icon(
                                            Icons.circle,
                                            color: Colors.green,
                                            size: 10,
                                          )
                                        : const Icon(Icons.circle_outlined,
                                            color: Colors.black, size: 10);
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              ),
                            )
                          ]),
                          title: Text(
                              getName(
                                snapshot.data["members"][index],
                              ),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
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
