import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/chat/chat_page.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GroupTile extends StatefulWidget {
  String groupId;
  String username;
  String groupName;
  String? groupPic;
  String? userId;
  String userProfile;

  GroupTile(
      {Key? key,
      this.groupPic,
      this.userId,
      required this.userProfile,
      required this.groupName,
      required this.username,
      required this.groupId})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  String profilePic = "";
  @override
  void initState() {
    super.initState();
    setState(() {
      getImage();
    });
  }
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }
  getGroupImage() async {
    DatabaseServices().getGroupIcon(widget.groupId).then((value) {
      setState(() {
        widget.groupPic = value;
      });
    });
  }
  getImage() async {
    await SharedPref.getGroupPic().then((value) {
      setState(() {
        profilePic = value ?? "";
        getGroupImage();
        /*  getGroupPic();*/
      });
    });
  }



AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () async {
        await nextPage(
            context,
            ChatPage(
              userId: widget.userId,
              groupPic: widget.groupPic,
              username: widget.username,
              groupName: widget.groupName,
              groupId: widget.groupId,
              userProfile: widget.userProfile,
            ));
      },
      onLongPressStart: (details) {
        final offset = details.globalPosition;
        showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              offset.dx,
              offset.dy,
              offset.dx + 1,
              offset.dy + 1,
            ),
            items: [
              PopupMenuItem(
                onTap: () async {
                  String? getId = await (SharedPref.getGroupId());
                  setState(() {
                    FirebaseFirestore.instance
                        .collection('groups')
                        .doc(getId)
                        .delete();
                  });
                },
                child: const Text("Delete"),
              ),
              const PopupMenuItem(
                child: Text("Close"),
              ),
            ]);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child:SizedBox(
            width: 150, // set the desired width here
            child: ListTile(
              leading: SizedBox(
                width: 50,
                child: (widget.groupPic ?? "").isEmpty
                    ? CircleAvatar(
                  child: Text(
                    widget.groupName.substring(0, 2).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.network(
                    widget.groupPic ?? "",
                    height: 50,
                    width: 50,
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
                  ),
                ),
              ),
              title: _buildTitleText(),
              subtitle: _buildSubTitleText(),
            ),
          ),

        ),
      ),
    );
  }

  // SUB TITLE TEXT EXTRACT AS A METHOD
  Text _buildSubTitleText() {
    return Text("Join the Conversation as the ${widget.username.toString()}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13));
  }

  // TITLE TEXT EXTRACT AS A METHOD
  Text _buildTitleText() {
    return Text(
      widget.groupName.capitalize().toString(),
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }


}
