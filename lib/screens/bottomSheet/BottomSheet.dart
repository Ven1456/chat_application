import 'dart:async';

import 'package:chat/screens/homeScreen/homeScreen.dart';
import 'package:chat/screens/profile/profile.dart';
import 'package:chat/screens/search/search_page.dart';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../resources/widget.dart';

class BottomSheetTest extends StatefulWidget {
  final int? screenIndex;
  final  bool? isProfileScreen;
   const BottomSheetTest({
    Key? key, this.screenIndex, this.isProfileScreen
  }) : super(key: key);

  @override
  State<BottomSheetTest> createState() => _BottomSheetTestState();
}

class _BottomSheetTestState extends State<BottomSheetTest> with WidgetsBindingObserver{
  int currentIndex = 0;
  // final internetChecker = InternetConnectivityObserver();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult result = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);
    if (widget.isProfileScreen != null) {
      currentIndex = widget.screenIndex ?? 2;
    } else {
      currentIndex = 0;
    }
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  buildPages() {
    return [
       HomeScreen(isConnected:result == _connectionStatus),
      const Search(),
      Profile(),
    ];
  }

  void setStatus(bool status) async {
    final user = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("users").doc(user).update(
        {"onlineStatus": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus(true);
    } else {
      setStatus(false);
    }
  }
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
    (result == _connectionStatus )? initConnectivity() : SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPages()[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTap,
        currentIndex: currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.deepPurple.withOpacity(0.9),
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            label: "Chats",
            icon: Icon(CupertinoIcons.chat_bubble),
          ),
          BottomNavigationBarItem(
            label: "Search",
            icon: Icon(CupertinoIcons.search),
          ),
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(CupertinoIcons.person),
          ),
        ],
      ),
    );
  }
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
      if (result == _connectionStatus) {
        // ignore: use_build_context_synchronously
        connection(context);
      }
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }
}

