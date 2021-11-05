import 'package:flutter/material.dart';
import '../service/firebase_service.dart';
import '../controller/main_controller.dart';

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import '../widgets/inputTextWidget.dart';

class Basic_Screen extends StatefulWidget {
  // Basic_Screen() : super();

  @override
  _Basic_ScreenState createState() => _Basic_ScreenState();
}

// class _Basic_ScreenState extends State<Basic_Screen> {
//   final TextEditingController _pwdController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   //final snackBar = SnackBar(content: Text('email ou mot de passe incorrect'));
//   final _formKey = GlobalKey<FormState>();
//   final firebaseService = FirebaseService();
//   String _loginErrTxt = "";
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final double r = (175 / 360); //  rapport for web test(304 / 540);
//     final coverHeight = screenWidth * r;
//     bool _pinned = false;
//     bool _snap = false;
//     bool _floating = false;

//     final widgetList = [
//       Row(
//         children: [
//           SizedBox(
//             width: 28,
//           ),
//           Text(
//             'Welcome',
//             style: TextStyle(
//               fontFamily: 'Segoe UI',
//               fontSize: 40,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xff000000),
//             ),
//             textAlign: TextAlign.left,
//           ),
//         ],
//       ),
//       SizedBox(
//         height: 12.0,
//       ),
//       Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               InputTextWidget(
//                   controller: _emailController,
//                   labelText: "Email Address",
//                   icon: Icons.email,
//                   obscureText: false,
//                   keyboardType: TextInputType.emailAddress),
//               SizedBox(
//                 height: 12.0,
//               ),
//               InputTextWidget(
//                   controller: _pwdController,
//                   labelText: "Password",
//                   icon: Icons.lock,
//                   obscureText: true,
//                   keyboardType: TextInputType.text),
//               Padding(
//                 padding: const EdgeInsets.only(right: 25.0, top: 10.0),
//                 child: Align(
//                     alignment: Alignment.topRight,
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () {},
//                         child: Text(
//                           "Forgot your password?",
//                           style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[700]),
//                         ),
//                       ),
//                     )),
//               ),
//               SizedBox(
//                 height: 15.0,
//               ),
//               Container(
//                 height: 55.0,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (_formKey.currentState!.validate()) {
//                       // print("I ove tunisia");

