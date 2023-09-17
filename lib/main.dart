import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chatapp/Screens/DowmloadImages.dart';
import 'package:chatapp/Screens/Homepage.dart';
import 'package:chatapp/Screens/LoginScreens.dart';
import 'package:chatapp/Screens/SplashScreens.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/ColudNotificationScreens.dart';
import 'Screens/NotificationScreens.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AwesomeNotifications().initialize(
      null, //'resource://drawable/res_app_icon',//
      [
        NotificationChannel(
            channelKey: 'normal',
            channelName: 'Normal',
            channelDescription: 'Notification tests as alerts',
            playSound: true,
            onlyAlertOnce: true,
            groupAlertBehavior: GroupAlertBehavior.Children,
            importance: NotificationImportance.High,
            defaultPrivacy: NotificationPrivacy.Private,
            defaultColor: Colors.deepPurple,
            ledColor: Colors.deepPurple)
      ],
      debug: true);

  FirebaseMessaging.onMessage.listen(showFlutterNotification);

  runApp( MyApp());
}
void showFlutterNotification(RemoteMessage message)  async{
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null ) {
    var title = notification.title.toString();
    var body = notification.body.toString();

    // alert dialog

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 150,
            channelKey: 'normal',
            title:title,
            body: body
        ));
  }
}
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: ColudNotificationScreens(),
    );
  }
}
