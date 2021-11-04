import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/*
 * This is an example showing how to record to a Dart Stream.
 * It writes all the recorded data from a Stream to a File, which is completely stupid:
 * if an App wants to record something to a File, it must not use Streams.
 *
 * The real interest of recording to a Stream is for example to feed a
 * Speech-to-Text engine, or for processing the Live data in Dart in real time.
 *
 */

///

const int tSampleRate = 44000;
typedef _Fn = void Function();

class Recorder {
  FlutterSoundPlayer? mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? mRecorder = FlutterSoundRecorder();
  bool mPlayerIsInited = false;
  bool mRecorderIsInited = false;
  bool mplaybackReady = false;
  String? _mPath;
  StreamSubscription? _mRecordingDataSubscription;
  var soundQ = Queue<FoodData>();
  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    print(status);
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await mRecorder!.openAudioSession();
    // setState(() {
    //   mRecorderIsInited = true;
    // });
    mRecorderIsInited = true;
  }

  void init() {
    // await firebase_core.Firebase.initializeApp();
    // firebase_storage.FirebaseStorage storage =
    //     firebase_storage.FirebaseStorage.instance;
    // Be careful : openAudioSession return a Future.
    // Do not access your FlutterSoundPlayer or FlutterSoundRecorder before the completion of the Future

    mPlayer!.openAudioSession().then((value) {
      // setState(() {
      //   mPlayerIsInited = true;
      // });
      mPlayerIsInited = true;
    });
    _openRecorder();
  }

  void dispose() {
    stopPlayer();
    mPlayer!.closeAudioSession();
    mPlayer = null;

    stopRecorder();
    mRecorder!.closeAudioSession();
    mRecorder = null;
  }

  Future<IOSink> createFile() async {
    var tempDir = await getTemporaryDirectory();
    _mPath = '${tempDir.path}/flutter_sound_example.pcm';
    var outputFile = File(_mPath!);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    return outputFile.openWrite();
  }

  // ----------------------  Here is the code to record to a Stream ------------

  Future<void> record() async {
    assert(mRecorderIsInited && mPlayer!.isStopped);
    var sink = await createFile();
    var recordingDataController = StreamController<Food>();
    _mRecordingDataSubscription =
        recordingDataController.stream.listen((buffer) {
      if (buffer is FoodData) {
        // print("sunk added buffer data");
        // sink.add(buffer.data!);
        soundQ.add(buffer);
        // print("${DateTime.now()}: ${soundQ.length} elements in sound queue");
        var nSeconds = 3;
        if (soundQ.length > 66 * nSeconds) {
          // print("removing element from sound queue");
          soundQ.removeFirst();
        }
      }
    });
    await mRecorder!.startRecorder(
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: tSampleRate,
    );
    // setState(() {});
  }

  Future<void> stopRecorder() async {
    await mRecorder!.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }
    var sink = await createFile();
    for (var buffer in soundQ) {
      sink.add(buffer.data!);
      print("adding thing to file!");
    }
    mplaybackReady = true;
  }

  _Fn? getRecorderFn() {
    if (!mRecorderIsInited || !mPlayer!.isStopped) {
      return null;
    }
    return mRecorder!.isStopped
        ? record
        : () {
            stopRecorder();
            // stopRecorder().then((value) => setState(() {}));
          };
  }

  void play() async {
    assert(mPlayerIsInited &&
        mplaybackReady &&
        mRecorder!.isStopped &&
        mPlayer!.isStopped);
    await mPlayer!.startPlayer(
      fromURI: _mPath,
      sampleRate: tSampleRate,
      codec: Codec.pcm16,
      numChannels: 1,
      // whenFinished: () {
      //   setState(() {});
      // }
    ); // The readability of Dart is very special :-(
    // setState(() {});
  }

  Future<void> stopPlayer() async {
    await mPlayer!.stopPlayer();
  }

  _Fn? getPlaybackFn() {
    if (!mPlayerIsInited || !mplaybackReady || !mRecorder!.isStopped) {
      return null;
    }
    return mPlayer!.isStopped
        ? play
        : () {
            stopPlayer();
            // stopPlayer().then((value) => setState(() {}));
          };
  }
}
