import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mfcc/mfcc.dart';
import 'package:tflite/tflite.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_speech/google_speech.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:synchronized/synchronized.dart' as mutex;
import 'package:nanoid/nanoid.dart';
import 'static/laugh_detection_controller.dart';

/// 1.  Add permissions to AndroidManifest.xml
/// 2.  Install all dependencies
/// 3.  Set android/build.gradle target and compile SDK to 31
/// 4.  Set android/build.gradle min SDK 21
/// 5.  Add --enable-software-rendering flag to run configuration
/// 6.  Add --no-sound-null-safety flag to run configuration
/// 7.  Use an AVD that supports google play services (i.e. Pixel 4)
/// 8.  Go to GCP, create a project, add speech to text API, create a service account, add a key in json,
///       download the json key file, add it to assets, name it "serviceAccount.json".

typedef RealtimeCallBack = void Function(bool, bool, double, double);
typedef DetectionCallBack = void Function(
    String, bool, double, double, String, String, int);
typedef SpectralCallBack = void Function(double);
typedef SaveEnableCallBack = void Function();
typedef PlaybackCompleteCallBack = void Function();

class LaughDetector {
  FlutterSoundPlayer? player;
  FlutterSoundRecorder? recorder;
  StreamSubscription? audioSub;
  SpeechToText? speechToText;
  RecognitionConfig? speechRecognitionConfig;
  StreamSubscription? progressSub;
  var buffer = List<int>.from([]);
  var prevBuffers = List<List<int>>.from([]);
  var laughLock = mutex.Lock();
  var prevPredictions = List<int>.from([]);
  var prevConsistentlyLaughing = false;
  var samplingRate = 44100; // DO NOT CHANGE
  var recorderOpened = false;
  var playerOpened = false;
  var logLevel = Level.debug;
  var logger = Logger();
  var maxBufferSize = 44100; // DO NOT CHANGE
  var dio = Dio();
  var training = false;
  var historySize = 20;
  var lookBackN = 8;
  var lookBackThresh = 6;
  var bufferLock = mutex.Lock();
  var recorded = false;

  LaughDetector();

