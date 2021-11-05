import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:lemmatizer/lemmatizer.dart';

// Return the download link for the best file, given the transcript
Image photoGetter(String transcript) {
  // Lemmatizer lemmatizer = new Lemmatizer();
  // var temp = lemmatizer.lemma("running");
  // print("summa lumma lemmatizing = ${temp}");

  Map<String, String> wordIconList = {
    "funny": "https://cdn-icons-png.flaticon.com/512/2492/2492765.png",
    "party": "https://static.thenounproject.com/png/98497-200.png",
    "camp":
        "https://www.freeiconspng.com/thumbs/camping-icon/travel-camping-tent-icon-1.png",
    "tent":
        "https://www.freeiconspng.com/thumbs/camping-icon/travel-camping-tent-icon-1.png",
    "chicken":
        "https://iconarchive.com/download/i87569/icons8/ios7/Animals-Chicken.ico",
    "beaches": "https://static.thenounproject.com/png/2839344-200.png",
  };
  String finalLink = "";

  // Split the transcript into words
  List<String> words = transcript.split(" ");
  // check if the word is a key in wordIconList. Pick the first occurance
  for (String word in words) {
    if (wordIconList.containsKey(word)) {
      finalLink = wordIconList[word]!;
      break;
    }
  }
  // print("finalLink = ${finalLink}");

  // Try download the image if exists, otherwise return default image
  Image outWidget;
  try {
    if (finalLink != "") {
      print("getting img from network");
      outWidget = Image.network(finalLink);
      print("img from network = ${outWidget}");
      return outWidget;
    }
  } catch (e) {
    print("failed collecting image = ${finalLink}");
  }

  // Return a regular laugh if in doubt
  return Image.asset("assets/images/funny.png");
}
