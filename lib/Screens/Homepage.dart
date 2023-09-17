import 'package:chatapp/Screens/LoginScreens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddChatScreens.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var name = "", email = "", photo = "", googleid = "";

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name").toString();
      email = prefs.getString("email").toString();
      photo = prefs.getString("photo").toString();
      googleid = prefs.getString("googleid").toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home page"),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(name),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(photo),
                ),
              ),
              Text(googleid),
              SizedBox(
                height: 10.0,
              ),
              TextButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.clear();
                    GoogleSignIn googlesignin = GoogleSignIn();
                    googlesignin.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => LoginScreens(),
                    ));
                  },
                  child: Text("Logout"))
            ],
          ),
        ),
        body:
        (email == "")
            ? Center(
                child: CircularProgressIndicator(),
              )
            :
        StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("userdetail")
                    .where("useremail", isNotEqualTo: email)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.size <= 0) {
                      return Center(
                        child: Text("No Data"),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: snapshot.data!.docs.map((document) {
                            return InkWell(
                              onTap: () {

                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => AddChatScreens(
                                    name: document["username"].toString(),
                                    email: document["useremail"].toString(),
                                    photo: document["userphoto"].toString(),
                                    receiverid:  document.id.toString(),
                                  ),
                                ));
                              },
                              child: Card(
                                elevation: 10.0,
                                child: Container(
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ListTile(
                                    title:
                                        Text(document["username"].toString()),
                                    subtitle:
                                        Text(document["useremail"].toString()),
                                    leading: CircleAvatar(
                                      radius: 25.0,
                                      backgroundImage: NetworkImage(
                                          document["userphoto"].toString()),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }));
  }
}
