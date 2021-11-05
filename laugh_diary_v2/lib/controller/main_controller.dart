import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

Future<String> siginInLogic(
    BuildContext context, String email, String password) async {
  // firebase_core.FirebaseApp initialization =
  //     await firebase_core.Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;

  try {
    await auth.signInWithEmailAndPassword(email: email, password: password);
    print("singing in with user = $email and password = $password");
    // setState(() {
    //   login_err_txt = "";
    // });

    Navigator.of(context).pushNamed('/second');
    // } on Exception catch (exception) {
    //   ... // only executed if error is of type Exception
    return "";
  } catch (error) {
    // setState(() {
    //   login_err_txt = "There was an error logging in";
    // });
    return "ERROR: Logging in.";
  }
}

// void signInWGoogle() async {
// // Future<String> signInWGoogle() async {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   try {
//     final GoogleSignInAccount? googleSignInAccount =
//         await _googleSignIn.signIn();
//     final GoogleSignInAuthentication googleSignInAuthentication =
//         await googleSignInAccount!.authentication;
//     final AuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleSignInAuthentication.accessToken,
//       idToken: googleSignInAuthentication.idToken,
//     );
//     await _auth.signInWithCredential(credential);
//     // return "";
//   } on FirebaseAuthException catch (e) {
//     print(e.message);
//     // throw e;
//     // return e.toString();
//   }
// }

Future<String?> signInWGoogle() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    await _auth.signInWithCredential(credential);
  } on FirebaseAuthException catch (e) {
    print(e.message);
    throw e;
  }
}
