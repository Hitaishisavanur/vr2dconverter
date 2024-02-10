import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';

class SavedFiles extends StatefulWidget {
  const SavedFiles({super.key});

  @override
  State<SavedFiles> createState() => _SavedFilesState();
}

class _SavedFilesState extends State<SavedFiles> {
  String getDuration = '';
  List<FileSystemEntity> files = [];
  bool isSelectAll = false;
  Set<FileSystemEntity> selectedFiles = Set();

  @override
  void initState() {
    super.initState();

    loadFiles();
  }

  Future<List<FileSystemEntity>> listFilesInAppDirectory() async {
    // final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final appDirectory = Directory('/storage/emulated/0/360VideoConverter');
    if (await appDirectory.exists()) {
      final files = await appDirectory.list().toList();

      return files;
    } else {
      createFolder();
      return [];
    }
  }

  void loadFiles() async {
    final fileList = await listFilesInAppDirectory();

    setState(() {
      files = fileList;
    });
  }

  void createFolder() async {
    final appDirectory = Directory('/storage/emulated/0/360VideoConverter');
    if (await appDirectory.exists()) {
    } else {
      final Directory appDirectory =
          await Directory('/storage/emulated/0/360VideoConverter')
              .create(recursive: true);
    }
  }

  void shareSelectedFiles() {
    for (final file in selectedFiles) {
      Share.shareFiles([file.path]);
    }
  }

  void deleteSelectedFiles() {
    for (final file in selectedFiles) {
      file.deleteSync();
      // Remove the file from the list of files
      files.remove(file);
    }
    // Clear the selected files set
    selectedFiles.clear();
    loadFiles();
  }

  Future<MediaInformation?> getMediaInformation(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    return await session.getMediaInformation();
  }

  String formatDuration(double seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds ~/ 60) % 60;
    final int remainingSeconds = seconds.toInt() % 60;

    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  void openVideoPlayer(context, String filePath) async {
    await OpenFile.open(filePath, type: 'video/*');
    // final success = await OpenFile.open(filePath, type: 'video/*');

    // if (!success) {
    //   // Handle the case where no apps are available to open the file.
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text('Unable to open file'),
    //         content: Text('No apps available to open this file.'),
    //         actions: <Widget>[
    //           TextButton(
    //             child: Text('OK'),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Saved Files',
              style: TextStyle(color: Color.fromARGB(255, 0, 71, 71))),
          actions: [
            selectedFiles.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.select_all),
                    onPressed: () {
                      setState(() {
                        if (!isSelectAll) {
                          // Select all files
                          selectedFiles.addAll(files);
                        } else {
                          // Deselect all files
                          selectedFiles.clear();
                        }
                        isSelectAll = !isSelectAll;
                      });
                    },
                  )
                : SizedBox.shrink(),
            selectedFiles.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: (() {
                      deleteSelectedFiles();
                    }))
                : SizedBox.shrink(),
          ],
          // [
          //   selectedFiles.isNotEmpty
          //       ? PopupMenuButton<String>(
          //           onSelected: (value) {
          //             if (value == 'share') {
          //               shareSelectedFiles();
          //             } else if (value == 'delete') {
          //               deleteSelectedFiles();
          //             }
          //           },
          //           itemBuilder: (context) => <PopupMenuEntry<String>>[
          //             PopupMenuItem<String>(
          //               value: 'share',
          //               child: Text('Share'),
          //             ),
          //             PopupMenuItem<String>(
          //               value: 'delete',
          //               child: Text('Delete'),
          //             ),
          //           ],
          //         )
          //       : SizedBox.shrink(),
          // ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final isSelected = selectedFiles.contains(file);

                    return FutureBuilder<MediaInformation?>(
                      future: getMediaInformation(file.path),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: ListTile(
                                isThreeLine: true,
                                shape: Border(bottom: BorderSide()),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      basename(file.path),
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                    ),
                                    SizedBox(height: 8.0),
                                  ],
                                ),
                                contentPadding: EdgeInsets.only(bottom: 8.0),
                                subtitle: Text(getDuration),
                                tileColor: isSelected
                                    ? Color.fromARGB(255, 196, 196,
                                        196) // Add a background color for selected files
                                    : null,
                                onTap: () {
                                  if (selectedFiles.isNotEmpty) {
                                    setState(() {
                                      if (isSelected) {
                                        selectedFiles.remove(file);
                                      } else {
                                        selectedFiles.add(file);
                                      }
                                    });
                                  } else {
                                    openVideoPlayer(context, file.path);
                                  }
                                },
                                leading: Icon(Icons.play_arrow_rounded,
                                    size: 65,
                                    color:
                                        const Color.fromARGB(255, 0, 167, 167)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.share),
                                      onPressed: () {
                                        Share.shareFiles([file.path]);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        file.deleteSync();
                                        files.remove(file);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              )); // Display a loading indicator while fetching information.
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          // Handle the case where no information is available.
                          //         return ListTile(ListView.builder(
                          // itemCount: files.length,
                          // itemBuilder: (context, index) {
                          //   final file = files[index];
                          //   final isSelected = selectedFiles.contains(file);

                          return ListTile(
                            shape: Border(bottom: BorderSide()),

                            title: Text(
                              basename(file.path),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                            ),

                            tileColor: isSelected
                                ? Color.fromARGB(255, 196, 196,
                                    196) // Add a background color for selected files
                                : null,
                            //subtitle: Text(getDuration),
                            onTap: () {
                              if (selectedFiles.isNotEmpty) {
                                setState(() {
                                  if (isSelected) {
                                    selectedFiles.remove(file);
                                  } else {
                                    selectedFiles.add(file);
                                  }
                                });
                              } else {
                                openVideoPlayer(context, file.path);
                              }
                            },
                            leading: Icon(Icons.play_arrow_rounded,
                                size: 65,
                                color: const Color.fromARGB(255, 0, 167, 167)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () {
                                    Share.shareFiles([file.path]);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    file.deleteSync();
                                    files.remove(file);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                        final mediaInfo = snapshot.data!;
                        final seconds = mediaInfo.getDuration();
                        getDuration = formatDuration(double.parse(seconds!));

                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              if (isSelected) {
                                selectedFiles.remove(file);
                              } else {
                                selectedFiles.add(file);
                              }
                            });
                          },
                          onTap: () {},
                          child: ListTile(
                            isThreeLine: true,
                            shape: Border(bottom: BorderSide()),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  basename(file.path),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 8.0),
                              ],
                            ),
                            contentPadding: EdgeInsets.only(bottom: 8.0),
                            subtitle: Text(getDuration),
                            tileColor: isSelected
                                ? Color.fromARGB(255, 196, 196,
                                    196) // Add a background color for selected files
                                : null,
                            onTap: () {
                              if (selectedFiles.isNotEmpty) {
                                setState(() {
                                  if (isSelected) {
                                    selectedFiles.remove(file);
                                  } else {
                                    selectedFiles.add(file);
                                  }
                                });
                              } else {
                                openVideoPlayer(context, file.path);
                              }
                            },
                            leading: Icon(Icons.play_arrow_rounded,
                                size: 65,
                                color: const Color.fromARGB(255, 0, 167, 167)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () {
                                    Share.shareFiles([file.path]);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    file.deleteSync();
                                    files.remove(file);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ));
  }
}
