import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'Homepage.dart';
import 'LoginScreens.dart';


class NotificationScreens extends StatefulWidget {
  const NotificationScreens({Key? key}) : super(key: key);

  @override
  State<NotificationScreens> createState() => _NotificationScreensState();
}

class _NotificationScreensState extends State<NotificationScreens> {
  Future<void> customaction(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == "yes") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } else if (receivedAction.buttonKeyPressed == "no") {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginScreens(),
      ));
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     }
  @override
  Widget build(BuildContext context) {
    AwesomeNotifications().setListeners(onActionReceivedMethod: customaction);

    return Scaffold(
      appBar: AppBar(
        title: Text("Notification"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
                onPressed: () async {
                    await AwesomeNotifications().isNotificationAllowed().then((status) async{
                      if(status)
                        {
                          await AwesomeNotifications().createNotification(
                              content: NotificationContent(
                                  id: 150,
                                  channelKey: 'normal',
                                  title: "Hello!!!",
                                  body: "Good morning"));
                        }
                      else
                        {
                          print("Notification is not allowed");
                          await AwesomeNotifications().requestPermissionToSendNotifications();
                        }
                    });
                },
                child: Text("Local Notification")),
          ),
          ElevatedButton(
              onPressed: () async {
                await AwesomeNotifications().createNotification(
                    content: NotificationContent(
                  id: 152,
                  channelKey: 'normal',
                  title: "Hello!!!",
                  body: "Have a nice day",
                  bigPicture: "asset://assets/images/beautyofnature.jpg",
                  notificationLayout: NotificationLayout.BigPicture,
                ));
              },
              child: Text("Local Notification image")),
          ElevatedButton(
              onPressed: () async {
                await AwesomeNotifications().createNotification(
                    content: NotificationContent(
                  id: 151,
                  channelKey: 'normal',
                  title: "Hello!!!",
                  body: "lookat hear",
                  bigPicture:
                      "https://www.fluttercampus.com/img/logo_small.webp",
                  notificationLayout: NotificationLayout.BigPicture,
                ));
              },
              child: Text("Local Notification networkimage")),
          ElevatedButton(
              onPressed: () async {

                AwesomeNotifications().isNotificationAllowed().then(
                  (isAllowed) {
                    if (!isAllowed) {

                    }
                    else
                      {
                         AwesomeNotifications().createNotification(
                            content: NotificationContent(
                              id: 153,
                              channelKey: 'normal',
                              title: "Hello!!!",
                              body: "lookat hear",),
                              actionButtons: <NotificationActionButton>[
                                NotificationActionButton(key: 'yes', label: 'Yes'),
                                NotificationActionButton(key: 'no', label: 'No'),
                              ],
                            );
                      }
                  },
                );
              },
              child: Text("Local Notification Text Button")),
        ],
      ),
    );
  }
}
