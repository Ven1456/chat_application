import 'package:chat/resources/widget.dart';
import 'package:chat/screens/ui/group_info.dart';
import 'package:chat/screens/ui/message_tlle.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  Stream<QuerySnapshot>? chats;
  String adminName = "";
  final TextEditingController messageController = TextEditingController();

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
      body: Stack(
        children: <Widget>[
          chatMessages(),

          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[500],
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Send a Message",
                      border: InputBorder.none,
                    ),
                  )),
                  GestureDetector(
                    onTap: () {
                      sendMessages();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(21),
                        color: Colors.blue,
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      return MessageTile(
                          message: snapshot.data.docs[index]["message"],
                          sendByMe: widget.username ==
                              snapshot.data.docs[index]["sender"],
                          sender: snapshot.data.docs[index]["sender"],
                        time:  snapshot.data.docs[index]["time"].toString(),
                      );
                    }),
              )
              : Container();
        });
  }

  sendMessages() {
    if(messageController.text.isNotEmpty){
      Map<String,dynamic> chatMessageMap = {
        "message":messageController.text,
        "sender":widget.username,
        "time":DateFormat("hh:mm:ss a").format(DateTime.now())
      };
      DatabaseServices().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
