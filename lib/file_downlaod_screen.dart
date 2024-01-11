import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloadScreen extends StatefulWidget {
  const FileDownloadScreen({super.key});

  @override
  State<FileDownloadScreen> createState() => _FileDownloadScreenState();
}

class _FileDownloadScreenState extends State<FileDownloadScreen> {
  ReceivePort receivePort = ReceivePort();
  int progress = 0;
  final file = 'https://www.clickdimensions.com/links/TestPDFfile.pdf';

  Future<void> _downloadFile() async {
    final status = await Permission.storage.request();

    if(status.isGranted) {
      var baseStorage;
      if(Platform.isAndroid) {
        baseStorage = (await getExternalStorageDirectory())!;
      } else if(Platform.isIOS) {
        baseStorage = await getApplicationDocumentsDirectory();
      }
      try {
        await FlutterDownloader.enqueue(
            url: file,
            savedDir: baseStorage.path ?? "",
            fileName: "Video.mp4"
        );
      } catch (e) {
        debugPrint("\n{e.toString()}\n\n");
      }
    } else {
      await openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, "downloadingVideo");

    receivePort.listen((message) {
      progress = message;
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadFileCallback);
  }

  static downloadFileCallback(id, status, progress) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName('downloadingVideo');
    sendPort?.send(progress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File download screen"),
      ),
      body: Center(
        child: RichText(
          text: TextSpan(
            text: "Download file progress: ",
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 20),
            children: [
              TextSpan(
                text: "$progress",
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 20),
              )
            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadFile,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.download, color: Colors.white,),
      ),
    );
  }
}
