import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:laugh_diary_v2/objects/audio_file.dart';
import 'package:logger/logger.dart';
import '../static/laugh_detection_controller.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  bool _currStatus = false; // either laughing or not laughing
  List<double> xCoors = [0, 1, 2, 3, 4, 5];
  List<double> yCoors = [0, -100, 80, 100, 50, 0];
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
              children: [
                lastSavedAudioFile(),
                currentStatus(),
                lineCard(xCoors, yCoors, 1),
                elapsedTime(),
                stopStartButton(),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    LaughDetectionController.initLaughDetector();
  }

  Widget stopStartButton() {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.all(30.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: Color(0xAAC5C5C5), spreadRadius: 1, blurRadius: 8)
        ],
      ),
      child: TextButton(
          onPressed: () {
            LaughDetectionController.recordStartStopPressed(onBuffer, onDetect)
                .then((_) {
              triggerTimer();
            });
          },
          child: Icon(
            _isRecording
                ? Icons.stop_outlined
                : Icons.fiber_manual_record_outlined,
            size: 60,
            color: _isRecording ? Color(0xFFF05E1C) : Color(0xFFCB1B45),
          )),
    );
  }

  // The widget for the elapsed time
  Widget elapsedTime() {
    String getTwoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = getTwoDigits(_elapsedTime.inHours);
    final minutes = getTwoDigits(_elapsedTime.inMinutes.remainder(60));
    final seconds = getTwoDigits(_elapsedTime.inSeconds.remainder(60));
    const textStyle = TextStyle(fontSize: 60);
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: Text(
        hours + ":" + minutes + ":" + seconds,
        style: textStyle,
      ),
    );
  }

  Widget currentStatus() {
    if (_isRecording) {
      return Container(
        margin: EdgeInsets.all(30.0),
        child: Text(
            "Current Status: " + (_currStatus ? "Not Laughing" : "Laughing"),
            style: TextStyle(fontSize: 15)),
      );
    } else {
      // return empty widget
      return SizedBox.shrink();
    }
  }

  Widget lastSavedAudioFile() {
    return ValueListenableBuilder<AudioFile?>(
        valueListenable: LaughDetectionController.lastSavedAudioFile,
        builder: (BuildContext context, AudioFile? _lastSavedAudioFile,
            Widget? child) {
          if (_lastSavedAudioFile != null) {
            return Column(
              children: [
                Text("Recently Saved: ", style: TextStyle(fontSize: 15)),
                ListTile(
                  leading: FlutterLogo(),
                  title: Text(
                    _lastSavedAudioFile.filePath! +
                        " " +
                        _lastSavedAudioFile.content,
                    style: TextStyle(
                        color: LaughDetectionController.isPlaying.value
                            ? Colors.red
                            : Colors.black),
                  ),
                  subtitle: Text(DateFormat.yMMMd()
                          .format(_lastSavedAudioFile.date) +
                      "  " +
                      _lastSavedAudioFile.duration.toString().substring(2, 7)),
                  onTap: () {
                    setState(() {
                      LaughDetectionController.playAudioFile(
                          _lastSavedAudioFile);
                    });
                  },
                )
              ],
            );
          } else {
            // return empty widghet
            return const SizedBox.shrink();
          }
        });
  }

  // Starts/stops the timer
  void triggerTimer() {
    if (LaughDetectionController.isRecording.value) {
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {
          _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);
        });
      });
    } else {
      setState(() {
        timer?.cancel();
        _elapsedTime = Duration();
      });
    }
  }

  onBuffer(
      bool laughing, bool located, double latitude, double longitude) async {
    logger.i(laughing);
    setState(() {
      _currStatus = !laughing;
    });
  }

  onDetect(String content, bool located, double latitude, double longitude,
      String fileId, String filePath, int duration) async {
    LaughDetectionController.saveAudioId(fileId, filePath, content, duration);
    logger.i(content);
  }

  Widget lineCard(
      List<double> xCoordinates,
      List<double> yCoordinates,
      int lineColorIndex) {
    List<Color> lineColors = List.from([
      const Color(0xCC77428D),
      const Color(0xCCD0104C),
      const Color(0xCC005CAF),
      const Color(0xCCF05E1C),
    ]);

    List<FlSpot> dataPoints = List.from([]);
    for (var i = 0; i < xCoordinates.length; i++) {
      dataPoints.add(FlSpot(xCoordinates[i], yCoordinates[i]));
    }

    var xMax = xCoordinates.reduce(max);
    var yMax = yCoordinates.reduce(max);

    var axisStyles = FlTitlesData(
      rightTitles: SideTitles(showTitles: false),
      topTitles: SideTitles(showTitles: false),
      bottomTitles: SideTitles(showTitles: false),
      leftTitles: SideTitles(showTitles: false),
    );

    var borderStyles = FlBorderData(show: false);

    var gridStyles = FlGridData(
      show: false,
    );

    var line = LineChartBarData(
      isCurved: true,
      colors: [lineColors[lineColorIndex]],
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      spots: dataPoints
    );

    var data = LineChartData(
      gridData: gridStyles,
      titlesData: axisStyles,
      borderData: borderStyles,
      lineBarsData: List.from([line]),
      minX: 0,
      maxX: xMax,
      maxY: yMax,
      minY: 0,
    );

    return Container(
        height: 200,
        // padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top:20, bottom:20),
        child: LineChart(data,
            swapAnimationDuration: const Duration(milliseconds: 250)));
  }
}
