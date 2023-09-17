import 'package:chatapp/Screens/Homepage.dart';
import 'package:chatapp/Screens/LoginScreens.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreens extends StatefulWidget {
  const SplashScreens({Key? key}) : super(key: key);

  @override
  State<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  checklogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("name")) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Homepage(),
      ));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginScreens(),
      ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    checklogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "Chat App",
            style: TextStyle(fontSize: 25.0),
          )),
        ],
      ),
    );
  }
}
