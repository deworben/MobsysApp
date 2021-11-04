import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'static/laugh_detection_controller.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;

  // states that you want to use and update in your view
  var state = 0;
  var status = "Initial";
  var result = "None";
  var consistentResult = "None";
  var lat = 0.0;
  var lgt = 0.0;
  var lat2 = 0.0;
  var lgt2 = 0.0;
  var fileId = "None";


  @override
  Widget build(BuildContext context) {
    print("build button!");

    return ValueListenableBuilder<bool>(
        valueListenable: LaughDetectionController.isRecording,
        builder: (BuildContext context, bool _isRecording, Widget? child) {
          this._isRecording = _isRecording;
          return Center(
              child: TextButton(
                  onPressed: () {
                    LaughDetectionController.recordStartStopPressed(onBuffer, onDetect);
                  },
                  child: this._isRecording ? const Text("Stop Recording") : const Text("Press to Record")
              )
          );
        }
    );
   }


  @override
  void initState() async {
    super.initState();
    LaughDetectionController.initLaughDetector();
  }


  onBuffer(
      bool laughing, bool located, double latitude, double longitude) async {
    if (laughing) {
      result = "Currently Laughing";
    } else {
      result = "Currently Talking";
    }
    if (located) {
      lat = latitude;
      lgt = longitude;
    }
    setState(() {});
  }

  onDetect(String content, bool located, double latitude, double longitude,
      String fileId) async {
    if (content != "") {
      consistentResult = content;
    }
    if (located) {
      lat2 = latitude;
      lgt2 = longitude;
    }
    this.fileId = fileId;
    setState(() {});
  }
}
