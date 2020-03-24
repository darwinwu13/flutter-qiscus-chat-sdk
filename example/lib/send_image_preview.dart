import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:developer' as dev;
import 'package:qiscus_sdk/qiscus_sdk.dart';

import 'locator.dart';

class SendImagePreview extends StatefulWidget {
  final File imgFile;
  final int roomId;

  const SendImagePreview({this.imgFile, this.roomId});

  @override
  _SendImagePreviewState createState() => _SendImagePreviewState();
}

class _SendImagePreviewState extends State<SendImagePreview> {
  String caption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send image"),
      ),
      backgroundColor: Colors.black,
      body: PhotoView(imageProvider: FileImage(widget.imgFile)),
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add your caption here',
                ),
                onChanged: (value) {
                  caption = value;
                },
              ),
              flex: 1,
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () async {
                Navigator.pop(context, caption);
              },
            )
          ],
        ),
      ),
    );
  }
}
