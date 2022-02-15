// ignore_for_file: must_be_immutable, use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:ava_bishoy/models/file_model.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class LectureViewer extends StatelessWidget {
  FileModel model;

  LectureViewer(this.model);
  PdfViewerController? controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SharedHelper.get(key: "theme") == 'Light Theme'
          ? Colors.white
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Lecture Content',
        ),
      ),
      body: SfPdfViewer.network(
        model.link,
        controller: controller,
      ),
    );
  }
}
