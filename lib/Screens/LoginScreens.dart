import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Homepage.dart';

class LoginScreens extends StatefulWidget {
  const LoginScreens({Key? key}) : super(key: key);

  @override
  State<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: InkWell(
                  onTap: () async {
                    final GoogleSignIn googleSignIn = GoogleSignIn();
                    final GoogleSignInAccount? googleSignInAccount =
                        await googleSignIn.signIn();
                    if (googleSignInAccount != null) {
                      final GoogleSignInAuthentication
                          googleSignInAuthentication =
                          await googleSignInAccount.authentication;
                      final AuthCredential authCredential =
                          GoogleAuthProvider.credential(
                              idToken: googleSignInAuthentication.idToken,
                              accessToken:
                                  googleSignInAuthentication.accessToken);

                      // Getting users credential
                      UserCredential result =
                          await auth.signInWithCredential(authCredential);
                      User? user = result.user;
                      var name = user!.displayName.toString();
                      var email = user.email.toString();
                      var photo = user.photoURL.toString();
                      var googleid = user.uid.toString();
                      print(name);
                      print(email);
                      print(photo);
                      print(googleid);

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("name", name);
                      prefs.setString("email", email);
                      prefs.setString("photo", photo);
                      prefs.setString("googleid", googleid);

                      await FirebaseFirestore.instance
                          .collection("userdetail")
                          .where("useremail", isEqualTo: email)
                          .get()
                          .then((document) async {
                        if (document.size <= 0) {
                          await FirebaseFirestore.instance
                              .collection("userdetail")
                              .add({
                            "username": name,
                            "useremail": email,
                            "userphoto": photo,
                            "usergoogleid": googleid,
                            //"token":prefs.getString("token")
                          }).then((document) async {
                            prefs.setString("senderid", document.id.toString());
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Homepage()));
                          });
                        }
                        else{
                          prefs.setString("senderid", document.docs.first.id.toString());


                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Homepage()));
                        }
                      });


                    }
                  },
                  child: Text("Login with google"))),
        ],
      ),
    );
  }
}
