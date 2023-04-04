import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  String message;
  String sender;
  bool sendByMe;

   MessageTile({Key? key,required this.message,required this.sendByMe,required this.sender}) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
      top: 4,
        bottom: 4,
          left: widget.sendByMe ? 0:12,
        right: widget.sendByMe ? 12:0,
      ),
      child: Container(
        margin: widget.sendByMe ? EdgeInsets.only(left:30): EdgeInsets.only(left:40),
        padding: EdgeInsets.only(top: 17,left: 20,right: 20),
        decoration: BoxDecoration(
          borderRadius: widget.sendByMe ?  const BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
            bottomLeft: Radius.circular(45),
          ):const BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
            bottomRight: Radius.circular(45),
          ),
          color: widget.sendByMe ? Colors.blue : Colors.grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(widget.sender.toUpperCase(),
             textAlign: TextAlign.center,
             style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),),
            const SizedBox(height: 2,),
            Text(widget.message.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.white),

            ),
            const SizedBox(height: 5,),
          ],
        ),

      ),
    );
  }
}

