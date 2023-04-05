import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 5,
        ),

        widget.sendByMe ? Container() :Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(21)),
          child:   Center(
            child: Text(widget.sender.toUpperCase().substring(0,2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
          ),
        ),
        Column(
          children: [
            Text(getDateForChat(widget.time)),
            Container(
              padding: EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: widget.sendByMe ? 0 : 12,
                right: widget.sendByMe ? 14 : 0,
              ),
              child: Container(
                width: 240,
                margin: widget.sendByMe
                    ? EdgeInsets.only(left: 120)
                    : EdgeInsets.only(right: 120),
                padding: EdgeInsets.only(top: 17, left: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: widget.sendByMe
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(88),
                            topRight: Radius.circular(88),
                            bottomLeft: Radius.circular(88),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(88),
                            topRight: Radius.circular(88),
                            bottomRight: Radius.circular(88),
                          ),
                    color: widget.sendByMe ? Colors.blue : Colors.lightGreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   /*  Text(widget.sender.toUpperCase(),
                     textAlign: TextAlign.center,
                     style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),),*/

                    Text(
                      widget.message.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: widget.sendByMe ? const EdgeInsets.only(left: 240.0) :const EdgeInsets.only(right: 240.0) ,
              child: Text(widget.time),
            )
          ],
        ),
        widget.sendByMe ? Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(21)),
          child:   Center(
            child: Text(widget.sender.toUpperCase().substring(0,2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
          ),
        ) : Container(),

      ],
    );
  }
  static String getDateForChat(String datetime) {
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
  }
}
