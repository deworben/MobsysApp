import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mfcc/mfcc.dart';
import 'package:tflite/tflite.dart';
import 'package:dio/dio.dart';

/// 1.  Add permissions to AndroidManifest.xml
/// 2.  Install all dependencies
/// 3.  Set android/build.gradle target and compile SDK to 31
/// 4.  Set android/build.gradle min SDK 21
/// 5.  Add --enable-software-rendering flag to run configuration
/// 6.  Add --no-sound-null-safety flag to run configuration
class LaughDetector {
  FlutterSoundPlayer? player;
  FlutterSoundRecorder? recorder;
  StreamSubscription? audioSub;
  void Function(bool, double, bool) callback = (y, p, c) => {};
  var buffer = List<int>.from([]);
  var prevBuffers = List<List<int>>.from([]);
  var prevPredictions = List<int>.from([]);
  var samplingRate = 44100; // DO NOT CHANGE
  var recorderOpened = false;
  var playerOpened = false;
  var logLevel = Level.debug;
  var logger = Logger();
  var maxSamples = 44100; // DO NOT CHANGE
  var fileName = "recording";
  var dio = Dio();
  var training = false;
  var historySize = 10;
  var laughRatioThreshold = 0.5;

  LaughDetector();

  Future<void> init(final void Function(bool, double, bool) cb) async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    if (!recorderOpened) {
      recorder = FlutterSoundRecorder(logLevel: logLevel);
      await recorder!.openAudioSession();
      recorderOpened = true;
    }
    if (!playerOpened) {
      player = FlutterSoundPlayer(logLevel: logLevel);
      await player!.openAudioSession();
      playerOpened = true;
    }
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt");
    callback = cb;
  }

  Future<void> destroy() async {
    if (recorderOpened) {
      await recorder!.closeAudioSession();
      recorder = null;
      recorderOpened = false;
    }
    if (playerOpened) {
      await player!.closeAudioSession();
      player = null;
      playerOpened = false;
    }
  }

  Future<void> startDetection() async {
    if (!recorderOpened || !recorder!.isStopped) {
      return;
    }
    // reset buffer
    buffer = List.from([]);
    prevBuffers = List.from([]);
    var controller = StreamController<Food>();
    audioSub = controller.stream.listen((segment) async {
      if (segment is FoodData) {
        buffer.addAll(segment.data!.toList());
        if (buffer.length > maxSamples) {
          // buffer swap
          var lastBuffer = buffer.take(maxSamples).toList();
          prevBuffers.add(buffer);
          buffer = List.from([]);

          // limit historic buffer size
          while (prevBuffers.length > historySize) {
            prevBuffers.removeAt(0);
            prevPredictions.removeAt(0);
          }

          // save to file
          var tempDir = await getTemporaryDirectory();
          var outFile = File('${tempDir.path}/$fileName.pcm');
          if (outFile.existsSync()) {
            await outFile.delete();
          }
          IOSink fileSink = outFile.openWrite();
          for (var b in prevBuffers) {
            fileSink.add(Uint8List.fromList(b));
          }
          fileSink.close();

          // convert pcm to mfcc
          var samples =
              Uint8List.fromList(lastBuffer).buffer.asInt16List().toList();
          var samplesCvt = samples.map((e) => e.toDouble()).toList();
          var features =
              MFCC.mfccFeats(samplesCvt, samplingRate, 1024, 512, 512, 20, 20);

          // upload for training
          if (training) {
            var svrResp = await dio.post('http://172.16.0.5:5000/',
                data: {'mfcc': features}).catchError((e) => {});
            logger.d(svrResp);
          }

          // convert mfcc to input tensor
          var flattened = features.expand((i) => i).toList();
          var input = Float32List.fromList(flattened).buffer.asUint8List();

          // classification
          var predictions = await Tflite.runModelOnBinary(binary: input);
          var laughing = false;
          var confidence = 0.0;

          if (predictions!.isNotEmpty) {
            if (predictions[0]['label'] == 'laughing') {
              laughing = true;
              confidence = predictions[0]['confidence'];
            } else {
              laughing = false;
              confidence = predictions[0]['confidence'];
            }
            logger.d(laughing);
            logger.d(confidence);
          }
          prevPredictions.add(laughing ? 1 : 0);

          // verify the user is consistently laughing
          var consistentLaughing = false;
          var laughCount = prevPredictions.reduce((a, b) => a + b);
          if (laughCount > laughRatioThreshold * historySize) {
            consistentLaughing = true;
          }

          // execute call back to deliver result
          callback(laughing, confidence, consistentLaughing);
        }
      }
    });
    await recorder!.startRecorder(
      toStream: controller.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: samplingRate,
    );
  }

  Future<void> stopDetection() async {
    if (!recorderOpened || !recorder!.isRecording) {
      return;
    }
    await recorder!.stopRecorder();
    await audioSub!.cancel();
    audioSub = null;
  }

  Future<void> startPlayback() async {
    if (!playerOpened || !player!.isStopped) {
      return;
    }
    var tempDir = await getTemporaryDirectory();
    await player!.startPlayer(
        fromURI: '${tempDir.path}/$fileName.pcm',
        sampleRate: samplingRate,
        codec: Codec.pcm16,
        numChannels: 1);
  }

  Future<void> stopPlayback() async {
    if (!playerOpened || !player!.isPlaying) {
      return;
    }
    await player!.stopPlayer();
  }
}
