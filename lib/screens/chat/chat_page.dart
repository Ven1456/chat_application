import 'dart:async';
import 'dart:io';
import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/chat/message_tlle.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../groups/group_info.dart';

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  String username;
  String groupName;
  String groupId;
  String? groupPic;
  String? userProfile;
  String? userId;
  String? messageImageUrl;

  ChatPage(
      {Key? key,
      this.userId,
      this.messageImageUrl,
      this.groupPic,
      this.userProfile,
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
  int maxLines = 10;
  String profilePic = '';
  String groupPicture = "";
  final picker = ImagePicker();
  AuthService authService = AuthService();
  // 21/04/23
  XFile? _messageImage;
  // 21/04/23
  XFile? get messageImage => _messageImage;
  XFile? _groupImage;
  XFile? get groupImage => _groupImage;
  XFile? _image;
  XFile? get image => _image;
  String getId = "";
  String url = "";
  String userName = "";
  String userProfile = "";
  bool isUploading = false;
  // 21/04/23
  String messageUrl = "";
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instanceFor(
          bucket: 'gs://chatapp-4f907.appspot.com');
  // 21/04/23
  String messageChatUrl = "";

  @override
  void initState() {
    // 24/04/23
    SharedPref.saveAllGroupIds(widget.groupId);
    getChatAndAdminName();
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoadingAnimation = true;
      getImage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void resetHeight() {
    setState(() {
      minHeight = 60;
      maxHeight = 150;
    });
  }

  getGroupImage() async {
    DatabaseServices().getGroupIcon(widget.groupId).then((value) {
      setState(() {
        widget.groupPic = value;
      });
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

  getImage() async {
    await SharedPref.getGroupPic().then((value) {
      setState(() {
        profilePic = value ?? "";
        getGroupImage();
        /*  getGroupPic();*/
      });
    });
  }

  bool _isShowEmoji = false;
  final chatFromKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if (_isShowEmoji) {
            setState(() {
              _isShowEmoji = !_isShowEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: Form(
            key: chatFromKey,
            child: Column(
              children: [
                // CHAT MESSAGE DESIGN
                _buildChatMessages(),
                // SEND MESSAGE BUTTON
                _buildSendMessageButton(context),
                if (_isShowEmoji)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .35,
                    child: EmojiPicker(
                      textEditingController: messageController,
                      config: Config(
                          bgColor: Colors.white,
                          columns: 8,
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0)),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SEND MESSAGE BUTTON EXTRACT AS A METHOD
  Container _buildSendMessageButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(21),topRight: Radius.circular(21)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _isShowEmoji = !_isShowEmoji;
              });
            },
            icon: const Icon(
              CupertinoIcons.smiley,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                minHeight: minHeight,
                maxHeight: maxHeight,
              ),
              child: TextFormField(
                  onTap: () {
                    if (_isShowEmoji) {
                      setState(() {
                        _isShowEmoji = !_isShowEmoji;
                      });
                    }
                  },
                  maxLines: null,
                  inputFormatters: [
                    TrimTextFormatter(),
                    NewLineTrimTextFormatter(),
                  ],
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
                    } else if (lines <= 10) {
                      setState(() {
                        minHeight = 60 + (5 - 1) * 20;
                        maxHeight = 150 + (lines - 5) * 20;
                        maxLines = lines;
                      });
                    } else {
                      setState(() {
                        maxLines = maxLines;
                      });
                    }
                  },
                  keyboardType: TextInputType.multiline,
                  controller: messageController,
                  decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: "Send Message")),
            ),
          ),
          IconButton(
            onPressed: () {
              // 21/04/23
             pickMessageImage(context);
            },
            icon: const Icon(
              Icons.photo,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              if (chatFromKey.currentState!.validate()) {
                sendMessages();
                resetHeight();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CHAT MESSAGE  EXTRACT AS A METHOD
  Expanded _buildChatMessages() {
    return Expanded(
      child: chatMessages(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: (widget.groupPic ?? "").isEmpty
                  ? const Center(
                      child: Icon(
                      Icons.person,
                      size: 30,
                    ))
                  : Image.network(
                      widget.groupPic.toString(),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )),
          const SizedBox(width: 80),
          Expanded(
            child: Text(
              widget.groupName.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            nextPage(
              context,
              GroupInfo(
                groupPic: groupPicture,
                adminName: adminName,
                groupName: widget.groupName,
                groupId: widget.groupId,
              ),
            );
          },
          icon: const Icon(
            Icons.info_outline_rounded,
            size: 30,
          ),
        ),
      ],
    );
  }

  // function to convert time stamp to date
  static DateTime returnDateAndTimeFormat(String time) {
    var dt = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    /* var originalDate = DateFormat('MM/dd/yyyy').format(dt);*/
    return DateTime(dt.year, dt.month, dt.day);
  }

  // function to return date if date changes based on your local date and time
  static String groupMessageDateAndTime(String time) {
    var dt = DateTime.fromMicrosecondsSinceEpoch(int.parse(time.toString()));
    /*  var originalDate = DateFormat('MM/dd/yyyy').format(dt);*/

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
        isLoadingAnimation
            ? WidgetsBinding.instance.addPostFrameCallback((_) async {
                // Scroll to the last item in the list
                if (_scrollController.hasClients) {
                  Timer(
                      const Duration(milliseconds: 2),
                      () => _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent));
                }
              })
            : "";
        return Stack(
          children: [
            snapshot.hasData
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
                              userProfile: snapshot.data.docs[index]
                              ["userProfile"],
                              type: snapshot.data.docs[index]["Type"],
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ) : Container(),
            isUploading
                ? Container(
              color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator(
              color: Colors.white,
            )),
                ) // Show a loading widget
                : Container(),
          ],
        );
      },
    );
  }

  sendMessages() {
    if (messageController.text.isNotEmpty) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      // 21/04/23
      ProfileController().messageUrl;
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text.trim(),
        "sender": widget.username,
        "time": DateTime.now().microsecondsSinceEpoch,
        /* "groupPic":groupPicture,*/
        "userProfile": widget.userProfile,
        "Type": "text",
      };
      DatabaseServices().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  // MESSAGE UPLOAD IMAGE
  void uploadMessageImage(BuildContext context) async {
    if (_messageImage == null) {
      return;
    }
    setState(() {
      isUploading = true;
    });
    String fileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    // @ 24/04/23
    getId = (await SharedPref.getAllGroupId())!;
    firebase_storage.Reference reference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child("/messagePhoto")
        .child(getId)
        .child(fileName);
    firebase_storage.UploadTask uploadTask =
        reference.putFile(File(_messageImage!.path).absolute);
    await Future.value(uploadTask);
    uploadTask.whenComplete(() {
      setState(() {
        isUploading = false;
      });
    });

    String downloadUrl = await reference.getDownloadURL();
    String userId = getId;
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('groups').doc(userId).get();
    if (snapshot.exists) {
      await FirebaseFirestore.instance.collection('groups').doc(userId).update({
        'recentMessage': downloadUrl,
      });
      final user = FirebaseAuth.instance.currentUser!.uid;
      final docSnapshot =
          await FirebaseFirestore.instance.collection("users").doc(user).get();
      userName = docSnapshot.get("fullName");
      userProfile = docSnapshot.get("profilePic");
      messageUrl = downloadUrl;
      Map<String, dynamic> chatMessag = {
        "message": messageUrl,
        "sender": userName,
        "time": DateTime.now().microsecondsSinceEpoch,
        "userProfile": userProfile,
        "Type": "Image",
      };
      DatabaseServices().sendMessage(getId, chatMessag);
    }
  }
// MESSAGE IMAGE
  void pickMessageImage(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 120,
              width: 120,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      pickCameraMessageImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.camera),
                    title: const Text("Camera"),
                  ),
                  ListTile(
                    onTap: () {
                      pickGalleryMessageImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.image),
                    title: const Text("Image"),
                  )
                ],
              ),
            ),
          );
        });
  }

  // 21/04/23
  // IMAGE PICK FROM GALLERY
  Future pickGalleryMessageImage(BuildContext context) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _messageImage = XFile(pickedFile.path);
      _messageImage = await _CropImage(imageFile: _messageImage);
      // ignore: use_build_context_synchronously
      setState(() {
        uploadMessageImage(context);
      });
    }
  }

  Future<XFile?> _CropImage({XFile? imageFile}) async {
    if (imageFile == null) return null;
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return XFile(croppedImage.path);
  }

  // 21/04/23
  // IMAGE PICK FROM CAMERA
  Future pickCameraMessageImage(BuildContext context) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      _messageImage = XFile(pickedFile.path);
      // ignore: use_build_context_synchronously
      setState(() {
        uploadMessageImage(context);
      });
    }
  }
}
