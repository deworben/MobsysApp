import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laugh Diary',
      home: Scaffold(
        appBar: AppBar(
          title: const Text("press the button"),
        ),
        body: Center(
          child: AudioRecorder(),      // use the RecordButton widget
        ),
        backgroundColor: Colors.black,
    ),
      color: Colors.red,    // TODO: this doesn't work for some reason
    );
  }
}

// //
// class RecordButton extends StatefulWidget {
//   const RecordButton({Key? key}) : super(key: key);
//
//   @override
//   _RecordButtonState createState() => _RecordButtonState();
// }
//
// // The button will change state depending on _recording
// class _RecordButtonState extends State<RecordButton> {
//   bool _recording = false;
//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//         onPressed: () {
//           setState(() {
//             _recording = _recording ? false : true;
//           });
//         },
//         child: _recording ? const Text("Stop Recording") : const Text("Press to Record")
//     );
//   }
// }


class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _myRecorder = FlutterSoundRecorder();
  bool _myRecorderIsInited = false;
  bool _isRecording = false;
  String _mPath = "";
  final _mCodec = Codec.aacADTS;


  @override
  Widget build(BuildContext context) {
    print("build button!");
    print(_myRecorderIsInited);
    return TextButton(
        onPressed: () {
          if (_myRecorderIsInited) {
            !_isRecording ? record().then((value) {
              setState(() {
                _isRecording = true;
              });
            })
                : stopRecorder().then((value) {
              setState(() {
                _isRecording = false;
              });
            });
          }
          // setState(() {
          //   _isRecording == _isRecording ? false : true;
          // });
        },
        child: _isRecording ? const Text("Stop Recording") : const Text("Press to Record")
    );  }


  @override
  void initState() {
    super.initState();


    // CARE: openAudioSession returns a Future
    // Do not access your FlutterSoundPlayer or FlutterSoundRecorder before the completion of the Future
    openRecorder().then((value) {
      setState(() {
        _myRecorderIsInited = true;
      });
    });

    print("recorder init");
  }

  Future<void> openRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException(
          'Microphone permission is not granted');
    }

    // Get temp file
    var tempDir = await getTemporaryDirectory();
    _mPath = '${tempDir.path}/TEST_FILE.aac';

    _myRecorder!.openAudioSession().then((value) {
      setState(() {
        _myRecorderIsInited = true;
      });
    });
  }

  @override
  void dispose() {
    _myRecorder!.closeAudioSession();
    _myRecorder = null;
    super.dispose();
    print("recorder dispose");

  }

  Future<void> record() async {
    await _myRecorder!.startRecorder(
      toFile: _mPath,
      codec: _mCodec,
    ).then((value) {
      print("currently recording!!");
    });
  }

  Future<void> stopRecorder() async {
    await _myRecorder!.stopRecorder().then((value) {
      print("stopped recording!!");
    });
  }

}


//
//
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
