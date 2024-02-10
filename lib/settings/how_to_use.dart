import 'package:flutter/material.dart';

class HowTo extends StatefulWidget {
  const HowTo({super.key});

  @override
  State<HowTo> createState() => _HowToState();
}

class _HowToState extends State<HowTo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("How to Use")),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 4.0, top: 5.0),
        child: const Text(
          "Step1:\n Select \"Vr to 2d\" option in home screen,\nThen you will be displayed a select media popup.\n\n\nStep2:\n Tap on \"Select 360/VR Video\" button,\nChoose the 360 or VR video using file selector. \n\n\nStep3:\n On successfull selection You will be redirected to \"Editor Screen\",\na]Move the video to set the Point of view(direction) you want crop out.\nb]You can also set aspect ratio of the output video by selecting \"Change aspect ratio\" option.\n\n\nStep4:\n Once you are okay with edits, click on \"convert\" button\nyou will get a popup saying \"converting video\".\n\n\nStep5:\n Once done converting, you will be redirected to \"Saved Files\" Screen, You will find the converted 2d video in the list.\n\n  ",
          textWidthBasis: TextWidthBasis.longestLine,
          textScaler: TextScaler.linear(1.75),
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: Colors.black87),
        ),
      ),
    );
  }
}
