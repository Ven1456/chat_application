import 'dart:async';

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
  final ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? chats;
  String adminName = "";
  bool isLoadingAnimation = false;
  final TextEditingController messageController = TextEditingController();
  double minHeight = 60;
  double maxHeight = 150;


  @override
  void initState() {
    getChatAndAdminName();

    // TODO: implement initState
    super.initState();
      setState(() {
        isLoadingAnimation = true;

      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  void resetHeight() {
    setState(() {
      minHeight = 60;
      maxHeight = 150;
    });
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
              child: const Icon(Icons.info)),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatMessages(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            color: Colors.lightBlue,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: minHeight,
                        maxHeight: maxHeight,

                      ),

                      child: TextFormField(
                        maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          final lines = value.split('\n').length;
                          if (lines < 2) {
                            setState(() {
                              minHeight = 60;
                              maxHeight = 150;
                            });
                          } else if (lines < 6) {
                            setState(() {
                              minHeight = 66;
                              maxHeight = 150;
                            });
                          } else if (lines <= 7) {
                            setState(() {
                              minHeight = 60 + (5 - 1) * 20;
                              maxHeight = 150 + (lines - 5) * 20;
                            });
                          } else {
                            final newLines = value.split('\n').sublist(0, 10);
                            final newValue = newLines.join('\n');
                            messageController.value = TextEditingValue(
                              text: newValue,
                              selection: TextSelection.collapsed(offset: newValue.length),
                            );
                            setState(() {
                              minHeight = 60 + (5 - 1) * 20;
                              maxHeight = 150 + (10 - 5) * 20;
                            });
                          }
                        },
                  decoration: const InputDecoration(
                      hintText: "Send a Message",
                      border: InputBorder.none,
                  ),
                ),
                    )),
                GestureDetector(
                  onTap: () {
                    sendMessages();
                    resetHeight();

                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      color: Colors.blue,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  // function to convert time stamp to date
  static DateTime returnDateAndTimeFormat(String time) {
    var dt = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    var originalDate = DateFormat('MM/dd/yyyy').format(dt);
    return DateTime(dt.year, dt.month, dt.day);
  }


  // function to return date if date changes based on your local date and time
  static String groupMessageDateAndTime(String time) {
    var dt = DateTime.fromMicrosecondsSinceEpoch(int.parse(time.toString()));
    var originalDate = DateFormat('MM/dd/yyyy').format(dt);

    final todayDate = DateTime.now();

    final today = DateTime(todayDate.year, todayDate.month, todayDate.day);
    final yesterday =
        DateTime(todayDate.year, todayDate.month, todayDate.day - 1);
    String difference = '';
    final aDate = DateTime(dt.year, dt.month, dt.day);

    if (aDate == today) {
      difference = "Today";
    } else if (aDate == yesterday) {
      difference = "Yesterday";
    } else {
      difference = DateFormat.yMMMd().format(dt).toString();
    }

    return difference;
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        isLoadingAnimation ? WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Scroll to the last item in the list
          if (_scrollController.hasClients) {
            Timer(
                const Duration(milliseconds: 2),
                () => _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent));
          }
        }) : "";
        return snapshot.hasData
            ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 28.0),
                        controller: _scrollController,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          bool isSameDate = false;
                          String? newDate = '';

                          final DateTime date = returnDateAndTimeFormat(
                              snapshot.data.docs[index]["time"].toString());

                          if (index == 0) {
                            newDate = groupMessageDateAndTime(snapshot
                                    .data.docs[index]["time"]
                                    .toString())
                                .toString();
                          } else {
                            final DateTime date = returnDateAndTimeFormat(
                                snapshot.data.docs[index]["time"].toString());
                            final DateTime prevDate = returnDateAndTimeFormat(
                                snapshot.data.docs[index - 1]["time"]
                                    .toString());
                            isSameDate = date.isAtSameMomentAs(prevDate);

                            newDate = isSameDate
                                ? ''
                                : groupMessageDateAndTime(snapshot
                                        .data.docs[index]["time"]
                                        .toString())
                                    .toString();
                          }
                          return Column(
                            children: [
                              if (newDate.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.lightGreen,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(newDate),
                                    ),
                                  ),
                                ),
                              MessageTile(
                                message: snapshot.data.docs[index]["message"],
                                sendByMe: widget.username ==
                                    snapshot.data.docs[index]["sender"],
                                sender: snapshot.data.docs[index]["sender"],
                                time: snapshot.data.docs[index]["time"]
                                    .toString(),
                              ),
                            ],
                          );
                        }),
                  ),
                ],
              )
            : Container();
      },
    );
  }

/*  chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      print(":${snapshot.data.docs.length}");
                      bool isSameDate = false;
                      String? newDate = '';

                      final DateTime date = returnDateAndTimeFormat(snapshot.data.docs[index]["time"].toString());


                      if(index == 0  && snapshot.data.docs.length ==  1){
                        newDate =  groupMessageDateAndTime(snapshot.data.docs[index]["time"].toString()).toString();
                      }else if(index == snapshot.data.docs.length - 1){
                        newDate =  groupMessageDateAndTime(snapshot.data.docs[index]["time"].toString()).toString();
                      }else {

                        final DateTime date = returnDateAndTimeFormat(snapshot.data.docs[index]["time"].toString());
                        final DateTime prevDate = returnDateAndTimeFormat(snapshot.data.docs[index + 1]["time"].toString());
                        isSameDate = date.isAtSameMomentAs(prevDate);

                        newDate =  isSameDate ?  "": groupMessageDateAndTime(snapshot.data.docs[index-1]["time"].toString()).toString() ;
                      }

                      return Column(
                        children: [
                          if(newDate.isNotEmpty)
                            Center(child:
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.lightGreen,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(newDate),
                                ))),
                          MessageTile(
                              message: snapshot.data.docs[index]["message"],
                              sendByMe: widget.username ==
                              snapshot.data.docs[index]["sender"],
                              sender: snapshot.data.docs[index]["sender"],
                              time:  snapshot.data.docs[index]["time"].toString(),
                          ),
                        ],
                      );
                    }),
              )
              : Container();
        });
  }*/

  sendMessages() {
    if (messageController.text.isNotEmpty) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.username,
        "time": DateTime.now().microsecondsSinceEpoch
      };
      DatabaseServices().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
