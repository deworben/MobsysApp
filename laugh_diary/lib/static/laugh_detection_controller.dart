import 'package:flutter/material.dart';
import 'package:laugh_diary/objects/audio_file.dart';
import 'recording_controller.dart';
import 'package:laugh_diary/laugh_detector.dart';

typedef RealtimeCallBack = void Function(bool, bool, double, double);
typedef DetectionCallBack = void Function(String, bool, double, double, String);

// Notifies listeners when values change
class LaughDetectionController {
  // Audio player notifiers
  static ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  static ValueNotifier<AudioFile?> currAudioFile =
      ValueNotifier<AudioFile?>(null);

  // Recorder notifier
  static ValueNotifier<bool> isRecording = ValueNotifier<bool>(false);

  // Laugh detection stuff
  static final LaughDetector _laughDetector = LaughDetector();
  static bool initialised = false;

  static void setCurrAudioFile(AudioFile audioFile) {
    // TODO: can load from cache and begin audio Playback
    currAudioFile.value = audioFile;
  }

  //
  static bool audioPlayPausePressed() {
    // can't play audio while recording
    if (isRecording.value) {
      if (isPlaying.value) {
        throw Exception("Should not be able to play audio while recording");
      }
      return false;
    }
    isPlaying.value = !isPlaying.value;
    return true;
  }

  static bool playAudioFile(AudioFile audioFile) {
    // can't play audio while recording
    if (isRecording.value) {
      if (isPlaying.value) {
        throw Exception("Should not be able to play audio while recording");
      }
      return false;
    }

    // check if need to update current audio file
    if (currAudioFile.value != audioFile) {
      currAudioFile.value = audioFile;
    }
    isPlaying.value = true;

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

    // if (_laughDetector.recorder!.isStopped) {
    //   // TODO: safety check
    // }

    return true;
  }

  static void initLaughDetector() async {
    await _laughDetector.init();
    initialised = true;
  }
}