  Future<void> init() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      throw const LocationServiceDisabledException();
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
        model: "assets/zacmodel.tflite", labels: "assets/labels.txt");

    var gcpCredential =
        await rootBundle.loadString('assets/serviceAccount.json');
    var serviceAccount = ServiceAccount.fromString(gcpCredential);
    speechToText = SpeechToText.viaServiceAccount(serviceAccount);

    speechRecognitionConfig = RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: samplingRate,
        languageCode: 'en-US');

    // TODO: FIX THIS
    // feed audio info into static notifier variable
    player!.setSubscriptionDuration(const Duration(milliseconds: 50));

    logger.i("Laugh detector has been initialised");
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

  Future<void> processBuffer(
      List<int> bufferCopy,
      List<List<int>> prevBuffersCopy,
      RealtimeCallBack onBuffer,
      DetectionCallBack onDetect,
      SpectralCallBack onSpectral,
      SaveEnableCallBack onSaveEnable) async {
    bufferCopy = bufferCopy.take(maxBufferSize).toList();

    var spectral = bufferCopy.reduce((a, b) => a + b).toDouble() / buffer.length;
    onSpectral(spectral);

    var samples = Uint8List.fromList(bufferCopy)
        .buffer
        .asInt16List()
        .toList()
        .map((e) => e.toDouble())
        .toList();
    var features =
        MFCC.mfccFeats(samples, samplingRate, 1024, 512, 512, 20, 20);
    // var svrResp = await dio.post('http://192.168.15.163:5000/',
    //     data: {'mfcc': features}).catchError((e) => {});
    // logger.d(svrResp);
    var flattened = features.expand((i) => i).toList();
    var input = Float32List.fromList(flattened).buffer.asUint8List();
    var predictions = await Tflite.runModelOnBinary(binary: input);

    var currentlyLaughing = false;
    if (predictions!.isNotEmpty) {
      currentlyLaughing = predictions.first['label'] == 'laughing';
    }

    var detected = false;
    await laughLock.synchronized(() async {
      prevPredictions.add(currentlyLaughing ? 1 : 0);
      if (prevPredictions.length > historySize) {
        prevPredictions.removeAt(0);
      }
      var laughCount =
          prevPredictions.reversed.take(lookBackN).reduce((a, b) => a + b);
      var consistentlyLaughing = laughCount >= lookBackThresh;
      detected = !prevConsistentlyLaughing && consistentlyLaughing;
      if (prevConsistentlyLaughing && !consistentlyLaughing) {
        prevPredictions =
            List.filled(prevPredictions.length, 0, growable: true);
        onSaveEnable();
      }
      prevConsistentlyLaughing = consistentlyLaughing;
    });

    var located = false;
    var latitude = 0.0;
    var longitude = 0.0;
    try {
      var loc = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      located = true;
      latitude = loc.latitude;
      longitude = loc.longitude;
    } on Exception catch (_) {
      logger.e(
          "Cannot acquire location, skipping. If you are seeing this, this is expected.");
    }

    var content = "";
    var sampleCount = 0;
    if (detected) {
      var tempDir = await getTemporaryDirectory();
      var fileId = nanoid();
      var filePath = '${tempDir.path}/$fileId.pcm';
      var outFile = File(filePath);
      if (outFile.existsSync()) {
        await outFile.delete();
      }
      IOSink fileSink = outFile.openWrite();
      var fullRecording = prevBuffersCopy.expand((i) => i).toList();
      sampleCount = fullRecording.length;
      fileSink.add(Uint8List.fromList(fullRecording));
      fileSink.close();
      var recognitionResult = await speechToText!
          .recognize(speechRecognitionConfig!, fullRecording);
      if (recognitionResult.results.isNotEmpty &&
          recognitionResult.results.first.alternatives.isNotEmpty) {
        content = recognitionResult.results.first.alternatives.first.transcript;
      }

      var duration = (sampleCount / samplingRate).round();

      onDetect(
          content, located, latitude, longitude, fileId, filePath, duration);
    }


    onBuffer(currentlyLaughing, located, latitude, longitude);
  }

  /// Maybe wrap the detection in another async function. with duplicate buffer.
  /// so it keeps adding the buffer.
  /// but processing are mostly done on the side.
  Future<void> startDetection(
      RealtimeCallBack onBuffer,
      DetectionCallBack onDetect,
      SpectralCallBack onSpectral,
      SaveEnableCallBack onSaveEnable) async {
    if (!recorderOpened || !recorder!.isStopped) {
      return;
    }

    buffer = List.from([]);
    prevBuffers = List.from([]);
    var controller = StreamController<Food>();
    audioSub = controller.stream.listen((segment) async {
      if (segment is FoodData) {
        await bufferLock.synchronized(() async {
          buffer.addAll(segment.data!.toList());
          if (buffer.length > maxBufferSize) {
            prevBuffers.add(buffer);
            if (prevBuffers.length > historySize) {
              prevBuffers.removeAt(0);
            }
            processBuffer(
                List.from(buffer), List.from(prevBuffers), onBuffer, onDetect, onSpectral, onSaveEnable);
            buffer = List.from([]);
          }
        });
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

  Future<void> startPlayback(
      String filePath, PlaybackCompleteCallBack onComplete) async {
    if (!playerOpened || !player!.isStopped) {
      return;
    }
    var tempDir = await getTemporaryDirectory();
    progressSub = player!.onProgress!.listen((e) {
      LaughDetectionController.audioDisposition.value = e;
    });
    await player!.startPlayer(
        fromURI: filePath,
        sampleRate: samplingRate,
        codec: Codec.pcm16,
        numChannels: 1);
  }

  Future<void> stopPlayback() async {
    if (!playerOpened || player!.isStopped) {
      return;
    }
    await player!.stopPlayer();
    await progressSub!.cancel();
  }

  Future<void> seek(double d) async {
    if (!playerOpened || player!.isStopped) {
      return;
    }
    await player!.seekToPlayer(Duration(milliseconds: d.floor()));
  }

  Future<void> pausePlayback() async {
    if (!playerOpened || player!.isStopped) {
      return;
    }
    await player!.pausePlayer();
  }

  Future<bool> resumePlayback() async {
    if (!playerOpened || player!.isStopped) {
      return false;
    }
    await player!.resumePlayer();
    return true;
  }

  bool isPaused() {
    if (!playerOpened || player!.isStopped) {
      return false;
    }
    return player!.isPaused;
  }
}
