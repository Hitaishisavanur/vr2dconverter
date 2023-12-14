import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player_extra/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final videoFile;

  VideoPlayerPage({
    Key? key,
    required this.videoFile,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

double _cameraPitch = 0;
double _cameraYaw = 0;

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      widget.videoFile,
      //'https://videojs-vr.netlify.app/samples/eagle-360.mp4',
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        mediaFormat: MediaFormat.VR2D360,
      ),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Player"),
      ),
      body: SafeArea(
        child: Flexible(
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          VideoPlayer(_controller),
                          _ControlsOverlay(controller: _controller),
                          VideoProgressIndicator(_controller,
                              allowScrubbing: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  static const _mediaFormats = {
    MediaFormat.STANDARD: "Standard",
    MediaFormat.VR2D180: "Monoscopic 180",
    MediaFormat.VR2D360: "Monoscopic 360",
    MediaFormat.VR3D180_OU: "Stereoscopic 180 OverUnder",
    MediaFormat.VR3D180_SBS: "Stereoscopic 180 SideBySide",
    MediaFormat.VR3D360_OU: "Stereoscopic 360 OverUnder",
    MediaFormat.VR3D360_SBS: "Stereoscopic 360 SideBySide",
  };

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
          onPanUpdate: (details) {
            double touchX = details.delta.dx;
            double touchY = details.delta.dy;
            double r = 0;
            double cr = cos(r);
            double sr = sin(r);
            _cameraYaw += cr * touchX - sr * touchY;
            _cameraPitch -= sr * touchX + cr * touchY;

            controller.setCameraRotation(0.0, _cameraPitch, _cameraYaw);
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<int>(
            initialValue: controller.value.mediaFormat,
            tooltip: 'Switch between media format',
            onSelected: (format) {
              controller.setMediaFormat(format);
            },
            itemBuilder: (context) {
              return [
                for (var keyvalue in _mediaFormats.entries)
                  PopupMenuItem(
                    value: keyvalue.key,
                    child: Text(keyvalue.value),
                  ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text(_mediaFormats[controller.value.mediaFormat]!),
            ),
          ),
        ),
      ],
    );
  }
}
