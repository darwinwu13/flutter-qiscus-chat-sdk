import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:developer' as dev;
import 'package:qiscus_sdk/qiscus_sdk.dart';

import 'locator.dart';

class ImagePreview extends StatefulWidget {
  final ImageProvider image;

  const ImagePreview({this.image});

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  String caption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
      ),
      backgroundColor: Colors.black,
      body: PhotoView(imageProvider: widget.image),
    );
  }
}
