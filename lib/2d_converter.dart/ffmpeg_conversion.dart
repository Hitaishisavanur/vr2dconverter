import 'dart:math';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';

import 'package:ffmpeg_kit_flutter/return_code.dart';

import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vr2dconverter/routes/routes.dart';

class Converter extends StatefulWidget {
  final String videoPath;
  final double yaw;
  final double pitch;
  final double width;
  final double height;
  final double aspectRatio;
  const Converter(
      {super.key,
      required this.videoPath,
      required this.yaw,
      required this.pitch,
      required this.width,
      required this.height,
      required this.aspectRatio});

  @override
  State<Converter> createState() => _ConverterState();
}

class _ConverterState extends State<Converter> {
  double _progress = 0.0;
  bool _isConverting = false;

  get session => null;

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  getPermission() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    await Permission.accessMediaLocation.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Conversion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isConverting
                ? CircularProgressIndicator(
                    value: _progress,
                    semanticsLabel: 'Conversion Progress',
                  )
                : SizedBox.shrink(),
            SizedBox(height: 16),
            _isConverting
                ? Text('Converting: ${(_progress * 100).toStringAsFixed(1)}%')
                : SizedBox.shrink(),
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    _startVideoConversion(
                        context); // Call _startVideoConversion from here
                  },
                  child: Text('Start Video Conversion'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // void savedFilesPage(BuildContext context) {
  //   Navigator.of(context)
  //       .pushNamedAndRemoveUntil(savedFilesViewRoute, (route) => false);
  // }

  void _startVideoConversion(BuildContext context) async {
    // Generate a unique file name for the output video
    final input = File(widget.videoPath).path;
    final inputFileName = basenameWithoutExtension(input).toString();

    // final Directory appDocumentsDirectory =
    //     await getApplicationDocumentsDirectory();

    final Directory appDirectory =
        await Directory('/storage/emulated/0/360VideoConverter')
            .create(recursive: true);

    final String uniqueFileName = inputFileName +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".mp4";

    // Create a File instance for the output video in the app directory

    final outputFileName =
        File('/storage/emulated/0/360VideoConverter/$uniqueFileName').path;
    final yaw = widget.yaw;
    final pitch = widget.pitch;
    final w = widget.width;
    final h = widget.height;
    final ratio = widget.aspectRatio;

    print("$input,$outputFileName,$yaw,$pitch,$w,$h");

    final command =
        '-i "$input" -vf "scale=$w:-1, v360=equirect:flat:yaw=$yaw:pitch=$pitch" $outputFileName';
    //     'ffmpeg -i $input -vf "v360=equirect:flat:yaw=$yaw:pitch=$pitch, scale=$w:$h "  $outputFileName';https://ffmpeg.org/ffmpeg-filters.html#toc-crop
//
    await FFmpegKit.executeAsync(command).then((session) async {
      FFmpegKitConfig.enableFFmpegSessionCompleteCallback((session) async {
        final sessionId = session.getSessionId();
        print(sessionId);

        final detail = await session.getAllStatistics(1000);
        final output = await session.getOutput();
        final returnCode = await session.getReturnCode();
        // The stack trace if FFmpegKit fails to run a command
        final failStackTrace = await session.getFailStackTrace();

        // The list of logs generated for this execution
        final logs = await session.getLogs();

        // The list of statistics generated for this execution (only available on FFmpegSession)
        final statistics = await session.getStatistics();
        if (ReturnCode.isSuccess(returnCode)) {
          print("success: $returnCode");
          Navigator.of(context).pop(converterViewRoute);
          Navigator.of(context).pop(cropperViewRoute);

          Navigator.of(context).pushNamed(savedFilesViewRoute);

          // SUCCESS
        } else if (ReturnCode.isCancel(returnCode)) {
          print("cancelled: $returnCode");
        } else {
          print("failed: $returnCode");
        }
      });
    });
  }

  Future<String> saveOutputVideo(File outputVideo) async {
    try {
      final Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();

      // Create a directory for your app if it doesn't exist
      final Directory appDirectory =
          await Directory('${appDocumentsDirectory.path}/MyApp')
              .create(recursive: true);

      // Generate a unique file name for the output video
      final String uniqueFileName =
          DateTime.now().millisecondsSinceEpoch.toString() + ".mp4";

      // Create a File instance for the output video in the app directory
      final File outputFile = File('${appDirectory.path}/$uniqueFileName');

      // Copy the output video to the app directory
      await outputVideo.copy(outputFile.path);

      return outputFile.path;
    } catch (e) {
      print("Error saving output video: $e");
      return e.toString();
    }
  }
}
