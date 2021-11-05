import 'package:flutter/material.dart';
import 'audio_recorder.dart';
import 'audio_files.dart';
import 'audio_player.dart';
import 'dashboard.dart';

class timsMainScreen extends StatefulWidget {
  @override
  _timsMainScreenState createState() => _timsMainScreenState();

  //State<_timsMainScreen> createState() => _timsMainScreen();
}

//class _MyAppState extends State<MyApp> {
class _timsMainScreenState extends State<timsMainScreen> {
  //TODO: save int to cache to save state when closing app
  // Current open page
  int _selectedIndex = 0;

  // List of pages
  static const List<Widget> _pages = <Widget>[
    AudioRecorder(),
    AudioFileList(),
    Dashboard(),
  ];

  // Template build function
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laugh Diary',
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages, // use the RecordButton widget
              ),
              margin: const EdgeInsets.only(bottom: 65),
            ),
            const AudioPlayer(),
          ],
          // mainAxisAlignment: MainAxisAlignment.end,
          alignment: AlignmentDirectional.bottomStart,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        bottomNavigationBar: bottomBar(),
      ),
    );
  }

  //https://blog.logrocket.com/how-to-build-a-bottom-navigation-bar-in-flutter/
  // Bottom bar and functionality
  Widget bottomBar() {
    return BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        elevation: 8.0,
        iconSize: 24,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: "Record",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark_rounded),
            label: "Gallery",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        });
  }
}
