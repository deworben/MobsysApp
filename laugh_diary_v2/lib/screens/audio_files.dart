import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laugh_diary_v2/service/firebase_service.dart';
import 'package:laugh_diary_v2/static/laugh_detection_controller.dart';
import '../objects/audio_file.dart';
import 'package:logger/logger.dart';
import '../service/photo_getter.dart';

// Displays a list of audio files
// TODO: could wrap in a YourLibrary class
class AudioFileList extends StatefulWidget {
  const AudioFileList({Key? key}) : super(key: key);

  @override
  _AudioFileListState createState() => _AudioFileListState();
}

class _AudioFileListState extends State<AudioFileList> {
  List<AudioFile> _filteredFiles = [];
  var logger = Logger();
  FirebaseService fbService = FirebaseService();

  SortBy _currSortBy = SortBy.all;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AudioFile>>(
        valueListenable: LaughDetectionController.sortedAudioFiles,
        builder: (BuildContext context, List<AudioFile> _filteredFiles,
            Widget? child) {
          this._filteredFiles = _filteredFiles;
          logger.e("UPDATING AUDIOFILE LIST");
          return Column(
            children: [
              AppBar(
                backgroundColor: Color(0xFF543884),
                title: const Text("Gallery"),
              ),
              Card(
                margin: const EdgeInsets.only(
                    left: 10, top: 10, right: 10, bottom: 10),
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: DropdownButton<SortBy>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(10),
                    value: _currSortBy,
                    icon: const Icon(Icons.sort),
                    underline: Container(
                      height: 1,
                      color: Colors.black,
                    ),
                    onChanged: (SortBy? value) {
                      setState(() {
                        _currSortBy = value!;
                        // filter the audio file list
                        LaughDetectionController.sortAudioList(_currSortBy);
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: SortBy.all, child: Text("All")),
                      DropdownMenuItem(
                          value: SortBy.favourites, child: Text("Favourites")),
                      DropdownMenuItem(value: SortBy.name, child: Text("Name")),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                  children: createListElements(),
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
  Future loadAudioFiles() async {
    LaughDetectionController.audioFiles.value = await fbService.listFiles();
    LaughDetectionController.sortAudioList(_currSortBy);
    // setState(() { });

    // make 20 audioFiles
    // LaughDetectionController.audioFiles.value = List<AudioFile>.generate(
    //     10,
    //     (i) => AudioFile(
    //       "$i",
    //       DateTime(2017, 9, 7, 17, i * 5),
    //       Duration(seconds: i * 3),
    //       "DUMMY",
    //       "audioFile$i"
    //         ));
    // LaughDetectionController.sortAudioList(SortBy.all);
    // TODO
    // append to list
    // get latest x from cache or firebase
  }

  List<AudioFileListElement> createListElements() {
    return _filteredFiles.map((f) => AudioFileListElement(f)).toList();
  }
}

// Displays a single audio file, also contains audio file info
class AudioFileListElement extends StatefulWidget {
  AudioFile audioFile;
  var logger = Logger();

  AudioFileListElement(this.audioFile) {}

  @override
  State<AudioFileListElement> createState() => _AudioFileListElementState();
}

class _AudioFileListElementState extends State<AudioFileListElement> {
  Color textColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AudioFile?>(
        valueListenable: LaughDetectionController.currAudioFile,
        builder: (BuildContext context, AudioFile? _audioFile, Widget? child) {
          // the clicked audio file should play
          var _isPlaying = (_audioFile != null)
              ? widget.audioFile.id == _audioFile.id
              : false;
          return Card(
              margin:
                  const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
              child: Column(
                children: [
                  ListTile(
                      // leading: const Icon(Icons.graphic_eq),
                      leading: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 5),
                          child: photoGetter(widget.audioFile.content)),
                      // title: Text(
                      //   widget.audioFile.name,
                      //   style: TextStyle(color: Colors.black),
                      // ),
                      title: _isPlaying
                          ? Row(
                              children: [
                                Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Color(0xFFCB1B45),
                                  size: 25,
                                ),
                                Text(" Now Playing",
                                    style: TextStyle(color: Color(0xFFCB1B45))),
                              ],
                            )
                          : Text(
                              DateFormat.yMMMd().format(widget.audioFile.date) +
                                  "  " +
                                  (widget.audioFile.duration == null
                                      ? ""
                                      : (widget.audioFile.duration!.inSeconds
                                              .toString()) +
                                          " sec")),
                      onTap: () {
                        setState(() {
                          LaughDetectionController.playAudioFile(
                              widget.audioFile);
                        });
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: !widget.audioFile.favourite
                                ? const Icon(Icons.favorite_border)
                                : const Icon(Icons.favorite,
                                    color: Color(0xFFCB1B45)),
                            onPressed: () {
                              setState(() {
                                widget.audioFile.favourite =
                                    !widget.audioFile.favourite;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useRootNavigator: true,
                                  builder: (context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter updateSelf) {
                                      return Wrap(children: [
                                        ListTile(
                                          leading: !widget.audioFile.favourite
                                              ? const Icon(
                                                  Icons.favorite_border)
                                              : const Icon(Icons.favorite),
                                          title: !widget.audioFile.favourite
                                              ? const Text(
                                                  "Add to Favourites",
                                                )
                                              : const Text(
                                                  "Remove from Favourites",
                                                ),
                                          tileColor: Colors.green,
                                          onTap: () {
                                            // update parent widget
                                            setState(() {
                                              widget.audioFile.favourite =
                                                  !widget.audioFile.favourite;
                                            });
                                            // update stateful builder in ModelBottomSheet
                                            updateSelf(() {});
                                          },
                                        ),
                                      ]);
                                    });
                                  });
                            },
                          ),
                        ],
                      )),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(
                        left: 16, top: 10, right: 16, bottom: 10),
                    child: Text(widget.audioFile.content == ""
                        ? "Transcript not available."
                        : widget.audioFile.content),
                  )
                ],
              ));
        });
  }

  Widget setNameDialog(context) {
    String valueText = widget.audioFile.name;
    return AlertDialog(
      title: Text("AudioFile Name"),
      content: TextFormField(
        onChanged: (value) {
          valueText = value;
        },
        initialValue: widget.audioFile.name,
        decoration: InputDecoration(hintText: "Enter name here"),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          },
        ),
        TextButton(
          child: Text("Accept"),
          onPressed: () {
            widget.audioFile.name = valueText;
            setState(() {
              Navigator.pop(context);
            });
          },
        ),
      ],
    );
  }
}
