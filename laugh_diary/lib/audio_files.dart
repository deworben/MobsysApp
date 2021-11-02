import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laugh_diary/static/laugh_detection_controller.dart';
import 'objects/audio_file.dart';

// Displays a list of audio files
// TODO: could wrap in a YourLibrary class
class AudioFileList extends StatefulWidget {
  const AudioFileList({Key? key}) : super(key: key);

  @override
  _AudioFileListState createState() => _AudioFileListState();
}

class _AudioFileListState extends State<AudioFileList> {
  List<AudioFile> audioFiles = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text("Your Library"),
        ),
        Expanded(
            child: ListView(
          children: List<AudioFileListElement>.generate(
              audioFiles.length,
              (i) => AudioFileListElement(
                    audioFiles[i],
                  )),
        ))
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    // load a list of audio files
    loadAudioFiles();
  }

  // get the most recent n audio files
  void loadAudioFiles() {
    // make 20 audioFiles
    audioFiles = List<AudioFile>.generate(
        10,
        (i) => AudioFile(
              "audioFile$i",
              DateTime(2017, 9, 7, 17, i * 5),
              Duration(seconds: i * 3),
            ));

    // TODO
    // append to list
    // get latest x from cache or firebase
  }
}

// Displays a single audio file, also contains audio file info
class AudioFileListElement extends StatefulWidget {
  AudioFile audioFile;

  AudioFileListElement(this.audioFile) {}

  @override
  State<AudioFileListElement> createState() => _AudioFileListElementState();
}

class _AudioFileListElementState extends State<AudioFileListElement> {
  bool _isPlaying = false;

  Color textColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AudioFile?>(
        valueListenable: LaughDetectionController.currAudioFile,
        builder: (BuildContext context, AudioFile? _audioFile, Widget? child) {
          // the clicked audio file should play
          _isPlaying = widget.audioFile == _audioFile;
          return Card(
              child: ListTile(
                leading: FlutterLogo(),
                title: Text(
                  widget.audioFile.filePath,
                  style: TextStyle(color: _isPlaying ? Colors.red : Colors.black),
                ),
                subtitle: Text(DateFormat.yMMMd().format(widget.audioFile.date) +
                    "  " +
                    widget.audioFile.duration.toString().substring(2, 7)),
                onTap: () {
                  setState(() {
                    // isPlaying = !isPlaying;
                    if (!_isPlaying) {
                      LaughDetectionController.playAudioFile(widget.audioFile);
                    }
                  });
                },
          ));
        });
  }

  // Plays the audio of the file
  void PlayAudio() {
    // audioManager.PlayAudio
  }
}
