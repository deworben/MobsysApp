/*
 * Copyright 2018, 2019, 2020 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 3 (LGPL-V3), as published by
 * the Free Software Foundation.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Flutter-Sound.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'service/recorder.dart';

void main() {
  runApp(const MyApp());
}

class MyColor extends MaterialStateColor {
  const MyColor() : super(_defaultColor);

  static const int _defaultColor = 0xcafefeed;
  static const int _pressedColor = 0xdeadbeef;

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return const Color(_pressedColor);
    }
    return const Color(_defaultColor);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecordToStreamExample(),
    );
  }
}

/// Example app.
class RecordToStreamExample extends StatefulWidget {
  @override
  _RecordToStreamExampleState createState() => _RecordToStreamExampleState();
}

class _RecordToStreamExampleState extends State<RecordToStreamExample> {
  final Future<firebase_core.FirebaseApp> _initialization =
      firebase_core.Firebase.initializeApp();
  Recorder recorder = Recorder();

  bool weAreRecording = false;
  bool weArePlaying = false;

  @override
  void initState() {
    super.initState();
    recorder.init();
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  Widget buildFullApp(BuildContext context) {
    Widget makeBody() {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: () {
                  var recorderFunc = recorder.getRecorderFn();
                  if (recorderFunc != null) {
                    recorderFunc();
                  }
                  weAreRecording = recorder.mRecorder!.isRecording;
                  setState(() {});
                },
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Text(weAreRecording ? 'Stop' : 'Record'),
              ),
              SizedBox(
                width: 20,
              ),
              Text(weAreRecording
                  ? 'Recording in progress'
                  : 'Recorder is stopped'),
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: () {
                  var playbackFunc = recorder.getPlaybackFn();
                  if (playbackFunc != null) {
                    playbackFunc();
                  }
                  weArePlaying = recorder.mPlayer!.isPlaying;
                  setState(() {});
                },
                // style: ButtonStyle(backgroundColor: MyColor()),
                // backgroundColor: weArePlaying ? MaterialStateColor Colors.blue : Colors.grey),
                // color: Colors.white,
                // disabledColor: Colors.grey,
                child: Text(weArePlaying ? 'Stop' : 'Play'),
              ),
              SizedBox(
                width: 20,
              ),
              Text(weArePlaying ? 'Playback in progress' : 'Player is stopped'),
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: () async {
                  print("hello mr console3");
                  var tempDir = await getTemporaryDirectory();
                  var targetFile = '${tempDir.path}/flutter_sound_example.pcm';

                  // var allFiles = Directory("${tempDir.path}")
                  //     .listSync(); // list all files in temp dir
                  File file = File(targetFile);

                  await FirebaseAppCheck.instance
                      .activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');
                  FirebaseAuth auth = FirebaseAuth.instance;
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
                },
                //disabledColor: Colors.grey,
                child: Text('My button'),
              ),
              SizedBox(
                width: 20,
              ),
              Text('Some more text'),
            ]),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Record to Stream ex.'),
      ),
      body: makeBody(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
          // return SomethingWentWrong();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return buildFullApp(context);
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Text("still loading");
      },
    );
  }
}
