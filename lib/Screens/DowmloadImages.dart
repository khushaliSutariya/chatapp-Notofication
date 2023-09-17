import 'dart:developer';

import 'package:awesome_toster/awesome_toster.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

class DowmloadImages extends StatefulWidget {
  var image = "";
  DowmloadImages({required this.image});

  @override
  State<DowmloadImages> createState() => _DowmloadImagesState();
}

class _DowmloadImagesState extends State<DowmloadImages> {

  var albumname = "Tack photo";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(width: 200.0, child: Image.network(widget.image)),
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  log('Image Url: ${widget.image}');
                  await GallerySaver.saveImage(widget.image,
                          albumName: 'Tack photo')
                      .then((success) {
                    Navigator.pop(context);
                    if (success != null && success) {
                      AwesomeToster().showOverlay(
                          context: context,
                          msg: "Image Successfully Saved",
                          tosterHeight: 50,
                          msgType: MsgType.SUCESS);
                    }
                  });
                } catch (e) {
                  log('ErrorWhileSavingImg: $e');
                  AwesomeToster().showOverlay(
                      context: context,
                      msg: "Image Not Saved",
                      tosterHeight: 50,
                      msgType: MsgType.ERROR);
                }
              },
              child: Text("Download")),
        ],
      ),
    );
  }
}
