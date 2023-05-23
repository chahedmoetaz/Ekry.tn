
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:tn/Screens/EditUser.dart';

import 'package:tn/Screens/singin-singup.dart';
import 'package:tn/Widgets/custom_flat_button.dart';

import 'package:tn/provider/app_provider.dart';
import 'package:tn/services/auth.dart';
import 'package:tn/util/constants.dart';
import 'package:tn/util/user.dart';


class UserScreen extends StatefulWidget {
  final FirebaseUser firebaseUser;

  UserScreen({this.firebaseUser});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _a;
  @override
  void initState() {
    _visible();
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    final data = EasyLocalizationProvider
        .of( context )
        .data;

    return EasyLocalizationProvider(
      child: Scaffold(
        backgroundColor: Theme
            .of( context )
            .backgroundColor,
        appBar: AppBar(
          elevation: Theme
              .of( context )
              .appBarTheme
              .elevation,leading: SizedBox(),
          centerTitle: true,
          title: Text(
            tr( "app_bar_user" ), ),
        ),
        body: SingleChildScrollView(
          child: Column( children: <Widget>[
            Padding( padding: EdgeInsets.all( 5 ) ),
            Container(
                height: MediaQuery
                    .of( context )
                    .size
                    .height / 3.2,
                child: RootScreen()
            ),
            Padding( padding: EdgeInsets.all( 10 ) ),
            Container(
              child: Column(

                children: <Widget>[
                  InkWell( onTap: () => _onActionSheetPress( context, data ),
                    child: Container(
                      color: Colors.grey.withOpacity( 0.1 ),
                      padding: EdgeInsets.symmetric( horizontal: 10 ),

                      height: 60,
                      margin: EdgeInsets.zero,
                      child: tr( "user_body_dark" ) == "الوضع الداكن"
                          ? Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            tr( "language" ),

                            style: TextStyle( fontSize: 20 ),
                          )
                      )
                          : Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tr( "language" ),

                          style: TextStyle( fontSize: 18 ),
                        ),
                      ), ),

                  ),

                  SizedBox(
                    height: 1,
                  ),
                  Container(
                    padding: EdgeInsets.all( 10 ),
                    color: Colors.grey.withOpacity( 0.1 ),
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            tr( "user_body_dark" ),
                            style: TextStyle( fontSize: 18 ),
                          ),
                        ),
                        CupertinoSwitch(
                          activeColor: Provider
                              .of<AppProvider>( context )
                              .theme ==
                              Constants.lightTheme
                              ? Theme
                              .of( context )
                              .accentColor
                              : Theme
                              .of( context )
                              .accentColor,
                          onChanged: (v) {
                            if (v) {
                              Provider.of<AppProvider>( context, listen: false )
                                  .setTheme( Constants.darkTheme, "dark" );
                            } else {
                              Provider.of<AppProvider>( context, listen: false )
                                  .setTheme( Constants.lightTheme, "light" );
                            }
                          },
                          value: Provider
                              .of<AppProvider>( context )
                              .theme ==
                              Constants.lightTheme
                              ? false
                              : true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Container(
                    color: Colors.grey.withOpacity( 0.1 ),
                    padding: EdgeInsets.all( 15 ),

                    height: 60,
                    margin: EdgeInsets.zero,
                    child: tr( "user_body_dark" ) == "الوضع الداكن"
                        ? GestureDetector(
                      onTap: ()=>_showErrorAlert(title: tr( "user_body_fon" ),content: tr("fonc")),
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          tr( "user_body_fon" ),

                          style: TextStyle( fontSize: 20 ),
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: ()=>_showErrorAlert(title: tr( "user_body_fon" ),content: tr("fonc")),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tr( "user_body_fon" ),

                          style: TextStyle( fontSize: 18 ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Container(
                    color: Colors.grey.withOpacity( 0.1 ),
                    padding: EdgeInsets.all( 15 ),

                    height: 60,
                    child: tr( "user_body_dark" ) == "الوضع الداكن"
                        ? GestureDetector(
                      onTap: ()=>_showErrorAlert(title: tr( "user_body_ser" ),content: tr("client")),
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          tr( "user_body_ser" ),

                          style: TextStyle( fontSize: 20 ),
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: ()=>_showErrorAlert(title: tr( "user_body_ser" ),content: tr("client")),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tr( "user_body_ser" ),

                          style: TextStyle( fontSize: 18 ),
                        ),
                      ),
                    ),

                  ),
                  SizedBox(
                    height: 1,
                  ),
                  if(_a==true)
                    InkWell(
                      onTap: () =>
                      {
                        print( 'tapp' ),
                        setState( () {
                          _a = false;
                          _logOut( );
                        } )
                      },
                      child: Container(
                        alignment:tr( "user_body_dark" ) == "الوضع الداكن"? Alignment.centerRight:Alignment.centerLeft,
                        padding: EdgeInsets.all( 15 ),

                        height: 60,
                        margin: EdgeInsets.zero,
                        child: Container(
                          child: Text(
                            tr( "user_body_dconn" ),

                            style: TextStyle( fontSize: 18, color: Colors.red ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: Text(
                      tr( "user_body_ver" ),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 17,
                          fontWeight: FontWeight.w700 ),
                    ),
                  )
                ],
              ),
            ),
          ] ),
        ),

      ),
    );
  }

