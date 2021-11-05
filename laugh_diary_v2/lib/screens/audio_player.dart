import 'package:flutter/material.dart';
import 'package:laugh_diary_v2/screens/audio_files.dart';
import '../objects/audio_file.dart';
import '../static/laugh_detection_controller.dart';
import '../service/photo_getter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:math';

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

                return bottomBarView(context);
                // return _isMinimised ? bottomBarView(context) : fullScreenView(context);
              });
        });
  }

  Widget bottomBarView(context) {
    return Container(
      // color: Colors.black,
        padding: EdgeInsets.only(left: 0, right: 0, bottom: 0.0),
        child: Container(
          // shape: CircularNotchedRectangle(),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMinimised = false;

                        // Navigator.push(context,
                        //     MaterialPageRoute(
                        //         builder:
                        //     ));

                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            builder: (context) {
                              return fullScreenView(context);
                            });
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        // FlutterLogo(),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _audioFile != null
                                  ? Text(_audioFile!.content.substring(0, min(38, _audioFile!.content.length)) + (_audioFile!.content.length > 38 ? "..." : ""),
                                      style: TextStyle(
                                          color: Colors.grey[900],
                                          fontWeight: FontWeight.bold))
                                  : Text(
                                      "Nothing playing",
                                      style: TextStyle(
                                          color: Colors.grey[900],
                                          fontWeight: FontWeight.bold),
                                    ),
                              SizedBox(height: 5),
                              Text("Select a laugh in gallery to play.",
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    behavior: HitTestBehavior.translucent,
                  ),
                  height: 60,
                ),
              ),
              Container(
                child: playPauseButton(),
                height: 40,
              ),
            ],
          ),
          // color: Colors.blue,
          decoration: BoxDecoration(
            color: Color(0xFFCB92FF),// Theme.of(context).colorScheme.secondary,
            // color: Colors.white,
            border: Border.all(
              color: Colors.white30,
            ),
            // borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ));
  }

  // TODO: cover bottom app bar?
  Widget fullScreenView(context) {
    return ValueListenableBuilder<AudioFile?>(
        valueListenable: LaughDetectionController.currAudioFile,
        builder: (BuildContext context, AudioFile? _audioFile, Widget? child) {
          this._audioFile = _audioFile;
          return ValueListenableBuilder<bool>(
              valueListenable: LaughDetectionController.isPlaying,
              builder: (BuildContext context, bool _isPlaying, Widget? child) {
                this._isPlaying = _isPlaying;

                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter updateSelf) {
                  return Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFCB92FF),
                            Colors.white,
                          ],
                        )
                    ),
                    child: Column(
                      children: [

                        Container(
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.black87,
                            ),
                          ),
                          padding: EdgeInsets.only(top: 40.0),
                        ),

                        Container(
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.only(top: 0.0),
                            child: Expanded(
                                child: Column(
                              children: [
                                SizedBox(height: 40),
                                topIconRow(),
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                        // color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          children: [

                                            SizedBox(height: 10),

                                            Divider(
                                              color: Color(0xFF543884),
                                              // color: Colors.black,
                                              thickness: 2,
                                              indent: 10,
                                              endIndent: 10,
                                            ),

                                            SizedBox(height: 0),


                                            descriptorTextRow(),

                                            SizedBox(height: 15),

                                            forwardBackPlay(updateSelf),
                                            scrubber(),

                                            SizedBox(height: 25),

                                            transcript(),

                                            SizedBox(height: 10),
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ))),
                      ],
                    ),
                  );
                });
              });
        });
  }

  Widget forwardBackPlay(StateSetter updateSelf) {
    return SizedBox(
        height: 80,
        child: Container(
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(
                    width: 70,
                    height: 70,
                    child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 0.0),
                        child: IconButton(
                          onPressed: () {
                            LaughDetectionController.skipPrevAudioFile();
                          },
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            size: 30,
                          ),
                        ))),

                SizedBox(width: 35),

                // play/pause icon button
                SizedBox(
                  height: 70,
                    child: Container(
                      width: 70,
                      height: 70,
                      child: IconButton(
                        onPressed: () {
                          playPauseButtonPressed();
                          updateSelf(() {});
                          setState(() {});
                        },
                        icon: LaughDetectionController.isPlaying.value
                            ? Icon(
                          Icons.pause_circle_filled,
                          size: 60,
                        )
                            : Icon(
                          Icons.play_circle_fill_rounded,
                          size: 60,
                        ),
                      ),
                    ),

                ),

                SizedBox(width: 35),
                // play next icon button
                SizedBox(
                    width: 70,
                    height: 70,
                    child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 0.0),
                        child: IconButton(
                          onPressed: () {
                            LaughDetectionController.skipNextAudioFile();
                          },
                          icon: Icon(
                            Icons.skip_next_rounded,
                            size: 30,
                          ),
                        ))),
              ],
            )));
  }

  Widget topIconRow() {
    // return LaughDetectionController.currAudioFile.value != null
    //     ? Text(
    //         "Currently playing:" + _audioFile!.name,
    //         textAlign: TextAlign.center,
    //       )
    //     : const Text("Nothing playing", textAlign: TextAlign.center);
    return Container(
      alignment: Alignment.bottomCenter,
      // padding: EdgeInsets.only(top: 100.0),
      width: 200,
      height: 200,
      child: photoGetter(
          "TODO:FIXME - put in current audio files transcript/content"),
    );
  }

  Widget descriptorTextRow() {
    // return Text("hey");
    return Row(
      children: [
        Container(
          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("",
                  style: TextStyle(
                      color: Colors.grey[800],
                      // fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ],
          ),
        )
      ],
    );
  }

  Widget scrubber() {
    return ValueListenableBuilder<PlaybackDisposition?>(
        valueListenable: LaughDetectionController.audioDisposition,
        builder: (BuildContext context, PlaybackDisposition? _audioDisposition,
            Widget? child) {
          return Slider(
            // value: _audioDisposition!.position.inMilliseconds.toDouble(),
            value: _audioDisposition != null
                ? _audioDisposition.position.inMilliseconds.toDouble()
                : 0.0,
            min: 0.0,
            // max: _audioDisposition!.duration.inMilliseconds.toDouble(),
            max: _audioDisposition != null
                ? _audioDisposition.duration.inMilliseconds.toDouble()
                : 1000.0,
            onChanged: (d) async {
              // seek
              await LaughDetectionController.seek(d);
              if (_audioDisposition != null) {
                // update value
                LaughDetectionController.audioDisposition.value =
                    PlaybackDisposition(
                        position: Duration(milliseconds: d.floor()),
                        duration: _audioDisposition.duration);
              }
              setState(() {});
            },

            // activeColor: Color(0xFFCB92FF),
            activeColor: Color(0xFF543884),
            // activeColor: Colors.grey,
            inactiveColor: Colors.black12,
          );
        });
  }

  Widget transcript() {

    return Container(
      child: Column(
        children: [
          Container(
            child: Text("TRANSCRIPT",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[800]
              ),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 0, right: 0, bottom: 0.0),
          ),

          SizedBox(height: 20),

          Container(
            child: Text(
              _audioFile != null ? _audioFile!.content : "...no transcript available :(",
                style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            padding: EdgeInsets.only(left: 35, right: 35),
          )
        ],
      ),
    );

  }

  Widget coverPhoto() {
    if (_audioFile != null) {
      return Container(
        child: FlutterLogo(),
      );
    } else {
      // return empty widget
      return SizedBox.shrink();
    }
  }

  Widget playPauseButton([double? size]) {
    return IconButton(
      onPressed: () {
        playPauseButtonPressed();
        setState(() {});
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

  // Widget nextButton() {
  //   return IconButton(
  //     onPressed: () {
  //       LaughDetectionController.skipNextAudioFile();
  //     },
  //     icon: Icon(
  //       Icons.skip_next,
  //       size: 30,
  //     ),
  //   );
  // }

  // Widget prevButton() {
  //   return IconButton(
  //     onPressed: () {
  //       LaughDetectionController.skipPrevAudioFile();
  //     },
  //     icon: Icon(
  //       Icons.skip_previous,
  //       size: 30,
  //     ),
  //   );
  // }

  Future<void> playPauseButtonPressed() async {
    // setState(() {
    //   LaughDetectionController.audioPlayPausePressed();
    // });
    await LaughDetectionController.audioPlayPausePressed();
    setState(() {});
  }

  Future<void> prevButtonPressed() async {
    // setState(() {
    //   LaughDetectionController.audioPlayPausePressed();
    // });
    await LaughDetectionController.skipPrevAudioFile();
    setState(() {});
  }

  Future<void> nextButtonPressed() async {
    // setState(() {
    //   LaughDetectionController.audioPlayPausePressed();
    // });
    await LaughDetectionController.skipNextAudioFile();
    setState(() {});
  }
}
