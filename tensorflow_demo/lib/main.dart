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
  var state = 0;
  var logger = Logger();
  var status = "Initial";
  var result = "None";
  var detector = LaughDetector();

  callback(bool laughing, double confidence) async {
      logger.i(laughing);
      logger.i(confidence);
      if (laughing) {
        result = "Laughing";
      } else {
        result = "Talking";
      }
      setState(() {});
  }

  loop() async {
    if (state == 0) {
      logger.w("Detector Start");
      await detector.init(callback);
      state = 1;
      status = "Started";
    } else if (state == 1) {
      logger.w("Recording Start");
      await detector.startDetection();
      state = 2;
      status = "Recording";
    } else if (state == 2) {
      logger.w("Recording Stop");
      await detector.stopDetection();
      state = 3;
      status = "Recorded";
    } else if (state == 3) {
      logger.w("Playing Start");
      await detector.startPlayback();
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
