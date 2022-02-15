// ignore_for_file: use_key_in_widget_constructors, avoid_print, must_be_immutable

import 'package:ava_bishoy/models/image_model%20.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class ZoomImage extends StatefulWidget {
  ImageModel model;
  ZoomImage(this.model);

  @override
  State<ZoomImage> createState() => _ZoomImageState();
}

class _ZoomImageState extends State<ZoomImage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SharedHelper.get(key: 'theme') == 'Light Theme'
          ? Colors.white
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.model.name),
      ),
      body: Center(
        child: PinchZoom(child: Image.network(widget.model.link),resetDuration: const Duration(milliseconds: 100),maxScale: 2.5,),
      ),
    );
  }
}
