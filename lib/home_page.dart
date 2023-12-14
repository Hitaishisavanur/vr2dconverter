import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:vr2dconverter/routes/routes.dart';
import 'package:vr2dconverter/settings/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vr2dConverter",
          style: TextStyle(color: Color.fromARGB(255, 0, 71, 71)),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ButtonGrid(),
    );
  }
}

class ButtonGrid extends StatelessWidget {
  int buttonValue = 0;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns in the grid
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        // Create a button for each grid cell
        return GestureDetector(
          onTap: () {
            print(index);
            handleButtonPress(context, index);
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          getIconForIndex(index),
                          size: 50,
                          color: Color.fromARGB(255, 0, 167, 167),
                          shadows: <Shadow>[
                            Shadow(
                                color: Color.fromARGB(50, 0, 167, 167),
                                blurRadius: 2.0)
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTextForIndex(index),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Color.fromARGB(255, 0, 167, 167)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      //Container(
      //     margin: EdgeInsets.all(8.0),
      //     color: Colors.amber,
      //     child: Column(
      //       children: [
      //         IconButton(
      //           icon: Icon(getIconForIndex(index)),
      //           onPressed: () {
      //             // Button click action
      //             handleButtonPress(context, index);
      //             print('Button $index clicked');
      //           },
      //         ),
      //         Text(getTextForIndex(index)),
      //       ],
      //     ),
      //   );
      // },
      // Set the total number of buttons
    );
  }

  IconData getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.play_circle; // Privacy Policy icon
      case 1:
        return Icons.video_library; // Contact Us icon
      case 2:
        return Icons.settings; // Share icon

      default:
        return Icons.error; // Default icon if index is out of bounds
    }
  }

  // Function to get the text based on the index
  String getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Play Vr360 video';
      case 1:
        return 'Vr360 to 2d';
      case 2:
        return 'Settings';

      default:
        return 'Unknown';
    }
  }

  void handleButtonPress(BuildContext context, int index) {
    switch (index) {
      case 0:
        buttonValue = 1;
        onTapVideoPlayerFunction(context);
        break;
      case 1:
        buttonValue = 2;
        ////////////////////////////////////////////////////////////////////////////////////
        onTapCropperFunction(context);
        break;
      case 2:
        buttonValue = 3;
        onTapSettingsFunction(context);
        break;

      default:
        // Handle unknown button press
        break;
    }
  }

  void onTapSettingsFunction(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Settings()));

    //Navigator.of(context).pushNamed(cropperViewRoute,
    // arguments: {'videoPath': "assets/video.mp4"});
  }

  void onTapCropperFunction(BuildContext context) {
    chooseOne(context);

    //Navigator.of(context).pushNamed(cropperViewRoute,
    // arguments: {'videoPath': "assets/video.mp4"});
  }

  void onTapVideoPlayerFunction(BuildContext context) {
    chooseOne(context);
    // Navigator.of(context).pushNamed(videoPlayerViewRoute,
    //     arguments: {'videoPath': "assets/video.mp4"});
  }

  selectVideoFromGallery() async {
    XFile? file = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }

  chooseOne(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: SizedBox(
              height: 165,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      'Select Media',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              var selectedVideoPath =
                                  await selectVideoFromGallery();

                              Navigator.pop(context);

                              if (selectedVideoPath != '') {
                                // It's a 360-degree video, you can proceed with your logic
                                File selectedVideo = File(selectedVideoPath);
                                print(selectedVideo.path);

                                if (buttonValue == 1) {
                                  Navigator.of(context).pushNamed(
                                    videoPlayerViewRoute,
                                    arguments: {'videoFile': selectedVideo},
                                  );
                                } else if (buttonValue == 2) {
                                  Navigator.of(context).pushNamed(
                                    cropperViewRoute,
                                    arguments: {'videoFile': selectedVideo},
                                  );
                                } else if (buttonValue == 3) {
                                  Navigator.of(context).pushNamed(
                                    cropperViewRoute,
                                    arguments: {'videoFile': selectedVideo},
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Selection failed !"),
                                ));
                              }
                            },
                            child: const Card(
                                elevation: 5,
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      // Image.asset(
                                      //   'assets/images/camera.png',
                                      Icon(
                                        Icons.video_call,
                                        size: 50,
                                        color: Colors.blueAccent,
                                      ),
                                      Text('Select 360/VR Video'),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
