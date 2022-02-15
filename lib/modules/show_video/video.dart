// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  VideoWidget(this.url);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController? videoPlayerController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture =
        videoPlayerController!.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Card(
            key: PageStorageKey(widget.url),
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chewie(
                key: PageStorageKey(widget.url),
                controller: ChewieController(
                  videoPlayerController: videoPlayerController!,
                  aspectRatio: 3 / 5.5,
                  autoInitialize: true,
                  looping: true,
                  autoPlay: true,
                  // Errors can occur for example when trying to play a video
                  // from a non-existent URL
                  errorBuilder: (context, errorMessage) {
                    return Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
