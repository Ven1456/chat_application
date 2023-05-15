import 'dart:async';
import 'dart:io';
import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/profile_Controller.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/chat/message_tlle.dart';
import 'package:chat/screens/chat/replyMessageWidget.dart';
import 'package:chat/services/authentication_services/auth_service.dart';
import 'package:chat/services/database_services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../utils/InputFormatters.dart';
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
  bool? isInternetConnected;

  ChatPage(
      {Key? key,
      this.userId,
      this.messageImageUrl,
      this.groupPic,
      this.userProfile,
      this.isInternetConnected,
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
  final FocusNode textFieldFocus = FocusNode();
  String adminName = "";
  String groupsUsersProfile = "";
  bool? groupsender;
  bool isSwipe = false;
  bool isSend = false;
  bool isLoadingAnimation = false;
  final TextEditingController messageController = TextEditingController();
  double minHeight = 60;
  double maxHeight = 150;
  int maxLines = 10;
  String profilePic = '';
  String groupPicture = "";
  String message = "";
  String messageType = "";
  String replyMessage = "";
  String swipeUserName = "";
  final picker = ImagePicker();
  bool isPressed = false;
  AuthService authService = AuthService();
  static const inputTopRadius = Radius.circular(21);
  // late FlutterSoundRecorder _recorder;
  // final recorder = SoundRecorder();

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
  String audioMessageUrl = "";
  String userName = "";
  String userProfile = "";
  bool isUploading = false;
  // 21/04/23
  String messageUrl = "";
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instanceFor(
          bucket: 'gs://chatapp-4f907.appspot.com');
  // 21/04/23
  String repliedMessageId = "";
  String replyMessageType = "";
  bool isReplyMsg = false;
  String messageChatId = "";
  String isReplyMessage = "";

  @override
  void initState() {
    // 24/04/23
    SharedPref.saveAllGroupIds(widget.groupId);
    getChatAndAdminName();
    // TODO: implement initState
    super.initState();
    // _recorder = FlutterSoundRecorder();
    // recorder.init();
    setState(() {
      isLoadingAnimation = true;
      getImage();
    });
  }

  @override
  void dispose() {
    // recorder.clear();
    _scrollController.dispose();
    messageController.dispose();
    // _recorder.closeAudioSession();
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
      });
      widget.isInternetConnected == true ? connection(context) : SizedBox();
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
  Column _buildSendMessageButton(BuildContext context) {
    return Column(
      children: [
        isSwipe
            ? Container(
                width: MediaQuery.of(context).size.width * 0.96,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: inputTopRadius,
                    bottomLeft: inputTopRadius,
                    bottomRight: inputTopRadius,
                    topRight: inputTopRadius,
                  ),
                ),
                child: ReplyMessageWidget(
                  previousMessage: message,
                  colorWhite: false,
                  messageType: replyMessageType,
                  isReplyMessage: replyMessage.isNotEmpty ? true : false,
                  isPreviousMessage: replyMessage.isEmpty ? true : false,
                  onCancelReply: () {
                    setState(() {
                      isSwipe = false;
                    });
                  },
                  username: swipeUserName,
                  replyMessage: replyMessage,
                ),
              )
            : const SizedBox(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(21), topRight: Radius.circular(21)),
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
              GestureDetector(
                onLongPress: () {
                  setState(() {
                    isPressed = true;
                  });
                },
                onLongPressEnd: (details) {
                  setState(() {
                    isPressed = false;
                  });
                },
                child: AnimatedContainer(
                  height: isPressed ? 50 : 40,
                  width: isPressed ? 50 : 40,
                  decoration: BoxDecoration(
                      color: isPressed ? Colors.grey : Colors.cyan,
                      borderRadius: BorderRadius.circular(45)),
                  duration: Duration(milliseconds: 200),
                  child: Icon(
                    isPressed ? CupertinoIcons.stop_circle : CupertinoIcons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
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
                      focusNode: textFieldFocus,
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
                    isSwipe = false;
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
        ),
      ],
    );
  }

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
                      size: 35,
                    ))
                  : Image.network(
                      widget.groupPic.toString(),
                      height: 35,
                      width: 35,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          'assets/images/404.jpg',
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        );
                      },
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
                currentUser: widget.username,
                userProfile: groupsUsersProfile,
                groupPic: groupPicture,
                adminName: adminName,
                groupName: widget.groupName,
                groupId: widget.groupId,
                sender: groupsender.toString(),
              ),
            );
            setState(() {});
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
        if (!snapshot.hasData || snapshot.data.docs.length == 0) {
          return const Center(
            child: Text(
              "No Chat Available",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
            ),
          );
        }
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
                                messageChatId = snapshot.data.docs[index].id;
                                newDate = groupMessageDateAndTime(snapshot
                                        .data.docs[index]["time"]
                                        .toString())
                                    .toString();
                              } else {
                                final DateTime date = returnDateAndTimeFormat(
                                    snapshot.data.docs[index]["time"]
                                        .toString());
                                final DateTime prevDate =
                                    returnDateAndTimeFormat(snapshot
                                        .data.docs[index - 1]["time"]
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
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
                                  SwipeTo(
                                    onRightSwipe: () {
                                      // replyMessage(snapshot.data.docs[index]["message"]);
                                      textFieldFocus.requestFocus();
                                      setState(() {
                                        isSwipe = true;
                                        repliedMessageId =
                                            snapshot.data.docs[index].id;
                                        isReplyMsg = true;
                                      });
                                      message =
                                          snapshot.data.docs[index]["message"];
                                      messageType =
                                          snapshot.data.docs[index]["Type"];
                                      replyMessageType = messageType;
                                      replyMessage = snapshot.data.docs[index]
                                          ["replyMessage"];
                                      swipeUserName =
                                          snapshot.data.docs[index]["sender"];
                                    },
                                    child: showDeleteDialogue(
                                      child: MessageTile(
                                        replyMessageType: snapshot.data
                                            .docs[index]["replyMessageType"],
                                        isReply: snapshot.data.docs[index]
                                            ["replyMessage"],
                                        messageId: snapshot.data.docs[index].id,
                                        groupId: widget.groupId,
                                        message: snapshot.data.docs[index]
                                            ["message"],
                                        sendByMe: widget.username ==
                                            snapshot.data.docs[index]["sender"],
                                        sender: snapshot.data.docs[index]
                                            ["sender"],
                                        time: snapshot.data.docs[index]["time"]
                                            .toString(),
                                        userProfile: snapshot.data.docs[index]
                                            ["userProfile"],
                                        type: snapshot.data.docs[index]["Type"],
                                      ),
                                      context: context,
                                      onDeletedButtonTap: () {
                                        deleteMessage(
                                          widget.groupId,
                                          snapshot.data.docs[index].id
                                              .toString(),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  sizeBoxH5()
                                ],
                              );
                            }),
                      ),
                    ],
                  )
                : Container(),
            isUploading ? loadingAnimation(size: 150) : Container(),
            (_scrollController.hasClients &&
                    _scrollController.position.maxScrollExtent > 0 &&
                    snapshot.data.docs.length > 0)
                ? Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.cyan.withOpacity(0.7),
                      onPressed: () {
                        if (_scrollController.hasClients &&
                            _scrollController.position.maxScrollExtent > 0 &&
                            snapshot.data.docs.length > 0) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutExpo,
                          );
                        }
                      },
                      child: const Icon(Icons.arrow_downward),
                    ),
                  )
                : SizedBox(),
          ],
        );
      },
    );
  }

  sendMessages() {
    if (messageController.text.isNotEmpty) {
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   duration: const Duration(milliseconds: 300),
      //   curve: Curves.easeOut,
      // );
      // 21/04/23
      ProfileController().messageUrl;
      Map<String, dynamic> chatMessageMap = {
        "message": isSwipe
            ? replyMessage.isEmpty
                ? message
                : replyMessage
            : messageController.text.trim(),
        "sender": widget.username,
        "time": DateTime.now().microsecondsSinceEpoch,
        "userProfile": widget.userProfile,
        "Type": "text",
        "messageId": messageChatId,
        "replyMessage": isSwipe ? messageController.text.trim() : "",
        'repliedMessageId': repliedMessageId,
        'replyMessageType': replyMessageType,
        'isReplyMessage': isReplyMsg,
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
        "message": isSwipe
            ? replyMessage.isEmpty
                ? message
                : replyMessage
            : messageUrl,
        "sender": userName,
        "time": DateTime.now().microsecondsSinceEpoch,
        "userProfile": userProfile,
        "Type": "Image",
        "messageId": messageChatId,
        "replyMessage": isSwipe ? messageController.text.trim() : "",
        'repliedMessageId': repliedMessageId,
        'replyMessageType': replyMessageType,
        'isReplyMessage': isReplyMsg,
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

  // void uploadAudio(BuildContext context, String filePath) async {
  //   getId = (await SharedPref.getGroupId())!;
  //   // Create a reference to the Firebase Storage location where the voice message will be uploaded
  //   firebase_storage.Reference reference = storage
  //       .ref()
  //       .child('voice_messages')
  //       .child(getId)
  //       .child(DateTime.now().toString() + '.mp3');
  //
  //   // Upload the file to Firebase Storage
  //   firebase_storage.UploadTask uploadTask = reference.putFile(File(filePath));
  //
  //   // Wait for the upload to complete
  //   await uploadTask.whenComplete(() {});
  //
  //   // Return the download URL for the uploaded file
  //   String audioUrl = await reference.getDownloadURL();
  //   String userId = getId;
  //   DocumentSnapshot snapshot =
  //       await FirebaseFirestore.instance.collection('groups').doc(userId).get();
  //   if (snapshot.exists) {
  //     await FirebaseFirestore.instance.collection('groups').doc(userId).update({
  //       'recentMessage': audioUrl,
  //     });
  //     final user = FirebaseAuth.instance.currentUser!.uid;
  //     final docSnapshot =
  //         await FirebaseFirestore.instance.collection("users").doc(user).get();
  //     userName = docSnapshot.get("fullName");
  //     userProfile = docSnapshot.get("profilePic");
  //     audioMessageUrl = audioUrl;
  //     Map<String, dynamic> chatMessag = {
  //       "message": audioMessageUrl,
  //       "sender": userName,
  //       "time": DateTime.now().microsecondsSinceEpoch,
  //       "userProfile": userProfile,
  //       "Type": "Audio",
  //     };
  //     DatabaseServices().sendMessage(getId, chatMessag);
  //   }
  // }
  //
  // Widget micIcon() {
  //   var isRecording = recorder.isRecording;
  //   return GestureDetector(
  //     onLongPress: () async {
  //       isRecording = await recorder.toggledRecording();
  //       setState(() {});
  //     },
  //     onLongPressEnd: (details) {
  //       setState(() {});
  //     },
  //     child: AnimatedContainer(
  //       height: isRecording ? 50 : 40,
  //       width: isRecording ? 50 : 40,
  //       decoration: BoxDecoration(
  //           color: isRecording ? Colors.grey : Colors.cyan,
  //           borderRadius: BorderRadius.circular(45)),
  //       duration: Duration(milliseconds: 200),
  //       child: Icon(
  //         CupertinoIcons.mic,
  //         color: Colors.white,
  //       ),
  //     ),
  //   );
  // }
}
