import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_recorder.dart';
import 'package:flutter_cache_manager_firebase/flutter_cache_manager_firebase.dart';
import 'audio_files.dart';
import 'audio_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  //TODO: save int to cache to save state when closing app
  // Current open page
  int _selectedIndex = 0;

  // List of pages
  static const List<Widget> _pages = <Widget>[
    AudioRecorder(),
    AudioFileList(),
  ];

  // Template build function
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laugh Diary',
      home: Scaffold(
        body: Stack(
          children: [
            // Positioned(
            //   child: AudioPlayer(),
            //   bottom: 10,
            // ),
            IndexedStack(
              index: _selectedIndex,
              children: _pages,      // use the RecordButton widget
            ),
            AudioPlayer(),
          ],
          alignment: AlignmentDirectional.bottomStart,
        ),
        // IndexedStack(
        //   index: _selectedIndex,
        //   children: _pages,      // use the RecordButton widget
        // ),
        backgroundColor: Colors.yellow,
        bottomNavigationBar: bottomBar(),
      ),
    );
  }

  //https://blog.logrocket.com/how-to-build-a-bottom-navigation-bar-in-flutter/
  // Bottom bar and functionality
  Widget bottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
        selectedItemColor: Colors.yellow,
      unselectedItemColor: Colors.white,
      elevation: 8.0,
      iconSize: 24,
      items: const<BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Record",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: "Your Library",
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      }
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
