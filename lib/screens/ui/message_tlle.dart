
import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:flutter/foundation.dart";
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MessageTile extends StatefulWidget {
  String message;
  String sender;
  String time;
  bool sendByMe;
  String? groupPic;
  String userProfile;




  MessageTile(
      {Key? key,
        this.groupPic,
        required  this.userProfile,
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
  String profilePic = '';
  String senderProfile = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getProfilePic();
    setState(() {
    });

/*    getUser();*/
  /*  getUser();*/
  }
 /* getImage() async {
    QuerySnapshot snapshot = await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .gettingUserPic();
    setState(() {
      senderProfile = snapshot.docs[0]["profilePic"];
      profilePic = snapshot.docs[0]["profilePic"];
    });
  }
  getSendByImage() async {
    QuerySnapshot snapshot = await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .gettingUserEmail(email);
    setState(() {
      profilePic = snapshot.docs[0]["profilePic"];
    });
  }*/
  getProfilePic() async {
    await SharedPref.getProfilePic().then((value) {
      setState(() {
       profilePic = value!;
     /*   getImage();
       getSendByImage();*/
      });
    });
  }
 /* getUser() async {
    await SharedPref.getProfilePic().then((value) {
      setState(() {
        profilePic = value ?? "";
        final user = AuthService().firebaseAuth.currentUser!.uid;
        DatabaseServices(uid: user);
      });
    });
  }*/
/*getProfilePic()async{
  QuerySnapshot snapshot = await DatabaseServices(
      uid: FirebaseAuth.instance.currentUser!.uid).gettingUserEmail(email);
  if (snapshot.docs.isNotEmpty){
    String value = snapshot.docs[0]["profilePic"];
    setState(() {
      profilePic = value;
    });
  }*/

  /*DatabaseServices().setUserProfilePicture(profilePic).then((value) {
      setState(() {
        profilePic = value;
      });
    });*/


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
            child: senderProfile.isEmpty ?  Center(
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
              senderProfile.toString(),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loading) {
                if (loading == null) return child;
                return Center(child: CircularProgressIndicator());
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
                      child: profilePic != null
                          ? Consumer<ProfileController>(
                builder: (context, provider, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: provider.image == null
                                  ? (profilePic).isEmpty
                                  ? const Center(
                                    child: Icon(
                                Icons.person,
                                size: 30,
                              ),
                                  )
                                  : Image.network(
                                height: 50,
                                width: 50,
                                profilePic,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loading) {
                                  if (loading == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                              ) : Container()
                            );
                }
    )
                          : Text(
                              widget.sender.toUpperCase().substring(0, 2),
                              style: TextStyle(color: Colors.white),
                            )),
                ),
              )
            : Container(),
      ],
    );
    }));
  }
}
