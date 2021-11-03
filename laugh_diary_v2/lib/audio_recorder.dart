import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'static/laugh_detection_controller.dart';



class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;

  Duration _elapsedTime = const Duration();
  Timer? timer;

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
  var logger = Logger();


  @override
  Widget build(BuildContext context) {
    // print("build button!");

    return ValueListenableBuilder<bool>(
      valueListenable: LaughDetectionController.isRecording,
      builder: (BuildContext context, bool _isRecording, Widget? child) {
        this._isRecording = _isRecording;
        return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children : [
              elapsedTime(),
              stopStartButton(),
            ],
            ),
          );
        }
    );
   }


  @override
  void initState() {
    super.initState();
    LaughDetectionController.initLaughDetector();
  }


  Widget stopStartButton() {
    return Container(
      margin: EdgeInsets.all(30.0),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: TextButton(
          onPressed: () {
            LaughDetectionController.recordStartStopPressed(onBuffer, onDetect).then(
                (_) {triggerTimer();});
          },
          child: Icon(
            _isRecording ? Icons.stop : Icons.play_arrow,
            size: 60,
          )
      ),
    );
  }

  Widget elapsedTime() {
    String getTwoDigits(int n) => n.toString().padLeft(2,'0');
    final hours = getTwoDigits(_elapsedTime.inHours);
    final minutes = getTwoDigits(_elapsedTime.inMinutes.remainder(60));
    final seconds = getTwoDigits(_elapsedTime.inSeconds.remainder(60));
    final textStyle = TextStyle(fontSize: 30);
    return Container(
      child: Text(hours + ":" + minutes + ":" + seconds, style: textStyle,),
    );
  }


  void triggerTimer() {
    if (LaughDetectionController.isRecording.value) {
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {
          _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);
        });
      });
    }
    else {
      setState(() {
        timer?.cancel();
        _elapsedTime = Duration();
      });
    }
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
    logger.i(laughing);
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

    // save the file id
    LaughDetectionController.saveAudioId(fileId, content);

    setState(() {});
    logger.e(content);
  }
}
