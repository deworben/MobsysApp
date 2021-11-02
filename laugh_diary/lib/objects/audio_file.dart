import 'package:flutter/material.dart';

class AudioFile {
  String filePath;

  DateTime date;

  Duration duration;

  Image? coverPhoto;

  AudioFile(this.filePath, this.date, this.duration, [this.coverPhoto]) {

  }
}