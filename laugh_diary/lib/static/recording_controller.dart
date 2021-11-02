import 'package:flutter/material.dart';
import 'laugh_detection_controller.dart';
import 'package:laugh_diary/laugh_detector.dart';



// typedef RealtimeCallBack = void Function(bool, bool, double, double);
// typedef DetectionCallBack = void Function(String, bool, double, double, String);
//
// class RecordingController {
//   static ValueNotifier<bool> isRecording = ValueNotifier<bool>(false);
//
//   static final LaughDetector _laughDetector = LaughDetector();
//   static bool initialised = false;
//
//   static bool recordStartStopPressed(RealtimeCallBack onBuffer, DetectionCallBack onDetect) {
//     // can't record if playing audio or uninitialised
//     if (LaughDetectionController.isPlaying.value || !initialised) {
//       if (isRecording.value) {
//         throw Exception("Should not be able to record while audio is playing or laugh detector isn't initialised");
//       }
//       return false;
//     }
//     _laughDetector.startDetection(onBuffer, (onDetect));
//     isRecording.value = !isRecording.value;
//
//     return true;
//   }
//
//
//   static void initLaughDetector() async {
//     await _laughDetector.init();
//     initialised = true;
//   }


