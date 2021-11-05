import 'package:flutter/material.dart';

class AudioFile {
  String name = "";

  String id = "";

  DateTime date;

  Duration? duration;

  String content;

  bool favourite = false;

  String? coverImageUrl =
      "https://www.pinclipart.com/picdir/big/116-1169283_crying-laughing-emoji-clipart-face-with-tears-of.png";

  String? filePath;

  AudioFile(this.id, this.date, this.duration, this.content, [this.filePath]) {
    name = id;
  }

  // @override
  // bool operator ==(other) {
  //   return (other is AudioFile)
  //       && other.id == id;
  // }

  static AudioFile clone(AudioFile other) {
    AudioFile a = AudioFile(other.id, other.date, other.duration, other.content, other.filePath);
    a.favourite = other.favourite;
    a.coverImageUrl = other.coverImageUrl;
    a.name = other.name;
    return a;
  }

  void setName(String name) {
    this.name = name;
  }
}

enum SortBy {
  all,
  favourites,
  name,
  durationAsc,
  durationDesc,
  dateNew,
  dateOld,
}
