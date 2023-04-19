import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/ui/chat_page.dart';
import 'package:chat/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GroupTile extends StatefulWidget {
  String groupId;
  String username;
  String groupName;
  String? groupPic;
  String userProfile;


  GroupTile(
      {Key? key,
        this.groupPic,
        required this.userProfile,
      required this.groupName,
      required this.username,
      required this.groupId})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
         nextPage(context, ChatPage(groupPic : widget.groupPic,username: widget.username, groupName: widget.groupName, groupId: widget.groupId,userProfile: widget.userProfile,));
      },
      onLongPressStart: ( details) {
        final offset = details.globalPosition;
        showMenu(context: context, position:  RelativeRect.fromLTRB(
          offset.dx,
          offset.dy,
          offset.dx + 1,
          offset.dy + 1,
        ), items: [
          PopupMenuItem(
            onTap: ()async {
              String?  getId = await( SharedPref.getGroupId());
           setState(()  {

             FirebaseFirestore.instance.collection('groups').doc(getId).delete();
           });
            },
            child: const Text("Delete"),
          ),

          const PopupMenuItem(
            child: Text("Close"),
          ),


        ]
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
        child: ListTile(
          leading: CircleAvatar(
              child: Text(
            widget.groupName.substring(0, 2).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
          title: Text(widget.groupName.toString(), style: const TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text("Join the Conversation as the ${widget.username.toString()}" ,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
        ),
      ),
    );
  }
}
