import 'package:flutter/material.dart';
import '../service/firebase_service.dart';
import '../controller/main_controller.dart';
import '../service/firebase_service.dart';

class Basic_Screen extends StatefulWidget {
  @override
  _Basic_ScreenState createState() => _Basic_ScreenState();
}

class _Basic_ScreenState extends State<Basic_Screen> {
  FirebaseService _firebaseService = FirebaseService();
  String _email = "";
  String _password = "";
  String login_err_txt = "";
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
          // ElevatedButton(
          //   child: Text('Go to second'),
          //   onPressed: () {
          //     // Pushing a named route
          //     Navigator.of(context).pushNamed('/second'
          //         // arguments: 'Hello there from the first page!',
          //         );
          //   },
          // ),
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          // color: Theme.of(context).accentColor,
                          child: Text('Signin'),
                          onPressed: () async {
                            login_err_txt =
                                await siginInLogic(context, _email, _password);
                            setState(() {});
                          }),
                      ElevatedButton(
                          // color: Theme.of(context).accentColor,
                          child: Text('Signin with google'),
                          onPressed: () async {
                            await signInWGoogle();
                            // login_err_txt = await signInWGoogle();
                            print("finished signinwgoogle");
                            // }
                            setState(() {});
                          }),
                      ElevatedButton(
                          // color: Theme.of(context).accentColor,
                          child: Text('Test'),
                          onPressed: () async {
                            _firebaseService.downloadFile('/randomFile.pcm');
                            setState(() {});
                          }),

                      //   ElevatedButton(
                      //     // color: Theme.of(context).accentColor,
                      //     child: Text('Signup'),
                      //     onPressed: () {
                      //       auth
                      //           .createUserWithEmailAndPassword(
                      //               email: _email, password: _password)
                      //           .then((_) {
                      //         Navigator.of(context).pushReplacement(
                      //             MaterialPageRoute(
                      //                 // builder: (context) => HomeScreen()));
                      //                 builder: Navigator.of(context)
                      //               .pushReplacement(MaterialPageRoute(
                      //                   // builder: (context) => HomeScreen()));
                      //                   builder: (context) {
                      //             Navigator.of(context).pushNamed('/third');
                      //           }));
                      //       });
                      //     },
                      //   )
                    ])
              ],
            ),
          ),
          Text(login_err_txt),
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
