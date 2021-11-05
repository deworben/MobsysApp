import 'package:flutter/material.dart';
import '/screens/basic_screen.dart';
// import 'screens/recorder_screen.dart';
import 'screens/tims_main_screen.dart';

class RouteGenerator {
  final String _errorTxt = "Error";
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    // final args = settings.arguments;

    switch (settings.name) {
      case '/':
        // return MaterialPageRoute(builder: (_) => timsMainScreen());
        return MaterialPageRoute(builder: (_) => Basic_Screen());
      case '/second':
        // Validation of correct data type
        // return MaterialPageRoute(builder: (_) => Basic_Screen2());
        return MaterialPageRoute(builder: (_) => timsMainScreen());
      // if (args is String) {
      // return MaterialPageRoute(
      //   builder: (_) => RecordToStreamExample(
      //       // data: args,
      //       ),
      // );
      // }
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("errorTxt"),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
