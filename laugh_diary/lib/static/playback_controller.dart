import 'package:flutter/material.dart';
import 'package:laugh_diary/objects/audio_file.dart';
import 'recording_controller.dart';

// Notifies listeners when values change
class PlaybackController {
  static ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  static ValueNotifier<AudioFile?> currAudioFile = ValueNotifier<AudioFile?>(null);

  static void setCurrAudioFile(AudioFile audioFile) {
    // TODO: can load from cache and begin audio Playback
    currAudioFile.value = audioFile;
  }

  //
  static bool playPausePressed() {
    // can't play audio while recording
    if (RecordingController.isRecording.value) {
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
    if (RecordingController.isRecording.value) {
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
}



