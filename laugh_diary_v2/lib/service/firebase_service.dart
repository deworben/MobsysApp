import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../objects/audio_file.dart';

class FirebaseService {
  // TODO: make singleton at the start
  // Future<firebase_core.FirebaseApp> initialization = firebase_core.Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService() {}

  void uploadFile(AudioFile audioFile) async {
    print("hello mr console3");
    // var tempDir = await getTemporaryDirectory();
    // var targetFile = '${tempDir.path}/flutter_sound_example.pcm';
    var targetFile = audioFile.filePath;

    // var allFiles = Directory("${tempDir.path}")
    //     .listSync(); // list all files in temp dir
    File file = File(targetFile);

    await FirebaseAppCheck.instance
        .activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');

    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();

    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    try {
      final metadata = firebase_storage.SettableMetadata(
          contentType: 'audio/pcm',
          customMetadata: {'picked-file-path': file.path});

      // await firebase_storage.FirebaseStorage.instance
      //     .ref('randomFile.pcm')
      //     .putFile(file, metadata);
      //TODO: make the function store data correclty in the database
      await storage.ref(audioFile.name).putFile(file, metadata);
    } on firebase_core.FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print("Exception occurred when uploading! $e");
    }
    print(targetFile);
  }

  void downloadFile(String id) async {
    var tempDir = await getTemporaryDirectory();
    var targetFile = '${tempDir.path}/${id}';

    // var allFiles = Directory("${tempDir.path}")
    //     .listSync(); // list all files in temp dir
    File file = File(targetFile);

    await FirebaseAppCheck.instance
        .activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');

    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();

    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    // firebase_storage.Reference ref =
    // await firebase_storage.FirebaseStorage.instance.ref('/randomFile.pcm');
    // firebase_storage.StorageReference _ref = await storage.getReferenceFromUrl(
    //     "gs://laughdetectorbackend.appspot.com/randomFile.pcm");

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('/randomFile.pcm')
        .getDownloadURL();

    print("downloadURL: $downloadURL");

    // final http.Response downloadData = await http.get(url);
    await FlutterDownloader.initialize();
    final taskId = await FlutterDownloader.enqueue(
      url: 'your download link',
      savedDir: 'the path of directory where you want to save downloaded files',
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );

    print("download complete");

    // try {
    //   final metadata = firebase_storage.SettableMetadata(
    //       contentType: 'audio/pcm',
    //       customMetadata: {'picked-file-path': file.path});

    //   // await firebase_storage.FirebaseStorage.instance
    //   //     .ref('randomFile.pcm')
    //   //     .putFile(file, metadata);

    //   //gs://laughdetectorbackend.appspot.com/randomFile.pcm
    //   await storage.ref('randomFile.pcm').getData(file);
    // } on firebase_core.FirebaseException catch (e) {
    //   // e.g, e.code == 'canceled'
    //   print("Exception occurred when uploading! $e");
    // }
  }
}
