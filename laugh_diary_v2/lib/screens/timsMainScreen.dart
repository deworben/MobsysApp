import 'package:flutter/material.dart';
import '../route_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_recorder.dart';
import 'package:flutter_cache_manager_firebase/flutter_cache_manager_firebase.dart';
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
              child:
              IndexedStack(
                index: _selectedIndex,
                children: _pages,      // use the RecordButton widget
              ),
              margin: const EdgeInsets.only(bottom: 45),
            ),
            AudioPlayer(),
          ],
          // mainAxisAlignment: MainAxisAlignment.end,
          alignment: AlignmentDirectional.bottomStart,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        ),
        backgroundColor: Colors.yellow,
        bottomNavigationBar: bottomBar(),
      ),
    );
  }

  //https://blog.logrocket.com/how-to-build-a-bottom-navigation-bar-in-flutter/
  // Bottom bar and functionality
  Widget bottomBar() {
    return BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        elevation: 8.0,
        iconSize: 24,
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Record",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Your Library",
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
        }
    );
  }

}


