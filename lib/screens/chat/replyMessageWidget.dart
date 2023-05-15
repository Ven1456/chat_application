import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReplyMessageWidget extends StatelessWidget {
  final String? previousMessage;
  final String? username;
  final String? replyMessage;
  final String? messageType;
  final VoidCallback? onCancelReply;
  bool? colorWhite;
  bool? isPreviousMessage;
  bool? isReplyMessage;

  ReplyMessageWidget({
    @required this.previousMessage,
    this.replyMessage,
    this.messageType,
    this.isReplyMessage,
    this.isPreviousMessage,
    this.colorWhite,
    this.onCancelReply,
    Key? key,
    this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          children: [
            Container(
              color: Colors.black,
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorWhite! ? Colors.white : Colors.black),
                ),
              ),
              if (onCancelReply != null)
                GestureDetector(
                  onTap: onCancelReply,
                  child: Icon(Icons.close,
                      size: 16,
                      color: colorWhite! ? Colors.white : Colors.black),
                )
            ],
          ),
          const SizedBox(height: 8),
          if (isPreviousMessage == true)
            messageType == 'text'
                ? Text(previousMessage!,
                    style: TextStyle(
                        color: colorWhite! ? Colors.white : Colors.black))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(21),
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      height: 150,
                      width: 200,
                      placeholder:
                      'assets/images/gallery.jpg',
                      placeholderErrorBuilder: (context,
                          url, error) =>
                          Image.asset(
                              'assets/images/404.jpg',
                              fit: BoxFit.cover),
                      imageErrorBuilder: (context, url,
                          error) =>
                          Image.asset(
                              'assets/images/error.jpg',
                              fit: BoxFit.cover),
                      image: previousMessage!,
                    ),
                  ),
          Text(replyMessage!,
              style:
                  TextStyle(color: colorWhite! ? Colors.white : Colors.black))
        ],
      );
}
