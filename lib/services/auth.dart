import 'dart:async';

import 'package:easy_localization/public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:tn/util/user.dart';


enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class Auth {

  static Future<String> signIn(String email, String password) async {
    AuthResult user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return user.user.uid;
  }

  static Future<FirebaseUser> signInWithFacebok(String accessToken) async {
    final AuthCredential credential = FacebookAuthProvider.getCredential(
      accessToken: accessToken,
    );

    final AuthResult user = await FirebaseAuth.instance.signInWithCredential(credential);
    return user.user;

  }
  static Future<String> signInWithGoogle(String accessToken) async {
    GoogleSignInAccount googleUser = await GoogleSignIn.games().signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken:accessToken,
          idToken: googleAuth.idToken,
        );
        final AuthResult user = await FirebaseAuth.instance.signInWithCredential(credential);
        return user.user.uid;

  }

  static Future<String> signUp(String email, String password) async {
    AuthResult user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return user.user.uid;
  }

  static Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }

  static Future<FirebaseUser> getCurrentFirebaseUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user;
  }

  static Future<void> addUser(User user) async {
    print("user ${user.firstName} ${user.email} exists");
    await checkUserExist(user.userID).then((value) async {
      if (!value) {
        print("user ${user.firstName} ${user.email} added");
        Firestore.instance.collection('users')
            .document("${user.userID}")
            .setData(user.toJson());
            } else {
        print("user ${user.firstName} ${user.email} exists");
      }
    });
  }


  // ignore: missing_return
   static Future updateProfilePic(picUrl) async {
    var userInfo=new UserUpdateInfo();
    userInfo.photoUrl=picUrl;
   await FirebaseAuth.instance.currentUser().then((val){
      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance.collection( '/users' )
            .where( 'userID', isEqualTo: user.uid )
            .getDocuments()
            .then( (doc) =>
            Firestore.instance.document( '/users/${user.uid}' )
                .updateData( {
              'profilePictureURL': picUrl,

                } )
                .then( (val) {

              print( 'update' );

            } )
                .catchError( (e) => print( e ) )
        ).catchError( (e) => print( e ) );
      }).catchError((e)=>print(e));

      }).catchError((e)=>print(e));

    }



  static Future<bool> checkUserExist(String userID) async {
    bool exists = false;
    try {
      await Firestore.instance.document("users/$userID").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  static Stream<User> getUser(String userID) {
    return Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: userID)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.documents.map((doc) {
        return User.fromDocument(doc);
      }).first;
    });
  }

  static String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return tr('usernot');
          break;
        case 'The password is invalid or the user does not have a password.':
          return tr('passwordinc');
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return tr('noconnc');
          break;
        case 'The email address is already in use by another account.':
          return tr('emailtaken');
          break;
        default:
          return tr('errinc');
      }
    } else {
      return tr('errinc');
    }
  }


}