import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laugh Diary',
      home: Scaffold(
        appBar: AppBar(
          title: const Text("press the button"),
        ),
        body: Center(
          child: RecordButton(),      // use the RecordButton widget
        ),
        backgroundColor: Colors.black,
    ),
      color: Colors.red,    // TODO: this doesn't work for some reason
    );
  }
}

//
class RecordButton extends StatefulWidget {
  const RecordButton({Key? key}) : super(key: key);

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

// The button will change state depending on _recording
class _RecordButtonState extends State<RecordButton> {
  bool _recording = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          setState(() {
            _recording = _recording ? false : true;
          });
        },
        child: _recording ? const Text("Stop Recording") : const Text("Press to Record")
    );
  }
}



// CODE FROM THE TUTORIAL
//
// class RandomWords extends StatefulWidget {
//   const RandomWords({Key? key}) : super(key: key);
//
//   @override
//   _RandomWordsState createState() => _RandomWordsState();
// }
//
// class _RandomWordsState extends State<RandomWords> {
//   final _suggestions = <WordPair>[];
//   final _biggerFont = const TextStyle(fontSize: 18.0);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("startup name generator"),
//       ),
//       body: _buildSuggestions(),
//     );
//   }
//
//   Widget _buildSuggestions() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16.0),
//       itemBuilder: (context, i) {
//         if (i.isOdd) return const Divider();
//         final index = i ~/ 2;
//         if (index >= _suggestions.length) {
//           _suggestions.addAll(generateWordPairs().take(10));
//         }
//         return _buildRow(_suggestions[index]);
//     }
//     );
//   }
//
//   Widget _buildRow(WordPair pair) {
//     return ListTile(
//       title: Text(
//         pair.asPascalCase,
//         style: _biggerFont,
//       ),
//     );
//   }
// }
