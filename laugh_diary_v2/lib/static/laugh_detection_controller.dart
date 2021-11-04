import 'dart:math';

import 'package:flutter/material.dart';
import 'package:laugh_diary_v2/objects/audio_file.dart';
import 'package:laugh_diary_v2/service/firebase_service.dart';
import 'recording_controller.dart';
import 'package:laugh_diary_v2/laugh_detector.dart';
import 'package:logger/logger.dart';
import 'package:flutter_sound/flutter_sound.dart';

typedef RealtimeCallBack = void Function(bool, bool, double, double);
typedef DetectionCallBack = void Function(String, bool, double, double, String, int);
typedef PlaybackCompleteCallBack = void Function();

// Notifies listeners when values change
class LaughDetectionController {

  static var logger = Logger();

  // Audio player notifiers
  static ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  static ValueNotifier<AudioFile?> currAudioFile =
      ValueNotifier<AudioFile?>(null);
  static ValueNotifier<List<AudioFile>> audioFiles = ValueNotifier<List<AudioFile>>([]);



  // Recorder notifier
  static ValueNotifier<bool> isRecording = ValueNotifier<bool>(false);
  static ValueNotifier<AudioFile?> lastSavedAudioFile = ValueNotifier<AudioFile?>(null);
  static ValueNotifier<PlaybackDisposition?> audioDisposition = ValueNotifier<PlaybackDisposition?>(null);

  // Laugh detection stuff
  static final LaughDetector _laughDetector = LaughDetector();
  static bool initialised = false;

  static void setCurrAudioFile(AudioFile audioFile) {
    // TODO: can load from cache and begin audio Playback
    currAudioFile.value = audioFile;
  }

  static void onComplete() {
    isPlaying.value = false;
  }

  //
  static Future<bool> audioPlayPausePressed() async {
    // can't play audio while recording
    if (isRecording.value || currAudioFile.value == null) {
      if (isPlaying.value) {
        throw Exception("Should not be able to play audio while recording");
      }
      return false;
    }
    isPlaying.value = !isPlaying.value;
    if (isPlaying.value) {
      await _laughDetector.startPlayback(currAudioFile.value!.filePath, onComplete);
    } else {
      await _laughDetector.stopPlayback();
    }
    return true;
  }

  static Future<bool> playAudioFile(AudioFile audioFile) async {
    // can't play audio while recording
    if (isRecording.value) {
      if (isPlaying.value) {
        throw Exception("Should not be able to play audio while recording");
      }
      return false;
    }

    if (isPlaying.value) {
      await _laughDetector.stopPlayback();
    }

    // check if need to update current audio file
    if (currAudioFile.value != audioFile) {
      currAudioFile.value = audioFile;
    }

    isPlaying.value = true;
    await _laughDetector.startPlayback(audioFile.filePath, onComplete);

    return true;
  }

  static Future<bool> recordStartStopPressed(
      RealtimeCallBack onBuffer, DetectionCallBack onDetect) async {
    // can't record if playing audio or uninitialised
    if (isPlaying.value || !initialised) {
      if (isRecording.value) {
        throw Exception(
            "Should not be able to record while audio is playing or laugh detector isn't initialised");
      }
      return false;
    }

    isRecording.value = !isRecording.value;

    if (isRecording.value) {
      await _laughDetector.startDetection(onBuffer, onDetect);
    }
    else {
      await _laughDetector.stopDetection();
    }

    return true;
  }

  static void initLaughDetector() async {
    await _laughDetector.init();
    initialised = true;
  }

  static Future<void> seek(double d) async {
    await _laughDetector.seek(d);
  }

  // For testing
  static void saveAudioId(String path, String content, int duration) {
    logger.e("Save audio ID $path");
    // create AudioFile Object
    AudioFile newAudioFile = AudioFile(path, DateTime(2021, 9, 7, 17, 5), Duration(seconds: duration), content);

    var fbService = FirebaseService();
    fbService.uploadFile(newAudioFile);

    // add to list
    audioFiles.value.add(newAudioFile);
    audioFiles.value = List.from(audioFiles.value);

    // save last created audioFile
    lastSavedAudioFile.value = newAudioFile;
  }


}