//                     }
//                     //Get.to(ChoiceScreen());
//                   },
//                   style: ElevatedButton.styleFrom(
//                     primary: Colors.white,
//                     elevation: 0.0,
//                     minimumSize: Size(screenWidth, 150),
//                     padding: EdgeInsets.symmetric(horizontal: 30),
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(0)),
//                     ),
//                   ),
//                   child: Ink(
//                     decoration: BoxDecoration(
//                         boxShadow: <BoxShadow>[
//                           BoxShadow(
//                               color: Colors.red,
//                               offset: const Offset(1.1, 1.1),
//                               blurRadius: 10.0),
//                         ],
//                         color: Colors.red, // Color(0xffF05945),
//                         borderRadius: BorderRadius.circular(12.0)),
//                     child: Container(
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Sign In",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white, fontSize: 25),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           )),
//       SizedBox(
//         height: 15.0,
//       ),
//       Wrap(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 110, right: 0, top: 20),
//             child: Container(
//               decoration: BoxDecoration(
//                   boxShadow: <BoxShadow>[
//                     BoxShadow(
//                         color: Colors.grey, //Color(0xfff05945),
//                         offset: const Offset(0, 0),
//                         blurRadius: 5.0),
//                   ],
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12.0)),
//               width: (screenWidth / 2) - 40,
//               height: 55,
//               child: Material(
//                 borderRadius: BorderRadius.circular(12.0),
//                 child: InkWell(
//                   onTap: () async {
//                     // print("google tapped");
//                     await signInWGoogle();
//                     // _loginErrTxt = await signInWGoogle();
//                     print("finished signinwgoogle");
//                     // }
//                     setState(() {});
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Image.asset("assets/google.png", fit: BoxFit.cover),
//                         SizedBox(
//                           width: 7.0,
//                         ),
//                         Text("Sign in with \nGoogle")
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // Test the listView
//           ElevatedButton(
//             onPressed: () async {
//               var myTmp = await firebaseService.listFiles();
//             },
//             child: Text("test"),
//           ),
//         ],
//       ),
//       SizedBox(
//         height: 15.0,
//       ),
//     ];
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         // leading: Icon(Icons.arrow_back),
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//       ),
//       body: CustomScrollView(
//         slivers: <Widget>[
//           SliverAppBar(
//             pinned: _pinned,
//             snap: _snap,
//             floating: _floating,
//             expandedHeight: coverHeight - 25, //304,
//             backgroundColor: Color(0xFFFFFFFF),
//             // backgroundColor: Color(0xFFdccdb4),
//             flexibleSpace: FlexibleSpaceBar(
//               centerTitle: true,
//               background:
//                   Image.asset("assets/background.png", fit: BoxFit.scaleDown),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Container(
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.only(),
//                   gradient: LinearGradient(
//                       colors: <Color>[Color(0xFFdccdb4), Color(0xFFd8c3ab)])),
//               width: screenWidth,
//               height: 25,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: <Widget>[
//                   Container(
//                     width: screenWidth,
//                     height: 25,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: const Radius.circular(30.0),
//                         topRight: const Radius.circular(30.0),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           SliverList(
//               delegate:
//                   SliverChildBuilderDelegate((BuildContext context, int index) {
//             return widgetList[index];
//           }, childCount: widgetList.length))
//         ],
//       ),
//       bottomNavigationBar: Stack(
//         children: [
//           new Container(
//             height: 50.0,
//             color: Colors.white,
//             child: Center(
//                 child: Wrap(
//               children: [
//                 Text(
//                   "Don't have an account?",
//                   style: TextStyle(
//                       color: Colors.grey[600], fontWeight: FontWeight.bold),
//                 ),
//                 Material(
//                     child: InkWell(
//                   onTap: () async {
//                     print("sign up tapped");
//                     _loginErrTxt = await siginInLogic(
//                         context, _emailController.text, _pwdController.text);
//                     setState(() {});
//                     // Get.to(SignUpScreen());
//                   },
//                   child: Text(
//                     "Sign Up",
//                     style: TextStyle(
//                       color: Colors.blue[800],
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                     ),
//                   ),
//                 )),
//               ],
//             )),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Basic_Screen extends StatefulWidget {
//   @override
//   _Basic_ScreenState createState() => _Basic_ScreenState();
// }

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
      return Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            // SizedBox(
            //   width: 28,
            // ),
            SizedBox(height: 30), // Space for the logo at top
            Container(child: Image.asset('assets/background.png')),
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
                            // color: Theme.of(context).accentColor,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100,
                              child: Text(
                                'Sign In',
                                // style: TextStyle(
                                //   fontFamily: 'Segoe UI',
                                //   fontSize: 20,
                                //   fontWeight: FontWeight.bold,
                                //   color: const Color(0xff000000),
                                // ),
                              ),
                            ),
                            // Text('Sign In'),
                            onPressed: () async {
                              _loginErrTxt = await siginInLogic(
                                  context, _email, _password);
                              setState(() {});
                            }),
                        ElevatedButton(
                            // color: Theme.of(context).accentColor,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100,
                              child: Text(
                                'Google Sign In',
                              ),
                            ),
                            // Text('Sign In'),
                            onPressed: () async {
                              await signInWGoogle();
                              // _loginErrTxt = await signInWGoogle();
                              print("finished signinwgoogle");
                              // }
                              setState(() {});
                            }),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            // color: Theme.of(context).accentColor,
                            child: Text('Test'),
                            onPressed: () async {
                              var a = await _firebaseService.listFiles();
                              print(a);
                              // _firebaseService.downloadFile('randomFile');
                              // _firebaseService.downloadFile('/randomFile.pcm');
                              setState(() {});
                            }),
                      ])
                ],
              ),
            ),
            // Text(_loginErrTxt),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
