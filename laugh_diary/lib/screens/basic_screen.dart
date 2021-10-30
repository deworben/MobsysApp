import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';

class Basic_Screen extends StatefulWidget {
  @override
  _Basic_ScreenState createState() => _Basic_ScreenState();
}

class _Basic_ScreenState extends State<Basic_Screen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildFullApp(BuildContext context) {
    Widget makeBody() {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              Text('Hello and welcome to your new page'),
            ]),
          ),
          ElevatedButton(
            child: Text('Go to second'),
            onPressed: () {
              // Pushing a named route
              Navigator.of(context).pushNamed('/second'
                  // arguments: 'Hello there from the first page!',
                  );
            },
          )
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Record to Stream ex.'),
      ),
      body: makeBody(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildFullApp(context);
  }
}
