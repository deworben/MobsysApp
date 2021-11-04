import 'package:flutter/material.dart';
import 'route_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true);
  runApp(MyApp());
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
      // home: RecordToStreamExample(),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}


// class AudioCacheManager {
//   static Future getAudioFile(String url) {
//     return FirebaseCacheManager().getSingleFile(url);
//   }
// }










//
// ---------AUDIOPLAYER ---------------------------
//
// class AudioPlayer extends StatefulWidget {
//   const AudioPlayer({Key? key}) : super(key: key);
//
//   @override
//   _AudioPlayerState createState() => _AudioPlayerState();
// }
//
// class _AudioPlayerState extends State<AudioPlayer> {
//   FlutterSoundPlayer? _myPlayer = FlutterSoundPlayer();
//   bool _mPlayerIsInited = false;
//   final _exampleAudioFilePathMP3 = "/";
//
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _myPlayer!.openAudioSession().then((value) {
//       setState(() {
//         _mPlayerIsInited = true;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _myPlayer!.closeAudioSession();
//     _myPlayer = null;
//     super.dispose();
//   }
//
//   void play() async {
//     await _myPlayer!.startPlayer(
//         fromURI: _exampleAudioFilePathMP3,
//         codec: Codec.mp3,
//         whenFinished: (){ setState((){}); }
//     );
//     setState((){});
//   }
//
//   Future<void> stopPlayer() async {
//     if (_myPlayer != null) {
//       await _myPlayer!.stopPlayer();
//     }
//   }
// }
//
//
