import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tn/Widgets/annonce_list_view.dart';
import 'package:tn/Widgets/detail_annonce.dart';
import 'package:tn/services/auth.dart';
import 'package:tn/util/user.dart';


class FavoriteList extends StatefulWidget {
  @override
  _FavoriteListState createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  String currentuser;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(leading: SizedBox(),
        elevation: Theme.of(context).appBarTheme.elevation,
        title: Text(
    tr("app_bar_favoris"),

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
                  return StreamBuilder(
                      stream: Firestore.instance.collection('users').document(snapshot.data.userID).snapshots(),
                      builder:  (_, snapshot) {
                        if(!snapshot.hasData||snapshot.hasError) {

                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                Theme
                                    .of( context )
                                    .accentColor,
                              ),
                            ),
                          );

                        }
                        else if(snapshot.hasData&&snapshot.data['favorites']!=null){

                          return StreamBuilder(
                              stream:Firestore.instance.collection( 'annonces' )
                                  .where('annonceID', whereIn:snapshot.data['favorites']).orderBy('annonceID')
                                  .snapshots(),
                              builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData||snapshot.hasError)
                                  return Padding(
                                    padding: const EdgeInsets.only( top: 28.0 ),
                                    child: ListView(
                                      physics: NeverScrollableScrollPhysics( ),
                                      children: [
                                        Align( alignment: Alignment.topCenter,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0 ),
                                              child: Image.asset(
                                                  'assets/empty.png' ),
                                            ) ),
                                        Align( alignment: Alignment.center,
                                            child: Text( tr( 'fav_body' ),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ), ) )
                                      ], ),
                                  );

                               else if(snapshot.hasData || snapshot.data.documents.length!=0) {
                                  return ListView.builder(
                                    itemCount: snapshot.data.documents.length,
                                    padding: const EdgeInsets.only( top: 8 ),
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (BuildContext context,
                                        int index) {

                                      return AnnonceListView(
                                        callback: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailAnnonce(
                                                    annonceData: snapshot.data
                                                        .documents[index]
                                                        .data, ),
                                            ),
                                          );
                                        },
                                        annonceData: snapshot.data
                                            .documents[index],
                                      );
                                    },
                                  );
                                }
                                else if(snapshot.data.documents.length==0 ||snapshot.data==null) {
                                  print("lennnn");
                                  /*Firestore.instance.collection("users").document(currentuser).updateData({
                                    "favorites" : FieldValue.delete()
                                  });*/
                                  return Padding(
                                    padding: const EdgeInsets.only( top: 28.0 ),
                                    child: ListView(
                                      physics: NeverScrollableScrollPhysics( ),
                                      children: [
                                        Align( alignment: Alignment.topCenter,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0 ),
                                              child: Image.asset(
                                                  'assets/empty.png' ),
                                            ) ),
                                        Align( alignment: Alignment.center,
                                            child: Text( tr( 'fav_body' ),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ), ) )
                                      ], ),
                                  );
                                }

                                else return Padding(
                                    padding: const EdgeInsets.only( top: 28.0 ),
                                    child: ListView(
                                      physics: NeverScrollableScrollPhysics( ),
                                      children: [
                                        Align( alignment: Alignment.topCenter,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0 ),
                                              child: Image.asset(
                                                  'assets/empty.png' ),
                                            ) ),
                                        Align( alignment: Alignment.center,
                                            child: Text( tr( 'fav_body' ),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ), ) )
                                      ], ),
                                  );
                              }
                          );
                        }
                        else if(snapshot.hasData&&snapshot.data['favorites']==null) {
                          return Padding(
                            padding: const EdgeInsets.only(top:28.0),
                            child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                              Align(alignment:Alignment.topCenter,child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('assets/empty.png'),
                              )),
                              Align(alignment:Alignment.center,child: Text(tr('fav_body'), style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),))
                            ],),
                          );
                        }
                        else {
                          return Padding(
                            padding: const EdgeInsets.only(top:28.0),
                            child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                              Align(alignment:Alignment.topCenter,child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('assets/empty.png'),
                              )),
                              Align(alignment:Alignment.center,child: Text(tr('fav_body'), style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),))
                            ],),
                          );
                        }
                      }
                  );
                }
              },
            );

          } else {
            return Padding(
              padding: const EdgeInsets.only(top:28.0),
              child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                Align(alignment:Alignment.topCenter,child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/empty.png'),
                )),
                Align(alignment:Alignment.center,child: Text(tr('fav_body'), style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),))
              ],),
            );
          }
        }
      },
    ),
    );
  }


}

