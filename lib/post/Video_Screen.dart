import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final String videoUrl;

  const VideoScreen( {required this.videoUrl});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isOverlayVisible = false;
  bool hasVideoPlayed = false;

  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);

    _controller.addListener(() {
      if (_controller.value.isPlaying && !hasVideoPlayed) {
        setState(() {
          hasVideoPlayed = true;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleOverlayVisibility() {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
    });

    Timer(Duration(seconds: 1), () {
      setState(() {
        isOverlayVisible = !isOverlayVisible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _toggleOverlayVisibility();
                if (!hasVideoPlayed) {
                  hasVideoPlayed = true;
                  _controller.play();
                } else {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                }
              },
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            Visibility(
              visible: isOverlayVisible && hasVideoPlayed,
              child: FloatingActionButton(
                onPressed: () {
                  _toggleOverlayVisibility();
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
                child: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
