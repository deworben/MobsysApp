import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laugh_diary_v2/objects/audio_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService() {}

  void uploadFile(AudioFile audioFile) async {
    print("uploadFile start");

    var tempDir = await getTemporaryDirectory();
    var localFilepath = '${tempDir.path}/${audioFile.id}';

    // Upload firebase metadata to firebase
    var ref = await FirebaseFirestore.instance
        .collection('users')
        .doc('tim')
        .collection('audio');
    ref.doc(audioFile.id).set({
      'id': audioFile.id,
      // 'duration': audioFile.duration.toString(),
      'content': audioFile.content,
      'datetime': Timestamp.fromDate(DateTime.now()),
    });

    // Upload the file to firebase
    // var allFiles = Directory("${tempDir.path}")
    //     .listSync(); // list all files in temp dir
    // File file = File(localFilepath);
    File file = File(audioFile.filePath!);

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
      await storage.ref(audioFile.id).putFile(file, metadata);
    } on firebase_core.FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print("FirebaseException occurred when uploading! $e");
    } catch (e) {
      print("Exception occurred when uploading! $e");
    }
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
  /// guarantee the path property is set.
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
    var _localDatetime = DateTime(2021, 9, 7, 17, 5);
    var _localId = '12345';
    var _localDuration = Duration(seconds: 1000);
    var _localContent = 'None str';

    // FirebaseFirestore.instance.collection('users').snapshots()
    FirebaseFirestore.instance
        .collection('users')
        .doc('tim')
        .collection('audio')
        .doc(id)
        .get()
        .then((doc) {
      if (doc.exists) {
        print('Document data: ${doc.data}');
        //TODO: Check the document data is valid
        if (doc.data() != null) {
          var _localId = doc.data()!['id'];
          var _localDatetime =
              DateTime.parse(doc.data()!['datetime'].toDate().toString());
          var _localDuration = doc.data()!['duration'];
          var _localContent = doc.data()!['content'];
          var _localFilepath = '${tempDir.path}/${id}.pcm';
        }
      } else {
        print('No such document! = ${id}');
      }
    });

    // First check if the file id exists locally and if it does, don't download it again
    if (await File(localFilepath).exists()) {
      print("File already exists locally"); //do nothing
    } else {
      // If not, download it
      try {
        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref('/${id}')
            .getDownloadURL();

        print("downloadURL: $downloadURL");

        await downloadFromURL(downloadURL, localFilepath);
      } catch (e) {
        print("Exception occurred when downloading! $e");
      }

      print("download complete");
    }
    return AudioFile(
        _localId, _localDatetime, _localDuration, _localContent, localFilepath);
  }

  Future<List<AudioFile>> listFiles() async {
    List audioFileList = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc('tim')
        .collection('audio')
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        print('snapshot.docs.isNotEmpty');
        snapshot.docs.forEach((doc) {
          print('doc.data: ${doc.data()}');
          audioFileList.add(AudioFile(
              doc.data()['id'],
              DateTime.parse(doc.data()['datetime'].toDate().toString()),
              doc.data()['duration'],
              doc.data()['content'],
              doc.data().containsKey('filePath')
                  ? doc.data()['filePath']
                  : null));
        });
      } else {
        print('snapshot.docs.isEmpty');
      }
    });

    print("Final output = ${List.from(audioFileList)}");
    return List.from(audioFileList);
  }

  List<double> getNumLaughsPerHourOverLastDay() {
    List<double> numLaughsPerHourOverLastDay = [];
    FirebaseFirestore.instance
        .collection('users')
        .doc('tim')
        .collection('audio')
        .get()
        .then((snapshot) {
      //Get current time
      var now = DateTime.now();

      // Get datetime 24 hours ago
      var yesterday = now.subtract(Duration(days: 1));

      // For every hour fromTime, starting 24 hours before,
      //  Get all the documents that are between fromTime and fromTime+1hr.
      //  Count this and put it in the list.
      int counter = 0;
      for (DateTime fromTime = yesterday;
          fromTime.isBefore(now);
          fromTime = fromTime.add(Duration(hours: 1))) {
        // iterate through all hours
        counter = counter + 1;
        int numLaughs = 0;

        // iterate through all documents and find the ones that are within the hour
        snapshot.docs.forEach((doc) {
          var docDatetime =
              DateTime.parse(doc.data()['datetime'].toDate().toString());
          if (docDatetime.isAfter(fromTime) &&
              docDatetime.isBefore(fromTime.add(Duration(hours: 1)))) {
            numLaughs += 1;
          }
        });

        // Add numLaughs to the list
        numLaughsPerHourOverLastDay.add(numLaughs.toDouble());
      }

      // print("numLaughsPerHourOverLastDay = ${numLaughsPerHourOverLastDay}");
      // print("$counter");
      // print("-------------");
    });

    // Future.delayed(Duration(milliseconds: 500) );
    return numLaughsPerHourOverLastDay;
  }
}
