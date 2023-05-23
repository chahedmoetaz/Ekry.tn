import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:tn/chats/chatUserslist.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tn/chats/chat_with.dart';
import 'package:tn/services/auth.dart';
import 'package:tn/util/user.dart';

class ChatPage extends StatefulWidget {
  final String userID;
  ChatPage(this.userID);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String title;
  String currentuser;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  String groupe;
  List name;
  List photo;
  String other;


  bool charge = false;
  int count=0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    name=[];
    photo=[];
    super.initState();

    registerNotification();
    configLocalNotification();


  }

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid ? showNotification(message['notification']) : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      FlutterAppBadger.removeBadge();
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      FlutterAppBadger.removeBadge();
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance.collection('users').document(widget.userID).updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: StreamBuilder<FirebaseUser>(
          stream: FirebaseAuth.instance.onAuthStateChanged,

          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return new SizedBox();
            } else {
              currentuser = snapshot.data.uid;
              if (snapshot.hasData) {
                return StreamBuilder(
                  stream: Auth.getUser(snapshot.data.uid),
                  builder:
                      (BuildContext context, AsyncSnapshot<User> snapshot) {
                    if (!snapshot.hasData||snapshot.hasError) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            Theme.of(context).accentColor,
                          ),
                        ),
                      );
                    } else {
                      return StreamBuilder(
                        stream: Firestore.instance
                            .collection("users")
                            .where('userID', isEqualTo: snapshot.data.userID)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData ||snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 28.0),
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  Align(
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset('assets/chat.png'),
                                      )),
                                  Align( alignment: Alignment.center,
                                      child: Text( tr( 'aucmes' ),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ), ) )
                                ],
                              ),
                            );
                          }
                          else if(snapshot.data==null)
                            return Padding(
                              padding: const EdgeInsets.only(top: 28.0),
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  Align(
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset('assets/chat.png'),
                                      )),
                                  Align( alignment: Alignment.center,
                                      child: Text( tr( 'aucmes' ),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ), ) )
                                ],
                              ),
                            );
                          else if(snapshot.hasData && snapshot.data.documents.length!=0) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height-50,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                  snapshot.data.documents.length,

                                  itemBuilder:
                                      (BuildContext context, int index) {

                                    count =snapshot.data.documents[index]['chattingWith']
                                        .toString()
                                        .length~/30.abs();

                                    return count==0?Padding(
                                      padding: const EdgeInsets.only(top: 28.0),
                                      child: Column(
                                        //physics: NeverScrollableScrollPhysics(),
                                        children: [
                                          Align(
                                              alignment: Alignment.topCenter,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Image.asset('assets/chat.png'),
                                              )),
                                          Align( alignment: Alignment.center,
                                              child: Text( tr( 'aucmes' ),
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ), ) )
                                        ],
                                      ),
                                    ):SizedBox(
                                      height: MediaQuery.of(context).size.height-20,
                                      child: ListView.builder(shrinkWrap: true,
                                          itemCount: count,
                                          itemBuilder: (BuildContext context, int index2) {
                                            if(snapshot.data
                                                .documents[index]['chattingWith'][index2]!=null)
                                              groupe = '${snapshot.data
                                                  .documents[index]['chattingWith'][index2]}-$currentuser';
                                            return StreamBuilder(
                                                stream: Firestore.instance
                                                    .collection( 'messages' )
                                                    .document( groupe )
                                                    .collection( groupe )
                                                    .orderBy( 'timestamp',
                                                    descending: true )
                                                    .snapshots( ),
                                                // ignore: missing_return
                                                builder: (context,
                                                    AsyncSnapshot<
                                                        QuerySnapshot> snapshot) {
                                                  if (!snapshot.hasData ||
                                                      snapshot.hasError) {
                                                    return Container(color:Colors.red );
                                                  }

                                                  else if (snapshot.hasData &&
                                                      snapshot.data.documents
                                                          .length == 0) {
                                                    print( 'hetghii' );
                                                    print( currentuser );
                                                    Firestore.instance
                                                        .collection( 'users' )
                                                        .document(
                                                        currentuser )
                                                        .get()
                                                        .then( (value) {
                                                      setState(() {
                                                        other =
                                                        value['chattingWith'][index];
                                                      });


                                                    } );
                                                    print( other );
                                                    groupe =
                                                    '$currentuser-$other';

                                                    return StreamBuilder(
                                                        stream: Firestore
                                                            .instance
                                                            .collection(
                                                            'messages' )
                                                            .document(
                                                            groupe )
                                                            .collection(
                                                            groupe )
                                                            .orderBy(
                                                            'timestamp',
                                                            descending: true )
                                                            .snapshots( ),
                                                        builder: (BuildContext context,
                                                            snapshot) {
                                                          if (
                                                          !snapshot
                                                              .hasData||snapshot.hasError)
                                                            return Container(color:Colors.yellowAccent );
                                                          else {
                                                            Firestore.instance
                                                                .collection(
                                                                'users' )
                                                                .where(
                                                                'userID',
                                                                isEqualTo: currentuser ==
                                                                    snapshot
                                                                        .data
                                                                        .documents[
                                                                    index2]['idFrom']
                                                                    ? snapshot
                                                                    .data
                                                                    .documents[index2]
                                                                ['idTo']
                                                                    : snapshot
                                                                    .data
                                                                    .documents[index2]
                                                                ['idFrom'] )
                                                                .getDocuments( )
                                                                .then( (
                                                                value) =>
                                                            {
                                                              setState( () {
                                                                photo.insert(index,value.documents[index]
                                                                ['profilePictureURL']);
                                                                name.insert(index,value.documents[index]
                                                                ['firstName']);

                                                                charge = true;
                                                              } )
                                                            } );
                                                            return charge
                                                                ? Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top:2.0 ),
                                                              child:  Dismissible(
                                                                key: Key(currentuser), // UniqueKey().toString()
                                                                onDismissed: (direction) {

                                                                  _showErrorAlert(title: tr("confsup"),content: '${tr("suprime")} ${tr("chat")} '
                                                                      '  ${name[index2]}',name:currentuser== snapshot
                                                                      .data
                                                                      .documents[index]
                                                                  ['idFrom'] ?snapshot
                                                                      .data
                                                                      .documents[index]
                                                                  ['idTo']:snapshot
                                                                      .data
                                                                      .documents[index]
                                                                  ['idFrom'],current: currentuser);
                                                                },
                                                                background: Container(
                                                                  alignment: Alignment.centerRight,
                                                                  padding: EdgeInsets.only(right: 20.0),
                                                                  color: Colors.red,
                                                                  child: const Icon(
                                                                    Icons.delete,
                                                                    color:Colors.white,
                                                                  ),
                                                                ),
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (
                                                                                context) =>
                                                                                Chat(
                                                                                    peerId: currentuser ==
                                                                                        snapshot
                                                                                            .data
                                                                                            .documents[index]['idFrom']
                                                                                        ? snapshot
                                                                                        .data
                                                                                        .documents[index]
                                                                                    [
                                                                                    'idTo']
                                                                                        : snapshot
                                                                                        .data
                                                                                        .documents[index]
                                                                                    [
                                                                                    'idFrom'],
                                                                                    peerAvatar:
                                                                                    photo[index2],
                                                                                    change: true,
                                                                                    name:
                                                                                    name[index2] ) ) );
                                                                  },
                                                                  child: ChatUsersList(
                                                                    text: name[index2],
                                                                    secondaryText: snapshot
                                                                        .data
                                                                        .documents[index]
                                                                    [
                                                                    'type'] ==
                                                                        1
                                                                        ? tr(
                                                                        'image' )
                                                                        : snapshot
                                                                        .data
                                                                        .documents[index]
                                                                    ['content'],
                                                                    image: photo[index2],
                                                                    isMessageRead:
                                                                    false,
                                                                    time: snapshot
                                                                        .data
                                                                        .documents[index]
                                                                    ['timestamp'],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                                : Container(color:Colors.red );
                                                          }
                                                        } );
                                                  }
                                                  else if (snapshot.hasData && snapshot.data.documents.length!=0) {
                                                    Firestore.instance
                                                        .collection( 'users' )
                                                        .where( 'userID',
                                                        isEqualTo: currentuser ==
                                                            snapshot.data
                                                                .documents[index]
                                                            ['idFrom']
                                                            ? snapshot.data
                                                            .documents[index]
                                                        ['idTo']
                                                            : snapshot.data
                                                            .documents[index]
                                                        ['idFrom'] )
                                                        .getDocuments( )
                                                        .then( (value) =>
                                                    {
                                                      setState((){
                                                        photo.insert(index,value.documents[index]
                                                        ['profilePictureURL']);
                                                        name.insert(index,value.documents[index]
                                                        ['firstName']);

                                                        charge = true;
                                                      })


                                                    } );
                                                    return charge
                                                        ? Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .only( top: 2.0,right: 10,left: 10 ),
                                                        child: Dismissible(
                                                          key: Key(currentuser), // UniqueKey().toString()
                                                          onDismissed: (direction) {

                                                            _showErrorAlert(title: tr("confsup"),content: '${tr("suprime")} ${tr("chat")}   ${name[index2]}',name:currentuser!= snapshot
                                                                .data
                                                                .documents[index]
                                                            ['idFrom'] ?snapshot
                                                                .data
                                                                .documents[index]
                                                            ['idFrom']:snapshot
                                                                .data
                                                                .documents[index]
                                                            ['idTo'],current: currentuser);
                                                          },
                                                          background: Container(
                                                            alignment: Alignment.centerRight,
                                                            padding: EdgeInsets.only(right: 20.0),
                                                            color: Colors.red,
                                                            child: const Icon(
                                                              Icons.delete,
                                                              color:Colors.white,
                                                            ),
                                                          ),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (
                                                                          context) =>
                                                                          Chat(
                                                                              peerId: currentuser ==
                                                                                  snapshot
                                                                                      .data
                                                                                      .documents[index2]
                                                                                  [
                                                                                  'idFrom']
                                                                                  ? snapshot
                                                                                  .data
                                                                                  .documents[
                                                                              index2]['idTo']
                                                                                  : snapshot
                                                                                  .data
                                                                                  .documents[index2]
                                                                              ['idFrom'],
                                                                              peerAvatar: photo[index2]!=''?photo[index2]:'',
                                                                              change: false,
                                                                              name: name[index2] ) ) );
                                                            },
                                                            child: ChatUsersList(
                                                                text: name[index2],
                                                                secondaryText:
                                                                snapshot.data
                                                                    .documents[index]
                                                                ['type'] ==
                                                                    1
                                                                    ? tr(
                                                                    'image')
                                                                    : snapshot
                                                                    .data
                                                                    .documents[index]
                                                                ['content'],
                                                                image: photo[index2],
                                                                isMessageRead: false,
                                                                time:
                                                                snapshot.data
                                                                    .documents[index]
                                                                ['timestamp'] ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                        : Container(color:Colors.green );
                                                  }
                                                  else
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 28.0),
                                                      child: ListView(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        children: [
                                                          Align(
                                                              alignment: Alignment.topCenter,
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Image.asset('assets/chat.png'),
                                                              )),
                                                          Align( alignment: Alignment.center,
                                                              child: Text( tr( 'aucmes' ),
                                                                style: TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight: FontWeight.bold,
                                                                ), ) )
                                                        ],
                                                      ),
                                                    );

                                                }
                                            );
                                          }
                                      ),
                                    );




                                  }),
                            );





                          }
                          else return Padding(
                              padding: const EdgeInsets.only(top: 28.0),
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  Align(
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset('assets/chat.png'),
                                      )),
                                  Align( alignment: Alignment.center,
                                      child: Text( tr( 'aucmes' ),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ), ) )
                                ],
                              ),
                            );
                        },
                      );
                    }
                  },
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/chat.png'),
                          )),
                      Align( alignment: Alignment.center,
                          child: Text( tr( 'aucmes' ),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ), ) )
                    ],
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }


  void _showErrorAlert({String title, String content,String name,String current}) {
    Platform.isIOS?
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CupertinoActionSheet(message: Text(content),

          title: Text(title),actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(tr(
                  "annuler"),style: TextStyle(color: Colors.blue), ),
              onPressed: () =>
              {
                Navigator.pop( context ),

              },
            ),
            CupertinoActionSheetAction(
              child: Text(tr(
                  "suprime" ),style: TextStyle(color: Colors.red), ),
              onPressed: () =>
              {
                Navigator.pop( context ),
                delite(name,current)
              },
            ),
          ],

        );
      },
    ):showDialog(context: context,builder: (contect)=>AlertDialog(shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0))),
        content:Text(content),
        title: Text(title),actions: <Widget>[
          MaterialButton(
            child: Text(tr("annuler"),style: TextStyle(color: Colors.blue),),
            onPressed: () =>{ Navigator.pop( context ),
            },
          ),
          MaterialButton(
            child: Text(tr(
                "suprime" ),style: TextStyle(color: Colors.red),),
            onPressed: () =>{ Navigator.pop( context ),
              delite(name,current)},
          )
        ]));
  }




  delite(String name,String current) async {
    print(name);
    print(current);
    try {

      Firestore.instance.collection("users").document(current).updateData({
        "chattingWith" : FieldValue.arrayRemove([name])
      });

    }catch (e) {
      print( "Error in suprime up: $e" );

    }
  }



  void showNotification(message) async {


    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.moetaz.tap_bar' : 'com.moetaz.tap_bar',
      'Ekry.tn',
      'Ekry.tn',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
    new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    setState((){
      title= tr( "title" );
    });

    FlutterAppBadger.updateBadgeCount(1);
    await flutterLocalNotificationsPlugin.show(
        0, '$title ${message['title'].toString()}', message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));



  }

}

