import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReplyMessageWidget extends StatelessWidget {
  final String? message;
  final String? username;
  final VoidCallback? onCancelReply;
  bool? colorWhite;

   ReplyMessageWidget({
    @required this.message,
    this.colorWhite, this.onCancelReply,
     Key? key, this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      children: [
        Container(
          color: Colors.green,
          width: 4,
        ),
        const SizedBox(width: 8),
        Expanded(child: buildReplyMessage()),
      ],
    ),
  );

  Widget buildReplyMessage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '$username',
              style: TextStyle(fontWeight: FontWeight.bold,color: colorWhite! ?  Colors.white:Colors.black),
            ),
          ),
          if (onCancelReply != null)
            GestureDetector(
              child: Icon(Icons.close, size: 16,color:  colorWhite! ?  Colors.white:Colors.black),
              onTap: onCancelReply,
            )
        ],
      ),
      const SizedBox(height: 8),
      Text(message!, style: TextStyle(color: colorWhite! ?  Colors.white:Colors.black)),
    ],
  );
}
