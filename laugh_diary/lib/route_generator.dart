import 'package:flutter/material.dart';
import 'screens/basic_screen.dart';
import 'screens/basic_screen_2.dart';
import 'screens/basic_screen_3.dart';
import 'screens/recorder_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Basic_Screen());
      case '/second':
        // Validation of correct data type
        // return MaterialPageRoute(builder: (_) => Basic_Screen2());
        return MaterialPageRoute(builder: (_) => RecordToStreamExample());
      // if (args is String) {
      // return MaterialPageRoute(
      //   builder: (_) => RecordToStreamExample(
      //       // data: args,
      //       ),
      // );
      // }
      case '/third':
        return MaterialPageRoute(builder: (_) => RecordToStreamExample());
      // If args is not of the correct type, return an error page.
      // You can also throw an exception while in development.
      // return _errorRoute();
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
