import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class GalleryPage extends StatefulWidget {

  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();

}

class _GalleryPageState extends State<GalleryPage> {

  List<Widget> files = [];

  Future<String> get _localPath async {
    return "";
  }

  Future<List<FileSystemEntity>> getFiles() async {
    String appDir = await _localPath;
    Directory dir = new Directory(appDir);
    Stream<FileSystemEntity> stream = dir.list();
    return stream.toList();
  }

  addSavedFile(FileSystemEntity record, context) {
    String filePath = record.path;
    String fileName = basename(filePath);
    File rawFile = File(filePath);
    DateTime fileDateTime = rawFile.lastModifiedSync();
    String rawFileDateTime = DateFormat('y/MM/dd HH:mm').format(fileDateTime);
    int fileSize = 0;
    bool isDir = new Directory(filePath).existsSync();
    bool isNotDir = !isDir;
    String rawFileSize = '0';
    if (isNotDir) {
      fileSize = rawFile.lengthSync();
      rawFileSize = '${fileSize.toStringAsFixed(2)} B';
      final kb = fileSize / 1024;
      bool isKbMeasure = kb > 0;
      if (isKbMeasure) {
        rawFileSize = '${kb.toStringAsFixed(2)} KB';
      }
      final mb = kb / 1024;
      bool isMbMeasure = mb > 0;
      if (isMbMeasure) {
        rawFileSize = '${mb.toStringAsFixed(2)} MB';
      }
    }
    GestureDetector file = GestureDetector(
      child: Container(
        height: 350,
        width: 175,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              rawFile,
              width: 170,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$rawFileDateTime'
                ),
                Text(
                  '$rawFileSize'
                )
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: Icon(
                    Icons.delete
                  ),
                  onTap: () {

                  }
                ),
                GestureDetector(
                  child: Icon(
                    Icons.more_vert
                  ),
                  onTap: () {

                  }
                )
              ]
            )
          ]
        )
      ),
      onTap: () {

      }
    );
    files.add(file);
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Галерея'
        )
      ),
      body: FutureBuilder(
        future: getFiles(),
        builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
          int snapshotsCount = 0;
          if (snapshot.data != null) {
            snapshotsCount = snapshot.data!.length;
            files = [];
            for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
              addSavedFile(snapshot.data!.elementAt(snapshotIndex), context);
            }
          }
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    25
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: Column(
                        children: [
                          Wrap(
                            children: files
                          )
                        ]
                      )
                    )
                  )
                )
              ]
            );
          } else {
            return Column(

            );
          }
          return Column(

          );
        }
      )
    );
  }

}