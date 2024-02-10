import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vr2dconverter/2d_converter.dart/cropper.dart';
import 'package:vr2dconverter/2d_converter.dart/ffmpeg_conversion.dart';
import 'package:vr2dconverter/360_player/video_player.dart';
import 'package:vr2dconverter/home_page.dart';
import 'package:vr2dconverter/routes/routes.dart';
import 'package:vr2dconverter/saved_files.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 167, 167)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Vr Converter'),
      routes: {
        savedFilesViewRoute: ((context) => const SavedFiles()),
        cropperViewRoute: ((context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return Cropper(videoFile: args['videoFile']);
        }),
        converterViewRoute: ((context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return Converter(
            videoPath: args['videoPath'],
            aspectRatio: args['aspectRatio'],
            height: args['height'],
            pitch: args['pitch'],
            width: args['width'],
            yaw: args['yaw'],
          );
        }),
        videoPlayerViewRoute: ((context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return VideoPlayerPage(videoFile: args['videoFile']);
        }),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  int selectedIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController(
      keepPage: true,
      initialPage: index,
    );

    getPermission();
    super.initState();
  }

  getPermission() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    await Permission.accessMediaLocation.request();
  }

  static const List<Widget> _widgetOptions = <Widget>[HomePage(), SavedFiles()];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedIconTheme:
            const IconThemeData(color: Color.fromARGB(255, 0, 167, 167)),
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        enableFeedback: false,
        showSelectedLabels: false,
        showUnselectedLabels: false,

        currentIndex: selectedIndex,

        //
        onTap: (index) {
          Future.delayed(const Duration(milliseconds: 200), () {
            onItemTapped(index);
          });
        },

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: "Saved Files",
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(selectedIndex),
      ),
    );
  }
}
