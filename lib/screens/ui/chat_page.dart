import 'package:chat/resources/widget.dart';
import 'package:chat/screens/ui/group_info.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  String username;
  String groupName;
  String groupId;

  ChatPage(
      {Key? key,
      required this.username,
      required this.groupName,
      required this.groupId})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream <QuerySnapshot>? chats;
  String adminName = "";

  @override
  void initState() {
    getChatAndAdminName();
    // TODO: implement initState
    super.initState();
  }

  void getChatAndAdminName() {
    DatabaseServices().getCharts(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });
    DatabaseServices().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        adminName = value;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.groupName.toString()),
        elevation: 0,
        actions: [
          GestureDetector(
              onTap: () {
                nextPage(
                    context,
                    GroupInfo(
                        adminName: adminName,
                        groupName: widget.groupName,
                        groupId: widget.groupId));
              },
              child: Icon(Icons.info)),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
}
