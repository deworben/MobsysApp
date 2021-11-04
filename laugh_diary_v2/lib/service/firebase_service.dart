import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:laugh_diary_v2/objects/audio_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // TODO: make singleton at the start
  // Future<firebase_core.FirebaseApp> initialization = firebase_core.Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService() {}

  void uploadFile(AudioFile file) async {
    print("hello mr console3");
    var tempDir = await getTemporaryDirectory();
    var targetFile = '${tempDir.path}/flutter_sound_example.pcm';

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
      await storage.ref('randomFile.pcm').putFile(file, metadata);
    } on firebase_core.FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print("Exception occurred when uploading! $e");
    }
    print(targetFile);
  }

  /// given a file id, downlaod the audio file and return an AudioFile object.
  /// guarantee the path property is set.
  Future<AudioFile> downloadFile(String id) async {
    return AudioFile("id", DateTime(2021, 9, 7, 17, 5), Duration(seconds: 1000), "Yo", "PATH");
  }


  /// returns a list of audio files with file path value as null.
  Future<List<AudioFile>> listFiles(int count) async {
    return List.from([]);
  }
}
