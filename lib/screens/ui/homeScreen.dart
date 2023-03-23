import 'package:chat/resources/Shared_Preferences.dart';
import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/RegisterPage.dart';
import 'package:chat/screens/auth/login_screen.dart';
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
  String email ="";
Stream?groups;
AuthService authService = AuthService();
  @override
 initState()  {
    gettingUserData();
    // TODO: implement initState
    super.initState();


  }
  gettingUserData() async {

    await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid).getUserGroups().then((snapshot){
      setState(() {
        snapshot = groups;
      });
    });

   await  SharedPref.getName().then((value)  {
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
                nextPage(context, Profile(username: username,email: email,));
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
                                        builder: (context) => const LoginPage()),
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
        onPressed: (){
          popUpDialog(context);
        },
        elevation: 0,
        child: Icon(Icons.add),
      ),
    );
  }

  groupList() {


  }

  popUpDialog(BuildContext context) {}

}
