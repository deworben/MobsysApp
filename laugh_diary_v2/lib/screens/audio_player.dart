import 'package:flutter/material.dart';
import 'package:laugh_diary_v2/screens/audio_files.dart';
import '../objects/audio_file.dart';
import '../static/laugh_detection_controller.dart';
import 'package:flutter_sound/flutter_sound.dart';


class AudioPlayer extends StatefulWidget {
  const AudioPlayer({Key? key}) : super(key: key);

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  AudioFile? _audioFile;

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
                return _isMinimised ? bottomBarView() : fullScreenView();
              });
        });
  }

  Widget bottomBarView() {
    return Container(
      // shape: CircularNotchedRectangle(),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: GestureDetector(
                onTap: () {setState(() {_isMinimised = false;});},
                child: Row(
                  children: [
                    FlutterLogo(),
                    _audioFile != null
                        ? Text(_audioFile!.name)
                        : const Text("Nothing playing"),
                  ],
                ),
                behavior: HitTestBehavior.translucent,
              ),
              height: 40,
            ),
          ),
          Container(
            child: playPauseButton(),
            height: 40,
          ),
        ],
      ),
      // color: Colors.blue,
      decoration:  BoxDecoration(
        color: Colors.red,
        border: Border.all(
          color: Colors.red,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }

  // TODO: cover bottom app bar?
  Widget fullScreenView() {
    return Container(
      child: Column(
        children: [
          AppBar(
              leading: IconButton(
            onPressed: () {
              setState(() {
                _isMinimised = true;
              });
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          )),
          Expanded(
              child: Column(
            children: [
              LaughDetectionController.currAudioFile.value != null
                  ? Text(
                      "Currently playing:" + _audioFile!.name,
                      textAlign: TextAlign.center,
                    )
                  : const Text("Nothing playing", textAlign: TextAlign.center),
              Row(
                children: [
                  playPauseButton(60),
                  nextButton(),
                ],
              ),

              scrubber(),
              Row(
                  children: [
                    coverPhoto(),
                    transcript(),
                  ],
                  mainAxisAlignment : MainAxisAlignment.center
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )),
        ],
      ),
      // TODO: change colour to nice gradient
      color: Colors.blue,
    );
  }

  Widget scrubber() {
    return ValueListenableBuilder<PlaybackDisposition?>(
      valueListenable: LaughDetectionController.audioDisposition,
      builder: (BuildContext context, PlaybackDisposition? _audioDisposition, Widget? child)
      {
        return Slider(
          // value: _audioDisposition!.position.inMilliseconds.toDouble(),
          value: _audioDisposition!=null ? _audioDisposition.position.inMilliseconds.toDouble() : 0.0,
          min: 0.0,
          // max: _audioDisposition!.duration.inMilliseconds.toDouble(),
          max: _audioDisposition!=null ? _audioDisposition.duration.inMilliseconds.toDouble() : 1000.0,
          onChanged: (d) async {
            // seek
            await LaughDetectionController.seek(d);
            setState(() {});
            },
          activeColor: Colors.white,
          inactiveColor: Colors.white24,
        );
      }
      );
  }

  Widget transcript() {
    if (_audioFile != null) {
      return Container(
        child: Text("Transcript: " + (_audioFile!.content),
            style: TextStyle(fontSize: 15)),
      );
    }
    else {
      // return empty widget
      return SizedBox.shrink();
    }
  }

  Widget coverPhoto() {
    if (_audioFile != null) {
      return Container(
        child: FlutterLogo(),
      );
    }
    else {
      // return empty widget
      return SizedBox.shrink();
    }
  }

  Widget playPauseButton([double? size]) {
    return IconButton(
      onPressed: () {
        playPauseButtonPressed();
      },
      icon: LaughDetectionController.isPlaying.value
          ? Icon(
              Icons.pause_circle_filled,
              size: size,
            )
          : Icon(
              Icons.play_arrow,
              size: size,
            ),
    );
  }

  Widget nextButton() {
    return IconButton(
        onPressed: () {
          LaughDetectionController.skipNextAudioFile();
        },
        icon: Icon(
          Icons.skip_next,
          size: 30,
        ),
    );
  }

  void playPauseButtonPressed() {
    setState(() {
      LaughDetectionController.audioPlayPausePressed();
    });
  }
}
