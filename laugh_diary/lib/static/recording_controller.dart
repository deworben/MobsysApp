import 'package:flutter/material.dart';
import 'playback_controller.dart';

class RecordingController {
  static ValueNotifier<bool> isRecording = ValueNotifier<bool>(false);

  static bool startStopPressed() {
    // can't record if playing audio
    if (PlaybackController.isPlaying.value) {
      if (isRecording.value) {
        throw Exception("Should not be able to record while audio is playing");
      }
      return false;
    }
    isRecording.value = !isRecording.value;
    return true;
  }
}
