import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:laugh_diary/static/recording_controller.dart';

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

    return ValueListenableBuilder<bool>(
        valueListenable: RecordingController.isRecording,
        builder: (BuildContext context, bool _isRecording, Widget? child) {
          this._isRecording = _isRecording;
          return Center(
              child: TextButton(
                  onPressed: () {
                    RecordingController.startStopPressed();



                    // if (_myRecorderIsInited) {
                    //   !_isRecording ? record().then((value) {
                    //     setState(() {
                    //       _isRecording = true;
                    //     });
                    //   })
                    //       : stopRecorder().then((value) {
                    //     setState(() {
                    //       _isRecording = false;
                    //     });
                    //   });
                    // }
                    // setState(() {
                    //   _isRecording == _isRecording ? false : true;
                    // });
                  },
                  child: _isRecording ? const Text("Stop Recording") : const Text("Press to Record")
              )
          );
        }
    );
   }


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
