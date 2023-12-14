// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:vr_player/vr_player.dart';

// class Cropper extends StatefulWidget {
//   final String videoPath;
//   const Cropper({super.key, required this.videoPath});

//   @override
//   _CropperState createState() => _CropperState();
// }

// class _CropperState extends State<Cropper> with TickerProviderStateMixin {
//   late VrPlayerController _viewPlayerController;
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   bool _isShowingBar = false;
//   bool _isPlaying = false;
//   bool _isFullScreen = false;
//   bool _isVideoFinished = false;
//   bool _isLandscapeOrientation = false;
//   bool _isVolumeSliderShown = false;
//   bool _isVolumeEnabled = true;
//   late double _playerWidth;
//   late double _playerHeight;
//   String? _duration;
//   int? _intDuration;
//   bool isVideoLoading = false;
//   bool isVideoReady = false;
//   String? _currentPosition;
//   double _currentSliderValue = 0.1;
//   double _seekPosition = 0;

//   double _videoX = 0.0;
//   double _videoY = 0.0;
//   double _videoRotation = 0.0;
//   double _videoHeight = 0.0;
//   double _videoWidth = 0.0;

//   bool _isAspectRatio169 = true;

//   @override
//   void initState() {
//     _animationController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 1));
//     _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
//     _toggleShowingBar();
//     super.initState();
//   }

//   void _toggleShowingBar() {
//     switchVolumeSliderDisplay(show: false);

