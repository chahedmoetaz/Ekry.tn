import 'package:easy_localization/public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tn/chats/chat_page.dart';
import 'package:tn/services/auth.dart';
import 'package:tn/util/user.dart';

class Chat extends StatefulWidget {

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(leading: SizedBox(),
        elevation: Theme.of(context).appBarTheme.elevation,
        title: Text(
          tr("chat"),

        ),
        centerTitle: true,
      ),
      body:StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        // ignore: missing_return
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return new Center(
                child:SpinKitRotatingCircle(
                  color: Theme.of(context).accentColor,
                  size: 30.0,
                )
            );
          } else {
            if (snapshot.hasData) {
              return  StreamBuilder(
                stream: Auth.getUser( snapshot.data.uid ),
                builder: (BuildContext context, AsyncSnapshot<
                    User> snapshot) {

                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).accentColor,
                        ),
                      ),
                    );
                  } else {
                    return Container(height:MediaQuery.of(context).size.height-20,child: ChatPage(snapshot.data.userID));
                  }
                },
              );

            } else {
              return Padding(
                padding: const EdgeInsets.only(top:28.0),
                child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                  Align(alignment:Alignment.topCenter,child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/chat.png'),
                  )),
                  Align( alignment: Alignment.center,
                      child: Text( tr( 'aucmes' ),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ), ) )
                ],),
              );
            }
          }
        },
      ),
    );
  }
}