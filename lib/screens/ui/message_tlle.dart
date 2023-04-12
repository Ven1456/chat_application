import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:flutter/foundation.dart";

// ignore: must_be_immutable
class MessageTile extends StatefulWidget {
  String message;
  String sender;
  String time;
  bool sendByMe;

  MessageTile(
      {Key? key,
        required this.time,
      required this.message,
      required this.sendByMe,
      required this.sender})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  String datetime = DateFormat("hh:mm a").format(DateTime.now());
  String email = '';
  String profilePic = '';
  @override
  getUser() async {
    QuerySnapshot snapshot = await DatabaseServices(
        uid: FirebaseAuth.instance.currentUser!.uid)
        .gettingUserEmail( email ?? "");

    setState(() {
      profilePic = snapshot.docs[0]["profilePic"];
    });
  }
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final double maxWidth = isSmallScreen ? screenWidth * 0.75 : 300;

    return Row(
      mainAxisAlignment: widget.sendByMe
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        widget.sendByMe
            ? Container()
            : Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Container(
          width: isSmallScreen ? 40 : 50,
          height: isSmallScreen ? 40 : 50,
          margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
              color: Colors.green[300],
              shape: BoxShape.circle,
          ),
          child: Center(
              child: Text(
                widget.sender.substring(0, 2).toUpperCase(),
                style:  TextStyle(
                  fontSize: isSmallScreen ? 12 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
          ),
        ),
            ),
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 8.0,
            ),
            decoration: BoxDecoration(
              color: widget.sendByMe ? Colors.purple[300] : Colors.blue[500],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12.0),
                topRight: const Radius.circular(12.0),
                bottomLeft:
                widget.sendByMe ? const Radius.circular(12.0) : const Radius.circular(0.0),
                bottomRight:
                widget.sendByMe ? const Radius.circular(0.0) : const Radius.circular(12.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  getDateForChat(widget.time),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        widget.sendByMe
            ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
          width: isSmallScreen ? 40 : 50,
          height: isSmallScreen ? 40 : 50,
          margin: const EdgeInsets.only(left: 8.0),
          decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
          ),
          child:  Center(
              child:Text(widget.sender.toUpperCase().substring(0,2),style: TextStyle(color: Colors.white),)
          ),
        ),
            )
            : Container(),
      ],
    );
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.start,
    //   children: [
    //     const SizedBox(
    //       width: 5,
    //     ),
    //
    //     widget.sendByMe ? Container() :Container(
    //       height: 40,
    //       width: 40,
    //       decoration: BoxDecoration(
    //           color: Colors.blueGrey,
    //           borderRadius: BorderRadius.circular(21)),
    //       child:   Center(
    //         child: Text(widget.sender.toUpperCase().substring(0,2),
    //           textAlign: TextAlign.center,
    //           style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
    //       ),
    //     ),
    //     Column(
    //       children: [
    //        // Text(getDateForChat(widget.time)),
    //         Container(
    //           padding: EdgeInsets.only(
    //             top: 4,
    //             bottom: 4,
    //             left: widget.sendByMe ? 0 : 12,
    //             right: widget.sendByMe ? 14 : 0,
    //           ),
    //           child: Container(
    //             width: 240,
    //             margin:  widget.sendByMe ? MediaQuery.of(context).size.width < 2500 ? EdgeInsets.only(left: 0) :  EdgeInsets.only(right: 0) :
    //             MediaQuery.of(context).size.width < 2500 ? EdgeInsets.only(left: 0) :  EdgeInsets.only(right: 0),
    //             margin: widget.sendByMe
    //                 ? const EdgeInsets.only(left: 110) //120 default value
    //                 : const EdgeInsets.only(right: 110), //120 default value
    //             padding: const EdgeInsets.only(top: 17, left: 20, right: 20),
    //             decoration: BoxDecoration(
    //                 borderRadius: widget.sendByMe
    //                     ? const BorderRadius.only(
    //                         topLeft: Radius.circular(88),
    //                         topRight: Radius.circular(88),
    //                         bottomLeft: Radius.circular(88),
    //                       )
    //                     : const BorderRadius.only(
    //                         topLeft: Radius.circular(88),
    //                         topRight: Radius.circular(88),
    //                         bottomRight: Radius.circular(88),
    //                       ),
    //                 color: widget.sendByMe ? Colors.blue : Colors.lightGreen),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                  Text(widget.sender.toUpperCase(),
    //                  textAlign: TextAlign.center,
    //                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),),
    //
    //                 Text(
    //                   widget.message.toUpperCase(),
    //                   textAlign: TextAlign.center,
    //                   style: const TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 14,
    //                       color: Colors.white),
    //                 ),
    //                const SizedBox(
    //                   height: 20,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //
    //         Padding(
    //           padding: widget.sendByMe ? const EdgeInsets.only(left: 240.0) :const EdgeInsets.only(right: 240.0) ,
    //           child: Text(getDateForChat(widget.time)),
    //         )
    //       ],
    //     ),
    //     widget.sendByMe ? Container(
    //       height: 40,
    //       width: 40,
    //       decoration: BoxDecoration(
    //           color: Colors.blueGrey,
    //           borderRadius: BorderRadius.circular(21)),
    //       child:   Center(
    //         child: Text(widget.sender.toUpperCase().substring(0,2),
    //           textAlign: TextAlign.center,
    //           style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
    //       ),
    //     ) : Container(),
    //
    //     const SizedBox(height: 50,),
    //
    //   ],
    // );
  }
  static String getDateForChat(String datetime) {

    double time = int.parse(datetime) / 1000;
    // Create a DateTime object from the millisecond timestamp
    DateTime date = DateTime.fromMillisecondsSinceEpoch(time.toInt());

// Format the DateTime object to display only the time in jm format
    String formattedTime = DateFormat.jm().format(date);

// Print the formatted time

    return formattedTime;
  }

 /* static String getDateForChat(String datetime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    print("object : ${DateFormat("hh:mm:ss a").parse(datetime)}");

    final dateToCheck = DateTime.now();
    final aDate =
    DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    if (aDate == today) {
      return "Today";
    } else if (aDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('dd-MM-yyyy').format(dateToCheck);
    }
  }*/
}
