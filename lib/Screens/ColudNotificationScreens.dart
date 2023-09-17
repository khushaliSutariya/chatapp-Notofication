import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ColudNotificationScreens extends StatefulWidget {
  const ColudNotificationScreens({Key? key}) : super(key: key);

  @override
  State<ColudNotificationScreens> createState() => _ColudNotificationScreensState();
}

class _ColudNotificationScreensState extends State<ColudNotificationScreens> {


  var optoken="";

  mobiletoken() async
  {
    await FirebaseMessaging.instance.getToken().then((token) async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("token", token.toString());
      setState(() {
        optoken=token.toString();
      });
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mobiletoken();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text(optoken,style: TextStyle(fontSize: 30.0,
          color: Colors.red.shade400),)),
        ],
      ),
    );
  }
}
