import 'package:chat/resources/widget.dart';
import 'package:chat/screens/ui/chat_page.dart';
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        nextPage(context, ChatPage(username: widget.username, groupName: widget.groupName, groupId: widget.groupId));
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
}
