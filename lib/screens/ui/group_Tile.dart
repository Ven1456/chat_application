import 'dart:async';

import 'package:chat/resources/widget.dart';
import 'package:chat/screens/ui/chat_page.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatefulWidget {
  String groupId;
  String username;
  String groupName;

  GroupTile(
      {Key? key,
      required this.groupName,
      required this.username,
      required this.groupId})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
         nextPage(context, ChatPage(username: widget.username, groupName: widget.groupName, groupId: widget.groupId));
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
            onTap: (){
            /*  DatabaseServices().deleteUserData(FirebaseAuth.instance.currentUser!.uid).then((value)

              {
              });*/
            },
            child: Text("Delete"),
          ),

          PopupMenuItem(
            child: Text("Close"),
          ),


        ]);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
        child: ListTile(
          leading: CircleAvatar(
              child: Text(
            widget.groupName.substring(0, 2).toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          title: Text(widget.groupName.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text("Join the Conversation as the ${widget.username.toString()}" ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
        ),
      ),
    );
  }
  final List<String> options = ['Option 1', 'Option 2', 'Option 3'];

  void _showMenu(BuildContext context, Offset position) async {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      items: options.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );

   
  }

}
