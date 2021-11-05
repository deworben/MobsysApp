import 'package:flutter/material.dart';
import 'package:laugh_diary_v2/service/photo_getter.dart';
import '../service/firebase_service.dart';
import '../service/photo_getter.dart';
import '../controller/main_controller.dart';

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import '../widgets/inputTextWidget.dart';
import '../service/firebase_service.dart';

class Basic_Screen extends StatefulWidget {
  // Basic_Screen() : super();

  @override
  _Basic_ScreenState createState() => _Basic_ScreenState();
}

class _Basic_ScreenState extends State<Basic_Screen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _email = "";
  String _password = "";
  String _loginErrTxt = "";
  // final FBS = FirebaseService();
  // late final auth;

  @override
  void initState() {
    // auth = FBS.auth;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildFullApp(BuildContext context) {
    Widget makeBody() {
      return SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            // SizedBox(
            //   width: 28,
            // ),
            SizedBox(height: 30), // Space for the logo at top
            Container(child: Image.asset('assets/images/background.png')),
            Row(
              // Welcome text
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontFamily: 'Segoe UI',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff000000),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            // Text fields and buttons
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: 'Email'),
                      onChanged: (value) {
                        setState(() {
                          _email = value.trim();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Password'),
                      onChanged: (value) {
                        setState(() {
                          _password = value.trim();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Color(0xFF6C48AA)), //Color(0xFF6C48AA)4285f4
                            child: Container(
                              alignment: Alignment.center,
                              width: 305,
                              child: Text(
                                'Sign In',
                              ),
                            ),
                            // Text('Sign In'),
                            onPressed: () async {
                              _loginErrTxt = await siginInLogic(
                                  context, _email, _password);
                              setState(() {});
                            }),
                        // ElevatedButton(
                        //     style: ElevatedButton.styleFrom(primary: Color(0xFF4285f4)),
                        //     child: Container(
                        //       alignment: Alignment.center,
                        //       width: 100,
                        //       child: Text(
                        //         'Google Sign In',
                        //       ),
                        //     ),
                        //     // Text('Sign In'),
                        //     onPressed: () async {
                        //       await signInWGoogle();
                        //       // _loginErrTxt = await signInWGoogle();
                        //       print("finished signinwgoogle");
                        //       // }
                        //       setState(() {});
                        //     }),
                      ]),
                ],
              ),
            ),
            Text(_loginErrTxt),
          ],
        ),
      ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF543884),
        title: const Text('Laugh at laughing'),
      ),
      body: makeBody(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildFullApp(context);
  }
}
