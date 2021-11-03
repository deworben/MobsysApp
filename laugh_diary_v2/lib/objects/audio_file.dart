import 'package:flutter/material.dart';

class AudioFile {
  String filePath;

  DateTime date;

  Duration duration;

  String content;

  bool favourite = false;

  String? coverImageUrl = "https://www.pinclipart.com/picdir/big/116-1169283_crying-laughing-emoji-clipart-face-with-tears-of.png";

  AudioFile(this.filePath, this.date, this.duration, this.content) {

  }

  // void setImage(String imageUrl) {
  //   coverImage = Image.network(imageUrl);
  // }
}