//     _isShowingBar = !_isShowingBar;
//     if (_isShowingBar) {
//       _animationController.forward();
//     } else {
//       _animationController.reverse();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     _playerWidth = MediaQuery.of(context).size.width;
//     _playerHeight =
//         _isFullScreen ? MediaQuery.of(context).size.height : _playerWidth / 2;
//     _isLandscapeOrientation =
//         MediaQuery.of(context).orientation == Orientation.landscape;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('VR Player'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             flex: 4,
//             child: GestureDetector(
//               onTap: _toggleShowingBar,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: <Widget>[
//                   VrPlayer(
//                     x: _videoX,
//                     y: _videoY,
//                     width: _videoWidth == 0 ? _playerWidth : _videoWidth,
//                     height: _videoHeight == 0 ? _playerHeight : _videoHeight,
//                     onCreated: onViewPlayerCreated,
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     child: FadeTransition(
//                       opacity: _animation,
//                       child: ColoredBox(
//                         color: Colors.black,
//                         child: Row(
//                           children: <Widget>[
//                             IconButton(
//                               icon: Icon(
//                                 _isVideoFinished
//                                     ? Icons.replay
//                                     : _isPlaying
//                                         ? Icons.pause
//                                         : Icons.play_arrow,
//                                 color: Colors.white,
//                               ),
//                               onPressed: playAndPause,
//                             ),
//                             Expanded(
//                               child: SliderTheme(
//                                 data: SliderTheme.of(context).copyWith(
//                                   activeTrackColor: Colors.amberAccent,
//                                   inactiveTrackColor: Colors.grey,
//                                   trackHeight: 5,
//                                   thumbColor: Colors.white,
//                                   thumbShape: const RoundSliderThumbShape(
//                                     enabledThumbRadius: 8,
//                                   ),
//                                   overlayColor: Colors.purple.withAlpha(32),
//                                   overlayShape: const RoundSliderOverlayShape(
//                                     overlayRadius: 14,
//                                   ),
//                                 ),
//                                 child: Slider(
//                                   value: _seekPosition,
//                                   max: _intDuration?.toDouble() ?? 0,
//                                   onChangeEnd: (value) {
//                                     _viewPlayerController.seekTo(value.toInt());
//                                   },
//                                   onChanged: (value) {
//                                     onChangePosition(value.toInt());
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Container(
//                     color: Colors.black,
//                     alignment: Alignment.center,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _isAspectRatio169 = !_isAspectRatio169;
//                           if (_isAspectRatio169) {
//                             _videoWidth = _playerWidth;
//                             _videoHeight = (_playerWidth / 16) * 9;
//                           } else {
//                             _videoWidth = (_playerWidth / 16) * 9;
//                             _videoHeight = _playerWidth;
//                           }
//                         });
//                       },
//                       child: Text(
//                         _isAspectRatio169
//                             ? 'Change ratio to 9:16'
//                             : 'Change ratio to 16:9',
//                         style: TextStyle(
//                             color: const Color.fromARGB(255, 194, 130, 130)),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           print("X: $_viewPlayerController.x");
//           print("Y: $_videoY");
//           print("Rotation: $_videoRotation");
//           print("Height: $_videoHeight");
//           print("Width: $_videoWidth");
//         },
//         child: Icon(Icons.check),
//       ),
//     );
//   }

//   void onViewPlayerCreated(
//     VrPlayerController controller,
//     VrPlayerObserver observer,
//   ) {
//     _viewPlayerController = controller;
//     observer
//       ..onStateChange = onReceiveState
//       ..onDurationChange = onReceiveDuration
//       ..onPositionChange = onChangePosition
//       ..onFinishedChange = onReceiveEnded;
//     _viewPlayerController.loadVideo(
//       videoUrl:
//           'https://cdn.bitmovin.com/content/assets/playhouse-vr/m3u8s/105560.m3u8',
//     );
//   }

//   void onReceiveState(VrState state) {
//     switch (state) {
//       case VrState.loading:
//         setState(() {
//           isVideoLoading = true;
//         });
//         break;
//       case VrState.ready:
//         setState(() {
//           isVideoLoading = false;
//           isVideoReady = true;
//         });
//         break;
//       case VrState.buffering:
//       case VrState.idle:
//         break;
//     }
//   }

//   void onReceiveDuration(int millis) {
//     setState(() {
//       _intDuration = millis;
//       _duration = millisecondsToDateTime(millis);
//     });
//   }

//   void onReceiveEnded(bool isFinished) {
//     setState(() {
//       _isVideoFinished = isFinished;
//     });
//   }

//   void onChangePosition(int millis) {
//     setState(() {
//       _currentPosition = millisecondsToDateTime(millis);
//       _seekPosition = millis.toDouble();
//     });
//   }

//   void onChangeVolumeSlider(double value) {
//     _viewPlayerController.setVolume(value);
//     setState(() {
//       _isVolumeEnabled = value != 0;
//       _currentSliderValue = value;
//     });
//   }

//   void switchVolumeSliderDisplay({required bool show}) {
//     setState(() {
//       _isVolumeSliderShown = show;
//     });
//   }

//   String millisecondsToDateTime(int milliseconds) =>
//       setDurationText(Duration(milliseconds: milliseconds));

//   String setDurationText(Duration duration) {
//     String twoDigits(int n) {
//       if (n >= 10) return '$n';
//       return '0$n';
//     }

//     final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
//   }

//   void playAndPause() async {
//     if (_isVideoFinished) {
//       await _viewPlayerController.seekTo(0);
//     }

//     if (_isPlaying) {
//       await _viewPlayerController.pause();
//     } else {
//       await _viewPlayerController.play();
//     }

//     setState(() {
//       _isPlaying = !_isPlaying;
//       _isVideoFinished = false;
//     });
//   }
// }
// Scaffold(
//       appBar: AppBar(
//         title: const Text("Converter"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const SizedBox(height: 8),
//             ValueListenableBuilder(
//               valueListenable: progress,
//               builder: (context, value, child) {
//                 return value == null
//                     ? const SizedBox.shrink()
//                     : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text('Converting ${(value * 100).ceil()}%'),
//                           const SizedBox(width: 6),
//                           const LinearProgressIndicator(),
//                         ],
//                       );
//               },
//             ),
//           ],
//         ),
//       ),
//     );