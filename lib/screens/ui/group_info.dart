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
    getMembers();
    getImage();
    // TODO: implement initState
    super.initState();
  }

  getImage() async {

    await SharedPref.getGroupPic().then((value) {
      setState(() {
        widget.groupPic = value ?? "";
      });
    });

  }

  getMembers() {
    DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
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
                                    widget.groupName.substring(0, 2),
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                                  : Image.network(
                                height: 150,
                                width: 150,
                                widget.groupPic ?? "",
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loading) {
                                  if (loading == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              )
                                  : Stack(children: [
                                Image.file(File(provider.groupImage!.path).absolute,
                                  fit: BoxFit.cover,
                                ),

                              ]),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              provider.pickGroupImage(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 35.0,vertical: 0),
                              child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle
                                  ),
                                  child: const Icon(Icons.edit)),
                            ),
                          )
                        ],
                      ),
                    /*  Stack(
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
                              child: provider.groupImage == null
                                  ? (widget.groupPic).isEmpty
                                      ? Container(
                                color: Colors.orange,
                                        child: Center(
                                            child: Text(
                                              widget.groupName.substring(0, 2),
                                              style: const TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      )
                                      : Image.network(
                                          height: 120,
                                          width: 120,
                                          widget.groupPic,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, loading) {
                                            if (loading == null) return child;
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                        )
                                  : Stack(children: [
                                      Image.file(
                                        File(provider.groupImage!.path)
                                            .absolute,
                                        fit: BoxFit.cover,
                                      ),
                                    ]) ,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              provider.pickGroupImage(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0,right: 24,top: 4),
                              child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.edit)),
                            ),
                          )
                        ],
                      ),*/
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21),
                          color: Colors.blue.withOpacity(0.4),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(widget.groupName.substring(0, 2)),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Group : ${widget.groupName}"),
                                Text("Admin : ${getName(widget.adminName)}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      memberList()
                    ],
                  ),
                ),
              );
            })));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
        title: const Text("Group Info"),
        centerTitle: true,
        actions: [
          GestureDetector(
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
                          "Are you sure you want Exit this Group",
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
                              onPressed: () async {
                                DatabaseServices(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .toggleGroupJoin(
                                        widget.groupId,
                                        getName(widget.adminName),
                                        widget.groupName)
                                    .whenComplete(() {
                                  nextPage(context, HomeScreen());
                                });
                              },
                              icon: const Icon(
                                Icons.done,
                                color: Colors.green,
                              )),
                        ],
                      );
                    });
              },
              child: const Icon(Icons.exit_to_app)),
          const SizedBox(
            width: 20,
          ),
        ],
      );
  }

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
                                    .substring(0, 2),
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
