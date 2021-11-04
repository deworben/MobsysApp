import 'package:flutter/material.dart';

class AudioFile {
  String filePath;

  String name = "";

  String id = "";

  DateTime date;

  Duration duration;

  String content;

  bool favourite = false;

  String? coverImageUrl =
      "https://www.pinclipart.com/picdir/big/116-1169283_crying-laughing-emoji-clipart-face-with-tears-of.png";

  AudioFile(this.filePath, this.date, this.duration, this.content) {
    name = filePath;
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
