import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laugh_diary_v2/static/laugh_detection_controller.dart';
import '../objects/audio_file.dart';
import 'package:logger/logger.dart';


// Displays a list of audio files
// TODO: could wrap in a YourLibrary class
class AudioFileList extends StatefulWidget {
  const AudioFileList({Key? key}) : super(key: key);


  @override
  _AudioFileListState createState() => _AudioFileListState();
}

class _AudioFileListState extends State<AudioFileList> {
  List<AudioFile> _audioFiles = [];
  var logger = Logger();

  SortBy _value = SortBy.all;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AudioFile>>(
        valueListenable: LaughDetectionController.audioFiles,
        builder: (BuildContext context, List<AudioFile> _audioFiles, Widget? child) {
          this._audioFiles = _audioFiles;
          logger.e("UPDATING AUDIOFILE LIST");
          return Column(
            children: [
              AppBar(
                title: const Text("Gallery"),

              ),

              Container(
                child: DropdownButton<SortBy>(
                  value: _value,
                  icon: Icon(Icons.arrow_drop_down_sharp),
                  underline: Container(
                    height: 2,
                    color: Colors.black,
                  ),
                  onChanged: (SortBy? value) {
                    setState(() {
                      _value = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                        value: SortBy.all,
                        child: Text("All")),
                    DropdownMenuItem(
                        value: SortBy.favourites,
                        child: Text("Favourites")),
                    DropdownMenuItem(
                        value: SortBy.name,
                        child: Text("Name")),
                  ],
                ),
              ),
              // TODO: THIS IS UPDATED!!!
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: createListElements(_value),
                )),
              )
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
          "$i",
          DateTime(2017, 9, 7, 17, i * 5),
          Duration(seconds: i * 3),
          "DUMMY",
          "audioFile$i"
            ));
    // TODO
    // append to list
    // get latest x from cache or firebase
  }

  List<AudioFileListElement> createListElements(SortBy sortBy) {
    switch(sortBy) {
      case SortBy.favourites: {
        return
          _audioFiles.where((a) => a.favourite).map((a) => AudioFileListElement(a)).toList();
      }
      case SortBy.name: {
        _audioFiles.sort((a, b) => a.id.compareTo(b.id));
        return _audioFiles.map((a) => AudioFileListElement(a)).toList();
      }
      // sort by date by default
      default: {
        _audioFiles.sort((a, b) => a.date.compareTo(b.date));
        return _audioFiles.map((a) => AudioFileListElement(a)).toList();
      }
    }
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

  TextEditingController _c = TextEditingController();



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
                  widget.audioFile.name + " " + widget.audioFile.content,
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
                                builder: (BuildContext context, StateSetter updateSelf) {
                                return Wrap(children: [
                                  ListTile(
                                    leading: !widget.audioFile.favourite ? Icon(Icons.favorite_border) : Icon(Icons.favorite),
                                    title: !widget.audioFile.favourite ? Text("Add to Favourites",) : Text("Remove from Favourites",),
                                    tileColor: Colors.green,
                                    onTap: () {
                                      // update parent widget
                                      setState(() {
                                        widget.audioFile.favourite = !widget.audioFile.favourite;
                                      });
                                      // update stateful builder in ModelBottomSheet
                                      updateSelf ((){});
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.drive_file_rename_outline),
                                    title: Text("Rename",),
                                    onTap: () {
                                      showDialog(context: context, builder:
                                      (context) {
                                        return setNameDialog();
                                      });
                                      setState(() {});
                                    },
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

  Widget setNameDialog() {
    String valueText = widget.audioFile.name;
    return AlertDialog(
      title: Text("AudioFile Name"),
      content: TextFormField(
        onChanged: (value) {valueText = value;},
        initialValue: widget.audioFile.name,
        // controller: _c,
        decoration: InputDecoration(hintText: "Enter name here"),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {setState(() {Navigator.pop(context);});},),
        TextButton(
          child: Text("Accept"),
          onPressed: () {
            widget.audioFile.name = valueText;
            setState(() {
              Navigator.pop(context);
            });
          },),
      ],
    );
  }
}
