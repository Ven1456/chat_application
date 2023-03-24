import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/ui/chat_page.dart';
import 'package:chat/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  bool isUserJoined=false;

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
String getName(String res ){
    return res.substring(res.indexOf("_")+1);
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            color: Colors.blue,
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  cursorColor: Colors.white,
                  controller: searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search Groups Here....",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                )),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(21)),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : groupList(),
        ],
      ),
    );
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                  username,
                  searchSnapshot!.docs[index]["groupId"],
                  searchSnapshot!.docs[index]["groupName"],
                  searchSnapshot!.docs[index]["admin"]);
            })
        : Container();
  }

  joinedOrNot(
      String username, String groupId, String groupName, String admin) async {
    await DatabaseServices(uid: user!.uid).isUserJoined(groupName, groupId, username).then((value){
      setState(() {
        isUserJoined = value;
      });
    });
  }

  Widget groupTile(
      String username, String groupId, String groupName, String admin) {
    joinedOrNot(username, groupId, groupName, admin);
    return ListTile(
      leading: CircleAvatar(
        child: Text(groupName.substring(0,2),style: TextStyle(fontWeight: FontWeight.bold),),

      ),
      title: Text(groupName,style: TextStyle(fontWeight: FontWeight.bold),),
      subtitle: Text("Admin : ${getName(admin)}",style: TextStyle(fontWeight: FontWeight.w600),),
      trailing: InkWell(
        onTap: () async{
          await DatabaseServices(uid: user!.uid).toggleGroupJoin(groupId, username, groupName);
          if(isUserJoined)
            {
              setState(() {
                isUserJoined = !isUserJoined;
              });
              showSnackbar(context, Colors.green, "Successfully Joined Group");
              Future.delayed(Duration(seconds: 2),(){
                nextPage(context, ChatPage(username: username, groupName: groupName, groupId: groupId));
              });
            }
          else
            {
              setState(() {
                isUserJoined = !isUserJoined;
                showSnackbar(context, Colors.green, "Left the  Group $groupName}");
              });
            }

        },
        child: isUserJoined ? Container(

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white)
          ),
          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          child: Text("Joined",style: TextStyle(color: Colors.white),),
        ):Container(
          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
              border: Border.all(color: Colors.white)
          ),
          child: Text("Joined Now ",style: TextStyle(color: Colors.white),),
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
  }
}
