import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';

class Basic_Screen3 extends StatefulWidget {
  @override
  _Basic_Screen3State createState() => _Basic_Screen3State();
}

class _Basic_Screen3State extends State<Basic_Screen3> {
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
              Text('Whassup were screen 2'),
            ]),
          ),
          // ElevatedButton(
          //   child: Text('Go fly away'),
          //   onPressed: () {
          //     // Pushing a named route
          //     Navigator.of(context).pushNamed('/second'
          //         // arguments: 'Hello there from the first page!',
          //         );
          //   },
          // )
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
