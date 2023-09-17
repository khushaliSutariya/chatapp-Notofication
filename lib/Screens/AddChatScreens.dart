import 'dart:io';

import 'package:chatapp/Screens/Homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'DowmloadImages.dart';

class AddChatScreens extends StatefulWidget {
  var name = "";
  var email = "";
  var photo = "";
  var receiverid = "";
  AddChatScreens({
    required this.name,
    required this.email,
    required this.photo,
    required this.receiverid,
  });
  @override
  State<AddChatScreens> createState() => _AddChatScreensState();
}

class _AddChatScreensState extends State<AddChatScreens> {
  TextEditingController _msg = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  ImagePicker _picker = ImagePicker();


  File? selectedfile;
  var sid = "";

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sid = prefs.getString("senderid").toString();
    });
  }
  bool emojiShowing = false;
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
        backgroundColor: Colors.green,
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => Homepage(),
                  ));
                },
                icon: Icon(Icons.arrow_back_ios)),
            CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(
                widget.photo,
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Column(
              children: [
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 20.0),
                ),
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 10.0),
                ),
              ],
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: (sid != "")
                  ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("userdetail")
                          .doc(sid)
                          .collection("chats")
                          .doc(widget.receiverid.toString())
                          .collection("messages")
                          .orderBy("timestamp", descending: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.size <= 0) {
                            return Center(
                              child: Text("No messages"),
                            );
                          } else {
                            return ListView(
                              controller: _scrollController,
                              reverse: true,
                              children: snapshot.data!.docs.map((document) {
                                if (document["senderid"] == sid) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      margin: EdgeInsets.all(10.0),
                                      padding: EdgeInsets.all(10.0),
                                      color: Colors.red.shade500,
                                      child: (document["type"] == "text")
                                          ? Text(
                                              document["msg"].toString(),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                  builder: (context) =>
                                                      DowmloadImages(image: document["msg"].toString()),
                                                ));
                                              },
                                              child: Image.network(
                                                document["msg"].toString(),
                                                width: 100.0,
                                              )),
                                    ),
                                  );
                                } else {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: EdgeInsets.all(10.0),
                                      color: Colors.red.shade800,
                                      padding: EdgeInsets.all(10.0),
                                      child: (document["type"] == "text")
                                          ? Text(
                                              document["msg"].toString(),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          : Image.network(
                                              document["msg"].toString(),
                                              width: 100.0,
                                            ),
                                    ),
                                  );
                                }
                              }).toList(),
                            );
                          }
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      })
                  : Container(),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35.0),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 3),
                            blurRadius: 5,
                            color: Colors.grey)
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                            icon:  Icon(
                              Icons.face,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                emojiShowing = !emojiShowing;
                              });
                            }),
                        Expanded(
                          child: TextField(
                            controller: _msg,
                            onTap: ()
                            {
                              setState(() {
                                emojiShowing=false;
                              });
                            },
                            decoration: InputDecoration(
                                hintText: "Type Something...",
                                hintStyle:
                                    TextStyle(color: Colors.blueAccent),
                                border: InputBorder.none),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.photo_camera,
                              color: Colors.blueAccent),
                          onPressed: () async {
                            XFile? image = await _picker.pickImage(
                                source: ImageSource.camera);
                            selectedfile = File(image!.path);
                            var uuid = Uuid();
                            var filename = uuid.v1()+".jpg";

                            await FirebaseStorage.instance
                                .ref(filename)
                                .putFile(selectedfile!)
                                .whenComplete(() {})
                                .then((filedata) async {
                              await filedata.ref
                                  .getDownloadURL()
                                  .then((fileurl) async {
                                await FirebaseFirestore.instance
                                    .collection(("userdetail"))
                                    .doc(sid)
                                    .collection("chats")
                                    .doc(widget.receiverid.toString())
                                    .collection("messages")
                                    .add({
                                  "senderid": sid.toString(),
                                  "receiverid": widget.receiverid.toString(),
                                  "msg": fileurl,
                                  "type": "image",
                                  "timestamp":
                                      DateTime.now().millisecondsSinceEpoch
                                }).then((value) async {
                                  await FirebaseFirestore.instance
                                      .collection("userdetail")
                                      .doc(widget.receiverid.toString())
                                      .collection("chats")
                                      .doc(sid)
                                      .collection("messages")
                                      .add({
                                    "senderid": sid.toString(),
                                    "receiverid":
                                        widget.receiverid.toString(),
                                    "msg": fileurl,
                                    "type": "image",
                                    "timestamp":
                                        DateTime.now().millisecondsSinceEpoch
                                  }).then((value) {});
                                  // _msg.clear();
                                });
                              });
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.attach_file,
                              color: Colors.blueAccent),
                          onPressed: () async {
                            XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery);
                            selectedfile = File(image!.path);
                            var uuid = Uuid();
                            var filename = uuid.v1();

                            await FirebaseStorage.instance
                                .ref(filename)
                                .putFile(selectedfile!)
                                .whenComplete(() {})
                                .then((filedata) async {
                              await filedata.ref
                                  .getDownloadURL()
                                  .then((fileurl) async {
                                await FirebaseFirestore.instance
                                    .collection(("userdetail"))
                                    .doc(sid)
                                    .collection("chats")
                                    .doc(widget.receiverid.toString())
                                    .collection("messages")
                                    .add({
                                  "senderid": sid.toString(),
                                  "receiverid": widget.receiverid.toString(),
                                  "msg": fileurl,
                                  "type": "image",
                                  "timestamp":
                                      DateTime.now().millisecondsSinceEpoch
                                }).then((value) async {
                                  await FirebaseFirestore.instance
                                      .collection("userdetail")
                                      .doc(widget.receiverid.toString())
                                      .collection("chats")
                                      .doc(sid)
                                      .collection("messages")
                                      .add({
                                    "senderid": sid.toString(),
                                    "receiverid":
                                        widget.receiverid.toString(),
                                    "msg": fileurl,
                                    "type": "image",
                                    "timestamp":
                                        DateTime.now().millisecondsSinceEpoch
                                  }).then((value) {});
                                  // _msg.clear();
                                });
                              });
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent, shape: BoxShape.circle),
                  child: InkWell(
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      _scrollController.animateTo(
                          _scrollController.position.minScrollExtent,
                          duration: Duration(milliseconds: 2),
                          curve: Curves.easeOut);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      var senderid = prefs.getString("senderid");
                      var msg = _msg.text.toString();
                      _msg.text = "";
                      await FirebaseFirestore.instance
                          .collection(("userdetail"))
                          .doc(senderid)
                          .collection("chats")
                          .doc(widget.receiverid.toString())
                          .collection("messages")
                          .add({
                        "senderid": senderid.toString(),
                        "receiverid": widget.receiverid.toString(),
                        "msg": msg,
                        "type": "text",
                        "timestamp": DateTime.now().millisecondsSinceEpoch
                      }).then((value) async {
                        await FirebaseFirestore.instance
                            .collection("userdetail")
                            .doc(widget.receiverid.toString())
                            .collection("chats")
                            .doc(senderid)
                            .collection("messages")
                            .add({
                          "senderid": senderid.toString(),
                          "receiverid": widget.receiverid.toString(),
                          "msg": msg,
                          "type": "text",
                          "timestamp": DateTime.now().millisecondsSinceEpoch
                        }).then((value) {});
                        // _msg.clear();
                      });

                      // print("senderid:" + senderid.toString());
                      // print("receiverid:" + widget.receiverid.toString());
                    },
                  ),
                ),
              ],
            ),
            (emojiShowing)?SizedBox(
              height: 250,
              child: EmojiPicker(
                textEditingController: _msg,
                config: Config(
                    columns: 7,
                    emojiSizeMax: 32 *1.0),
              ),
            ):SizedBox()
          ],
        ),
      ),
    );
  }


}
