import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/ui/chat_page.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
  bool isUserJoined = false;
  bool isTextFieldEmpty = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserIdAndName();
  }

  getCurrentUserIdAndName() async {
    await SharedPref.getName().then((value) {
      username = value!;
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
              color: Colors.blue,
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    cursorColor: Colors.white,
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Search Groups Here....",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                        onChanged: (value){
                          setState(() {
                            isTextFieldEmpty = value.isEmpty;
                          });
                        },
                  )),
                  GestureDetector(
                        onTap: () {
                       if(!isTextFieldEmpty){
                         setState(() {
                           hasUserSearched = true;
                         });
                         hasUserSearched ? initiateSearchMethod():
                         dataNotFound();
                       }
                      },

                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(21)),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  )
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
                              "https://assets1.lottiefiles.com/packages/lf20_p8bfn5to.json")),
                      // child: CircularProgressIndicator(),
                    ),
                  )
                : groupList()
          ],
        ),
      ),
    );
  }

  groupList() {

    return hasUserSearched
        ? searchSnapshot?.docs.length != 0 ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                  username,
                  searchSnapshot!.docs[index]["groupId"],
                  searchSnapshot!.docs[index]["groupName"],
                  searchSnapshot!.docs[index]["admin"]);
            }):const SizedBox(
        height: 650,
        child: Center(
          child: Text(
            "NO DATA FOUND",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                ))  :  const SizedBox(
        height: 650,
        child: Center(
          child: Text(
            "NO DATA FOUND",
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
            setState(() {
              isUserJoined = !isUserJoined;
            });
            showSnackbar(context, Colors.green, "Successfully Joined Group");
            Future.delayed(const Duration(seconds: 1), () {
              nextPage(
                  context,
                  ChatPage(
                      username: username,
                      groupName: groupName,
                      groupId: groupId));
            });
          } else {
            setState(() {
              isUserJoined = !isUserJoined;
              showSnackbar(context, Colors.red, "Left the  Group $groupName");
            });
          }
        },
        child: isUserJoined
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                    boxShadow: [
                      const BoxShadow(
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
                    boxShadow: [
                      const BoxShadow(
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
      ),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseServices()
          .getSearchByName(searchController.text)
          .then((value) {
        setState(() {

          searchSnapshot = value;
          _isLoading = false;
          hasUserSearched = true;

        });
      });
    }
    /*else if{
      print("ddd");
      noData ? const Center(child: Text("No Data Found"),) : const SizedBox();
    }*/
    /*  else if (searchController.text.isEmpty) {
      await DatabaseServices()
          .getSearchByName(searchController.text)
          .then((value) {
        setState(() {
          searchSnapshot = value;
          _isLoading = false;
          hasUserSearched = true;
        });
      });
      Center(child: Text("No Data Found"));
    }*/
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
