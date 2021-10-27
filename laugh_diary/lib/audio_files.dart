import 'package:flutter/material.dart';

// Displays a list of audio files
// TODO: could wrap in a YourLibrary class
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

  // get the most recent n audio files
  void loadAudioFiles(){
    // TODO
    // append to list
    // get latest x from cache or firebase
  }

}

// Displays a single audio file, also contains audio file info
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

  // Plays the audio of the file
  void PlayAudio() {
    // audioManager.PlayAudio
  }
}
