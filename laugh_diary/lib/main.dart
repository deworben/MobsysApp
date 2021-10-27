import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_recorder.dart';
import 'package:flutter_cache_manager_firebase/flutter_cache_manager_firebase.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  //TODO: save int to cache
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    AudioRecorder(),
    AudioFileList(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laugh Diary',
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Laugh"),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,      // use the RecordButton widget
        ),
        backgroundColor: Colors.yellow,
        bottomNavigationBar: bottomBar(),
    ),
      color: Colors.red,    // TODO: this doesn't work for some reason
    );
  }

  //https://blog.logrocket.com/how-to-build-a-bottom-navigation-bar-in-flutter/
  Widget bottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.cyanAccent,
      elevation: 8.0,
      iconSize: 24,
      items: const<BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: "Playlist",
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


class AudioFileList extends StatefulWidget {
  const AudioFileList({Key? key}) : super(key: key);

  @override
  _AudioFileListState createState() => _AudioFileListState();
}

class _AudioFileListState extends State<AudioFileList> {

  var audioFiles = ["audioFile1", "audioFile2", "audioFile3",
    "audioFile4", "audioFile5", "audioFile6",
    "audioFile7", "audioFile8", "audioFile9",
    "audioFile10", "audioFile11", "audioFile12"];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List<AudioFile>.generate(audioFiles.length, (i) => AudioFile(audioFiles[i])),
    );
  }

  @override
  void initState() {
    super.initState();

    // load a list of audio files
    loadAudioFiles();
  }

  void loadAudioFiles(){
    // TODO
    // append to list
    // get latest x from cache or firebase
  }

}


class AudioFile extends StatefulWidget {
  String filePath;

  AudioFile(this.filePath) {}

  @override
  State<AudioFile> createState() => _AudioFileState();
}

class _AudioFileState extends State<AudioFile> {
  bool isPlaying = false;

  DateTime? date;

  Duration? duration;

  Image? coverPhoto;

  Color textColor = Colors.black;

  @override
  Widget build(BuildContext context) {
     return Card(
        child: ListTile(
          title: Text(widget.filePath,
            style: TextStyle(color: textColor),
          ),
          onTap: () {
            setState(() {
              isPlaying = !isPlaying;
              if (!isPlaying) {
                textColor = Colors.black;
                PlayAudio();
              }
              else {
                textColor = Colors.red;
              }
            });
          },
        )
     );
  }

  void PlayAudio() {
    // audioManager.PlayAudio
  }
}


class AudioCacheManager {
  static Future getAudioFile(String url) {
    return FirebaseCacheManager().getSingleFile(url);
  }
  
  static Future writeAudioFileToCache() {
    return FirebaseCacheManager().putFile(url, fileBytes)
  }
}

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
