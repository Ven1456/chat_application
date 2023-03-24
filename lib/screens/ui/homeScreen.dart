import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/RegisterPage.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:chat/screens/ui/group_Tile.dart';
import 'package:chat/screens/ui/profile.dart';
import 'package:chat/screens/ui/search_page.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  String email = "";
  Stream? groups;
  AuthService authService = AuthService();
  bool _isLoading = false;
  String groupName = "";

  @override
  initState() {
    gettingUserData();
    // TODO: implement initState
    super.initState();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });

    await SharedPref.getName().then((value) {
      setState(() {
        username = value!;
      });
    });
    await SharedPref.getEmail().then((value) {
      setState(() {
        email = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                nextPage(context, const Search());
              },
              icon: const Icon(Icons.search))
        ],
        title: const Text(
          "Chats",
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.black,
            ),
            Text(
              username,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              height: 5,
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
              },
              leading: const Icon(Icons.group),
              title: const Text(
                "Chats",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {
                nextPage(
                    context,
                    Profile(
                      username: username,
                      email: email,
                    ));
              },
              leading: const Icon(Icons.person),
              title: const Text(
                "Profile",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          "LogOut",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                          "Are you sure you want Logout",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              )),
                          IconButton(
                              onPressed: () {
                                authService.signOut();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                    (route) => false);
                              },
                              icon: const Icon(
                                Icons.done,
                                color: Colors.green,
                              )),
                        ],
                      );
                    });
              },
              leading: const Icon(Icons.logout),
              title: const Text(
                "Log Out",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data["groups"] != null) {
              if (snapshot.data["groups"].length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data["groups"].length,
                  itemBuilder: (BuildContext context, int index) {
                    // reverse the index value
                    int reverseIndex = snapshot.data["groups"].length-index- 1;
                    return GroupTile(
                        groupName: getName(snapshot.data["groups"][reverseIndex]),
                        username: snapshot.data["fullName"],
                        groupId: getId(snapshot.data["groups"][reverseIndex]));
                  },
                );
              } else {
                return noGroupWidget();
              }
            } else {
              return noGroupWidget();
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Create A Group",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 60,
                  maxWidth: 150,
                ),
                child: Column(
                  children: [
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : TextField(
                            onChanged: (val) {
                              setState(() {
                                groupName = val;
                              });
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(21),
                                  borderSide:
                                      const BorderSide(color: Colors.blue)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(21),
                                  borderSide:
                                      const BorderSide(color: Colors.red)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(21),
                                  borderSide:
                                      const BorderSide(color: Colors.blue)),
                            ),
                          )
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
                ElevatedButton(
                    onPressed: () {
                      if (groupName != "" || groupName.isNotEmpty) {
                        setState(() {
                          _isLoading = true;
                        });
                        DatabaseServices(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .createGroup(
                                username,
                                FirebaseAuth.instance.currentUser!.uid,
                                groupName)
                            .whenComplete(() {
                          _isLoading = false;
                        });
                        Navigator.pop(context);
                        showSnackbar(context, Colors.green,
                            "Group Created Successfully");
                      }
                    },
                    child: const Text(
                      "Create",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
              ],
            );
          });
        });
  }

  noGroupWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: () {
                popUpDialog(context);
              },
              child: const Icon(
                Icons.add_circle_outline_outlined,
                size: 60,
              )),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "You are not created any Group not yet",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )
        ],
      ),
    );
  }
}