  void _onActionSheetPress(BuildContext context, data) {
    Platform.isIOS
        ?showCupertinoModalPopup( context: context,builder: (context)=>
        CupertinoActionSheet(
          title: Text( tr( 'language' ) ),
          message: Text(
            tr( 'language_msg' ), style: TextStyle( fontSize: 15 ), ),
          actions: <Widget>[

            CupertinoActionSheetAction(
              child: Text( tr( 'language_fr' ) ),
              onPressed: () =>
              {
                Navigator.pop( context ),
                data.changeLocale( locale: Locale( 'fr', 'FR' ) )
              },
            ),

            CupertinoActionSheetAction(
              child: Text( tr( 'language_ar' ) ),
              onPressed: () =>
              {
                Navigator.pop( context ),
                data.changeLocale( locale: Locale( 'ar', 'FR' ) )
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(

            child: Text(
              tr( 'annuler' ), style: TextStyle( color: Colors.red ), ),
            isDefaultAction: true,
            onPressed: () =>  {
              Navigator.pop( context ),
              data.changeLocale( locale: Locale( '', 'FR' ) )
            },
          ),
        ),
    )
        :showModalBottomSheet(backgroundColor: Colors.transparent,isDismissible: true,
      context: context,
      builder:(context)=> CupertinoActionSheet(

        title: Text( tr( 'language' ) ),
        message:  Text(
          tr( 'language_msg' ), style: TextStyle( fontSize: 16,color: Theme.of(context).cursorColor ), ),

        actions: <Widget>[


          FlatButton(
            child: Text( tr( 'language_fr' ),style: TextStyle(color: Colors.blue) ),
            onPressed: () =>
            {
              Navigator.pop( context ),
              data.changeLocale( locale: Locale( 'fr', 'FR' ) )
            },
          ),

          FlatButton(
            child: Text( tr( 'language_ar' ),style: TextStyle(color: Colors.blue), ),
            onPressed: () =>
            {
              Navigator.pop( context ),
              data.changeLocale( locale: Locale( 'ar', 'FR' ) )
            },
          ),


        ],
        cancelButton: FlatButton(
          child: Text(
            tr( 'annuler'), style: TextStyle( color: Colors.red ), ),

          onPressed: () => Navigator.pop( context ),
        ),

      ),
    );
  }

  void _logOut() async {
    Auth.signOut( );
  }

  // ignore: non_constant_identifier_names
  RootScreen() {
    return new StreamBuilder<FirebaseUser>(
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

                  return Container(

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 150.0,
                          width: 150.0,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: (snapshot.data
                                .profilePictureURL == '')
                                ? AssetImage( "assets/default.png" )
                                : NetworkImage(
                              snapshot.data.profilePictureURL, )
                            ,
                          ),
                        ),
                        Text(snapshot.data.firstName,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18), ),
                        GestureDetector(
                            onTap: ()  {
                              Navigator.of( context ).push( MaterialPageRoute(
                                  builder: (context) => ProfilePage(snapshot.data.userID) )).then( (user) async {
                                await _visible();
                              } );
                            },
                            child: Text(
                              tr( "user_bottom_modif" ),
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400 ),
                            ) ),
                      ],
                    ),
                  );
                }
              },
            );

          } else {
            return Container(

                width: MediaQuery
                    .of( context )
                    .size
                    .width - 50,

                child: Stack(
                  children: [
                    Align(alignment: Alignment.topCenter,
                      child: Image.asset('assets/connect.png',height: MediaQuery
                          .of( context )
                          .size
                          .height/4-10,),
                    ),
                    Align(alignment: Alignment.bottomCenter,
                      child: CustomFlatButton(
                        title: tr( "user_body_conn" ),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () =>
                            Navigator.push( context,
                                MaterialPageRoute( builder: (context) => MyHomePage( ) ) )
                                .then( (user) async {
                              await _visible();
                            } ),
                        splashColor: Colors.black12,
                        borderColor: Theme.of(context).accentColor,
                        borderWidth: 0,
                        color: Theme.of(context).accentColor,
                      ),
                    ),

                  ],
                )
            );
          }
        }
      },
    );
  }

  _visible()async {
    FirebaseUser user =await Auth.getCurrentFirebaseUser();
    if (user!=null)
      setState(() {
        _a=true;
      });

  }
  void _showErrorAlert({String title, String content}) {
    Platform.isIOS?
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CupertinoActionSheet(message: Text(content),

            title: Text(title)

        );
      },
    ):showDialog(context: context,builder: (contect)=>AlertDialog(shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0))),
      content:Text(content),
      title: Text(title),));
  }


}
