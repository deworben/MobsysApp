import 'package:flutter/material.dart';
import 'package:laugh_diary/audio_files.dart';
import 'objects/audio_file.dart';
import 'static/laugh_detection_controller.dart';


class AudioPlayer extends StatefulWidget {
  const AudioPlayer({Key? key}) : super(key: key);

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {

  AudioFile? _audioFile;

  // AudioFile audioFile = AudioFile("This is a filepath", DateTime(2017, 9, 7, 17, 17), Duration(seconds: 100),);

  bool _isMinimised = true;

  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AudioFile?>(
        valueListenable: LaughDetectionController.currAudioFile,
        builder: (BuildContext context, AudioFile? _audioFile, Widget? child) {
          this._audioFile = _audioFile;
          return ValueListenableBuilder<bool>(
              valueListenable: LaughDetectionController.isPlaying,
              builder: (BuildContext context, bool _isPlaying, Widget? child) {
                this._isPlaying = _isPlaying;
                return _isMinimised
                    ? bottomBarView()
                    : fullScreenView();
              });
        });
  }

  Widget fullScreenView() {
    return Container(
      child: Column(
        children: [
          AppBar(
              leading: IconButton(
                onPressed: () {setState(() {
                  _isMinimised = true;
                });},
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              )
          ),
          Expanded(
              child: Column(
                children: [
                  LaughDetectionController.currAudioFile.value!=null
                      ? Text("Currently playing:" + _audioFile!.filePath, textAlign: TextAlign.center,)
                      : const Text("Nothing playing", textAlign: TextAlign.center),
                  playPauseButton(60),
                ],
                mainAxisAlignment : MainAxisAlignment.center,
              )
          ),
        ],
      ),
      // TODO: change colour to nice gradient
      color: Colors.blue,
    );
  }

  Widget bottomBarView() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
                onTap: () {setState(() {
                  _isMinimised = false;
                });
                },
                child: Row(
                  children: [
                    _audioFile!=null
                        ? Text(_audioFile!.filePath)
                        : const Text("Nothing playing"),
                  ],
                ),
                behavior: HitTestBehavior.translucent,
              ),
          ),
          playPauseButton(),
        ],
      ),
      // TODO: fix audioPlayer height
      color: Colors.blue,
    );
  }

  Widget playPauseButton([double? size]) {
    return IconButton(
      onPressed: () {
        playPauseButtonPressed();
      },
      icon: LaughDetectionController.isPlaying.value
          ? Icon(Icons.pause_circle_filled, size: size,)
          : Icon(Icons.play_arrow, size: size,),
    );
  }
  
  void playPauseButtonPressed() {
    setState(() {
      LaughDetectionController.audioPlayPausePressed();
    });
  }

}
