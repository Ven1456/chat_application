import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/chat/chat_page.dart';
import 'package:chat/services/database_services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:toast/toast.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String username = "";
  User? user;
  bool noData = false;
  bool isButtonDisabled = false;
  bool isUserJoined = false;
  bool isTextFieldEmpty = true;
  bool _isPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserIdAndName();
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        initiateSearchMethod();
      }
    });
  }

  getCurrentUserIdAndName() async {
    await SharedPref.getName().then((value) {
      username = value;
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  @override
  void dispose() {
    if (searchController.text.isEmpty) {
      searchController.removeListener(initiateSearchMethod);
    }
    super.dispose();
  }

  final searchFromKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        titleText: "Search",
        context: context,
        isBack: false,
        textStyleColor: Colors.white,
        color: Colors.blue,
      ),
      body: Form(
        key: searchFromKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        cursorColor: Colors.black,
                        controller: searchController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            errorStyle: const TextStyle(color: Colors.red),
                            hintText: "Search Groups Here....",
                            hintStyle: const TextStyle(color: Colors.grey),

                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(12.0)),
                              borderSide:
                              BorderSide(color: Colors.red, width: 2),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.blueGrey),
                            ),
                          suffixIcon: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return IconButton(
                                icon: searchController.text.isEmpty
                                    ? const Icon(Icons.search)
                                    : const Icon(Icons.clear),
                                onPressed: () {
                                  if (searchController.text.isEmpty) {
                                    setState(() {});
                                    dataNotFound();
                                  } else {
                                    searchController.clear();
                                    setState(() {});
                                  }
                                },
                              );
                            },
                          ),
                        ),
                            // suffixIcon: GestureDetector(
                            //   onTap: () {
                            //     if (searchFromKey.currentState!.validate()) {
                            //       if (!isTextFieldEmpty) {
                            //         setState(() {
                            //           hasUserSearched = true;
                            //         });
                            //         hasUserSearched
                            //             ? initiateSearchMethod()
                            //             : dataNotFound();
                            //       }
                            //     }
                            //   },
                            //   child: Container(
                            //     width: 40,
                            //     height: 40,
                            //     decoration: BoxDecoration(
                            //         color: Colors.white.withOpacity(0.2),
                            //         borderRadius: BorderRadius.circular(21)),
                            //     child: const Icon(
                            //       Icons.search,
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            // )

                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Please Enter AtLeast 1 Characters";
                          } else if (val.trim().isEmpty) {
                            return "Please Search A Group Without Spaces";
                          } else if (val.trim().replaceAll(' ', '').isEmpty) {
                            return "Please Search A Group That Contains Text";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            isTextFieldEmpty = value.isEmpty;
                            if (isTextFieldEmpty) {
                              _isLoading = false;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? SizedBox(
                      height: 650,
                      child: Center(
                        child: SizedBox(
                            height: 150,
                            width: 100,
                            child: Lottie.network(
                                "https://assets1.lottiefiles.com/packages/lf20_p8bfn5to.json",
                              errorBuilder: (BuildContext context,
                                  Object exception,
                                  StackTrace? stackTrace) {
                                return Image.asset(
                                  'assets/images/404.jpg',
                                  height: 35,
                                  width: 35,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),

                        ),
                        // child: CircularProgressIndicator(),
                      ),
                    )
                  : groupList()
            ],
          ),
        ),
      ),
    );
  }

  groupList() {
    return hasUserSearched
        ? searchSnapshot?.docs.length != 0
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: searchSnapshot!.docs.length,
                itemBuilder: (context, index) {
                  return searchController.text.isEmpty  ? Container() : groupTile(
                      username,
                      searchSnapshot!.docs[index]["groupId"],
                      searchSnapshot!.docs[index]["groupName"],
                      searchSnapshot!.docs[index]["admin"]);
                })
            : SizedBox(
                height: 650,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                          height: 400,
                          width: 350,
                          child: Lottie.network(
                              "https://assets1.lottiefiles.com/packages/lf20_PjZ5YynQSK.json")),
                      const Positioned(
                        bottom: 35,
                        child: Text(
                          "NO GROUP FOUND",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ))
        : searchController.text.isEmpty
            ? const SizedBox(
                height: 650,
                child: Center(
                  child: Text(
                    "SEARCH YOUR GROUP",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ))
            : const SizedBox(
                height: 650,
                child: Center(
                  child: Text(
                    "NO GROUP FOUND",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ));
  }

  joinedOrNot(
      String username, String groupId, String groupName, String admin) async {
    await DatabaseServices(uid: user!.uid)
        .isUserJoined(groupName, groupId, username)
        .then((value) {
      setState(() {
        isUserJoined = value;
      });
    });
  }

  Widget groupTile(
      String username, String groupId, String groupName, String admin) {
    joinedOrNot(username, groupId, groupName, admin);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        child: Text(
          groupName.substring(0, 2).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "Admin : ${getName(admin)}",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: GestureDetector(
        onTap: () async {
          await DatabaseServices(uid: user!.uid)
              .toggleGroupJoin(groupId, username, groupName);
          if (isUserJoined) {
            if (_isPressed) {
              return;
            }
            _isPressed = true;
            Future.delayed(const Duration(seconds: 2), () {
              _isPressed = false;
            });
            ToastContext toastContext = ToastContext();
            // ignore: use_build_context_synchronously
            toastContext.init(context);
            Toast.show(
              "Successfully Joined Group",
              duration: Toast.lengthShort,
              rootNavigator: true,
              gravity: Toast.bottom,
              webShowClose: true,
              backgroundColor: Colors.green,
            );
            // ignore: use_build_context_synchronously
            nextPage(
                context,
                ChatPage(
                    username: username,
                    groupName: groupName,
                    groupId: groupId));

          } else {
            ToastContext toastContext = ToastContext();
            // ignore: use_build_context_synchronously
            toastContext.init(context);
            Toast.show(
              "Left the  Group $groupName",
              duration: Toast.lengthShort,
              rootNavigator: true,
              gravity: Toast.bottom,
              webShowClose: true,
              backgroundColor: Colors.red,
            );
          }
        },
        child: SizedBox(
          height: 100,
          width: 80,
          child: Row(children: [
            if (isUserJoined)
              Container(
                height: 40,
                width: 75,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //
                    ],
                    border: Border.all(color: Colors.white)),
                child: const Center(
                  child: Text(
                    "left",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Container(
                height: 40,
                width: 75,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //
                    ],
                    border: Border.all(color: Colors.white)),
                child: const Center(
                  child: Text(
                    "join",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ]),
        ),
      ),
/*      trailing: GestureDetector(
        onTap: () async {
          await DatabaseServices(uid: user!.uid)
              .toggleGroupJoin(groupId, username, groupName);

          if (_isPressed) {
            return;
          }
          _isPressed = true;
          Future.delayed(const Duration(seconds: 2), () {
            _isPressed = false;
          });

          if (isUserJoined) {
            setState(() {
              isUserJoined = !isUserJoined;
            });
            ToastContext toastContext = ToastContext();
            // ignore: use_build_context_synchronously
            toastContext.init(context);
            Toast.show(
              "Successfully Joined Group",
              duration: Toast.lengthShort,
              rootNavigator: true,
              gravity: Toast.bottom,
              webShowClose: true,
              backgroundColor: Colors.green,
            );

            // ignore: use_build_context_synchronously
            nextPage(
                context,
                ChatPage(
                    username: username,
                    groupName: groupName,
                    groupId: groupId));
          } else {
            setState(() {
              isUserJoined = !isUserJoined;
              ToastContext toastContext = ToastContext();
              toastContext.init(context);
              Toast.show(
                "Left the  Group $groupName",
                duration: Toast.lengthShort,
                rootNavigator: true,
                gravity: Toast.bottom,
                webShowClose: true,
                backgroundColor: Colors.red,
              );
            });
          }
        },
        child: isUserJoined
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //
                    ],
                    border: Border.all(color: Colors.white)),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text(
                  "Exit Group",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //
                    ],
                    border: Border.all(color: Colors.white)),
                child: const Text(
                  "Join Now ",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),*/
    );
  }

  initiateSearchMethod() async {
    setState(() {
      _isLoading = true;
    });
    String query = searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        searchSnapshot = null;
        _isLoading = false;
        hasUserSearched = false;
      });
      return;
    }
    await DatabaseServices().getSearchByTextFieldName(query).then((value) {
      if (searchController.text.trim() != query) {
        // The query has changed since we started searching, so discard the results
        return;
      }
      setState(() {
        searchSnapshot = value;
        _isLoading = false;
        hasUserSearched = true;
      });
    });
  }

  dataNotFound() async {
    if (searchController.text.length > 1) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseServices()
          .searchByNameNotFound(searchController.text)
          .then((value) {
        setState(() {
          _isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }
}
