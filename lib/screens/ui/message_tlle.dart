
import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/profile_Controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MessageTile extends StatefulWidget {
  String message;
  String sender;
  String time;
  bool sendByMe;
  String? userProfile;
  MessageTile(
      {Key? key,
      this.userProfile,
      required this.time,
      required this.message,
      required this.sendByMe,
      required this.sender,
     })
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  String datetime = DateFormat("hh:mm a").format(DateTime.now());
  String email = '';
  String senderProfile = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      getProfilePic();
    });
  }

/*  getImage() async {
    QuerySnapshot snapshot = await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .gettingUserEmail(email);
    setState(() {

    });
  }*/
  getProfilePic() async {
    await SharedPref.getEmail().then((value) {
        email = value!;
    });
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final double maxWidth = isSmallScreen ? screenWidth * 0.75 : 300;
    return ChangeNotifierProvider(
        create: (_) => ProfileController(),
    child: Consumer<ProfileController>(
    builder: (context, provider, child) {
    return Row(
      mainAxisAlignment:
          widget.sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
          child:ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: (widget.userProfile ?? '').isEmpty ?  Center(
                child: Text(
                  widget.sender.substring(0, 2).toUpperCase(),
                  style:  TextStyle(
                    fontSize: isSmallScreen ? 12 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
            ) :  Image.network(
                height: 50,
                width: 50,
              widget.userProfile .toString(),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loading) {
                if (loading == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
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
                bottomLeft: widget.sendByMe
                    ? const Radius.circular(12.0)
                    : const Radius.circular(0.0),
                bottomRight: widget.sendByMe
                    ? const Radius.circular(0.0)
                    : const Radius.circular(12.0),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  getDateForChat(widget.time),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
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
                  child: Center(
                      // ignore: unnecessary_null_comparison
                      child: widget.userProfile != null
                          ? Consumer<ProfileController>(
                builder: (context, provider, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: provider.image == null
                                  ? (widget.userProfile ??"").isEmpty
                                  ? const Center(
                                    child: Icon(
                                Icons.person,
                                size: 30,
                              ),
                                  )
                                  : Image.network(
                                height: 50,
                                width: 50,
                                widget.userProfile ?? '',
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loading) {
                                  if (loading == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                              ) : Container()
                            );
                }
    )
                          : Text(
                              widget.sender.toUpperCase().substring(0, 2),
                              style: const TextStyle(color: Colors.white),
                            )),
                ),
              )
            : Container(),
      ],
    );
    }));
  }
}
