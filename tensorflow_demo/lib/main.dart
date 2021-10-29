import 'package:flutter/material.dart';

import 'laugh_detector.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // states that you want to use and update in your view
  var state = 0;
  var logger = Logger();
  var status = "Initial";
  var result = "None";
  var consistentResult = "None";
  var detector = LaughDetector();
  var lat = 0.0;
  var lgt = 0.0;
  var lat2 = 0.0;
  var lgt2 = 0.0;
  var fileId = "None";

  // the function to update the states after detection
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

  // this is a simple finite state machine and does detection in order
  // showing how to use the library
  loop() async {
    if (state == 0) {
      logger.w("Detector Start");
      await detector.init();
      state = 1;
      status = "Started";
    } else if (state == 1) {
      logger.w("Recording Start");
      await detector.startDetection(onBuffer, onDetect);
      state = 2;
      status = "Recording";
    } else if (state == 2) {
      logger.w("Recording Stop");
      await detector.stopDetection();
      state = 3;
      status = "Recorded";
    } else if (state == 3) {
      logger.w("Playing Start");
      if (fileId != "None") {
        await detector.startPlayback(fileId);
      } else {
        logger.e("Not audio file saved yet.");
      }
      state = 4;
      status = "Playing";
    } else if (state == 4) {
      logger.w("Playing Stop");
      await detector.stopPlayback();
      state = 5;
      status = "PlayingStopped";
    } else if (state == 5) {
      logger.w("Detector Stop");
      await detector.destroy();
      state = 0;
      status = "Stopped";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Detection State',
            ),
            Text(
              '$state - $status',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              result,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              '($lat, $lgt)',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              fileId,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              consistentResult,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              '($lat2, $lgt2)',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loop,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
