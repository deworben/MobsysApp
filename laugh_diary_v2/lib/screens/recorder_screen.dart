import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:laugh_diary_v2/service/firebase_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

import '../service/recorder.dart';

class RecordToStreamExample extends StatefulWidget {
  @override
  _RecordToStreamExampleState createState() => _RecordToStreamExampleState();
}

class _RecordToStreamExampleState extends State<RecordToStreamExample> {
  Recorder recorder = Recorder();
  FirebaseService firebaseService = FirebaseService();

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
            // Button to go to new page
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
                // onPressed: firebaseService.uploadFile,
                onPressed: () {},
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
    return buildFullApp(context); // TODO fix this
    //   return FutureBuilder(
    //     // Initialize FlutterFire:
    //     future: firebaseService.initialization,
    //     builder: (context, snapshot) {
    //       // Check for errors
    //       if (snapshot.hasError) {
    //         return Center(
    //           child: Text('Error: ${snapshot.error}'),
    //         );
    //         // return SomethingWentWrong();
    //       }

    //       // Once complete, show your application
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         return buildFullApp(context);
    //       }

    //       // Otherwise, show something whilst waiting for initialization to complete
    //       return Text("still loading");
    //     },
    //   );
  }
}
