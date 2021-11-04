import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:laugh_diary_v2/objects/audio_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class FirebaseService {
  // TODO: make singleton at the start
  // Future<firebase_core.FirebaseApp> initialization = firebase_core.Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService() {}

  void uploadFile(AudioFile file) async {
    print("hello mr console3");
    var tempDir = await getTemporaryDirectory();
    var localFilepath = '${tempDir.path}/flutter_sound_example.pcm';

    // var allFiles = Directory("${tempDir.path}")
    //     .listSync(); // list all files in temp dir
    File file = File(localFilepath);

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
      await storage.ref('randomFile.pcm').putFile(file, metadata);
    } on firebase_core.FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print("Exception occurred when uploading! $e");
    }
    print(localFilepath);
  }

  Future<void> downloadFromURL(String downloadURL, String localFilepath) async {
    HttpClient httpClient = new HttpClient();
    String filePath = '';
    String myUrl = '';

    try {
      myUrl = downloadURL;
      // myUrl = url + '/' + fileName;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        File file = File(localFilepath);
        await file.writeAsBytes(bytes);
      } else {
        print('Error code: ' + response.statusCode.toString());
      }
    } catch (ex) {
      print('Can not fetch url');
    }
  }

  /// given a file id, downlaod the audio file and return an AudioFile object.
  Future<AudioFile> downloadFile(String id) async {
    await FirebaseAppCheck.instance
        .activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');

    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();

    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    var tempDir = await getTemporaryDirectory();
    var localFilepath = '${tempDir.path}/${id}.pcm';

    // var file = File(localFilepath).delete(); // Delete the file for debugging

    // Download document data from firebase
    // FirebaseFirestore.instance.collection('users').snapshots()
    FirebaseFirestore.instance
        .collection('users')
        .doc('tim')
        .collection('audio')
        .doc('randomFile')
        .get()
        .then((doc) {
      if (doc.exists) {
        print('Document data: ${doc.data}');
      } else {
        print('No such document! = ${id}');
      }
    });

    // First check if the file id exists locally and if it does, don't download it again
    if (await File(localFilepath).exists()) {
      print("File already exists locally");
      return AudioFile(id, localFilepath, DateTime(2021, 9, 7, 17, 5),
          Duration(seconds: 1000), "Content");
    }

    // If not, download it
    try {
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref('/${id}.pcm')
          .getDownloadURL();

      print("downloadURL: $downloadURL");

      await downloadFromURL(downloadURL, localFilepath);
    } catch (e) {
      print("Exception occurred when downloading! $e");
    }

    print("download complete");

    return AudioFile(id, localFilepath, DateTime(2021, 9, 7, 17, 5),
        Duration(seconds: 1000), "Content");
  }

  /// sortby is a string: "none", "date", "duration" ...
  /// filterby is a string: "none", "keyword", "favourite" ...
  /// keyowords is a string: a user provided keyword
  /// count is the number of results
  /// returns a list of ids.
  Future<List<String>> listFiles(
      String sortBy, String filterBy, String keywords, int count) async {
    return List.from(["path1", "path2"]);
  }
}
