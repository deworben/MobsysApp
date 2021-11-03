import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laugh_diary_v2/static/laugh_detection_controller.dart';
import 'objects/audio_file.dart';
import 'package:logger/logger.dart';


// Displays a list of audio files
// TODO: could wrap in a YourLibrary class
class AudioFileList extends StatefulWidget {
  const AudioFileList({Key? key}) : super(key: key);


  @override
  _AudioFileListState createState() => _AudioFileListState();
}

class _AudioFileListState extends State<AudioFileList> {
  // List<AudioFile> audioFiles = [];
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AudioFile>>(
        valueListenable: LaughDetectionController.audioFiles,
        builder: (BuildContext context, List<AudioFile> _audioFiles, Widget? child) {
          logger.e("UPDATING AUDIOFILE LIST");
          return Column(
            children: [
              AppBar(
                title: const Text("Gallery"),
              ),
              Expanded(
                  child: ListView(
                    children: List<AudioFileListElement>.generate(
                        _audioFiles.length,
                            (i) => AudioFileListElement(
                              _audioFiles[i],
                        )),
                    shrinkWrap: true,
                  ))
            ],
          );
        });
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
    LaughDetectionController.audioFiles.value = List<AudioFile>.generate(
        10,
        (i) => AudioFile(
          "audioFile$i",
          DateTime(2017, 9, 7, 17, i * 5),
          Duration(seconds: i * 3),
          "DUMMY"
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
  // bool _isPlaying = false;

  Color textColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AudioFile?>(
      valueListenable: LaughDetectionController.currAudioFile,
      builder: (BuildContext context, AudioFile? _audioFile, Widget? child) {
        // the clicked audio file should play
        var _isPlaying = widget.audioFile == _audioFile;
        return Card(
            child: ListTile(
                leading: FlutterLogo(),
                title: Text(
                  widget.audioFile.filePath + " " + widget.audioFile.content,
                  style: TextStyle(color: _isPlaying ? Colors.red : Colors.black),
                ),
                subtitle: Text(DateFormat.yMMMd().format(widget.audioFile.date) +
                    "  " +
                    widget.audioFile.duration.toString().substring(2, 7)),
                onTap: () {
                  setState(() {
                    LaughDetectionController.playAudioFile(widget.audioFile);
                  });
                  },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: !widget.audioFile.favourite ? Icon(Icons.favorite_border) : Icon(Icons.favorite),
                      onPressed: () {
                        setState(() {
                          widget.audioFile.favourite = !widget.audioFile.favourite;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        showModalBottomSheet(context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                return Wrap(children: [
                                  ListTile(
                                    leading: !widget.audioFile.favourite ? Icon(Icons.favorite_border) : Icon(Icons.favorite),
                                    title: !widget.audioFile.favourite ? Text("Add to Favourites",) : Text("Remove from Favourites",),
                                    tileColor: Colors.green,
                                    onTap: () {
                                      setState(() {
                                        widget.audioFile.favourite = !widget.audioFile.favourite;
                                      });
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.drive_file_rename_outline),
                                    title: Text("Rename",),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text("Delete",),
                                  ),
                                ]);
                              }
                            );
                        });
                        },
                    ),
                  ],
                )
            )
        );
      });
  }

  // Plays the audio of the file
  void PlayAudio() {
    // audioManager.PlayAudio
  }
}
