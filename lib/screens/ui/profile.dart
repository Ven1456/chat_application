import 'package:chat/resources/widget.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:chat/screens/ui/homeScreen.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  String? username;

  String? email;

  Profile({Key? key, this.username, this.email}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("profile"),
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
              widget.username.toString(),
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
                replaceScreen(context, const HomeScreen());
              },
              leading: const Icon(Icons.group),
              title: const Text(
                "Chats",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {},
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 75,
          ),
          const Icon(
            Icons.account_circle,
            size: 180,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: const [
              SizedBox(
                width: 50,
              ),
              Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 33,
              ),
            ],
          ),
          Container(
            height: 60,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(21),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Text(
              widget.username!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(

            children: const [
              SizedBox(
                width: 50,
              ),
              Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 33,
              ),

            ],

          ),
          Container(
            height: 60,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(21),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child:  Text(
              widget.email!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
