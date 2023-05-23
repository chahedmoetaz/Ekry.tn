
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:validated/validated.dart' as validate;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:easy_localization/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:tn/Filter_page/filter_screen.dart';
import 'package:tn/Recherche_pages/view_maps.dart';

import 'package:tn/Widgets/annonce_list_view.dart';
import 'package:tn/Widgets/detail_annonce.dart';
import 'package:tn/nav_bar.dart';

class ListFilter extends StatefulWidget {
  final String title;
  final bool groupe2;
  final int groupe,jourend,moisEnd,jourStart,moisStart;
  final DateTime dateEnd,dateStart;
  final  List<int> type;
  final  List<String> list;

  ListFilter({this.title,this.groupe,this.moisEnd, this.moisStart, this.jourStart,
    this.jourend,this.dateEnd, this.dateStart,this.groupe2,this.type,this.list});
  @override
  _ListFilterState createState() => _ListFilterState(title);
}

class _ListFilterState extends State<ListFilter> {
  String title;

  LatLng destination;
  DateTime startDate = DateTime.now();
  bool connect=false;

  DateTime dateStart,dateend;



  _ListFilterState(this.title);

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }
  String arabe='';


  var firestoreInstance;
  @override
  void initState() {
    if(widget.dateStart==null||widget.dateEnd==null){
      dateStart = DateTime.now();
      dateend = DateTime.now().add(const Duration(days: 1));
    }
    else {
      dateStart=widget.dateStart;
      dateend=widget.dateEnd;
    }

    _connection( );
    print(widget.title);
    print(widget.groupe);
    print(widget.type);
    print(widget.dateStart);
    print(widget.dateEnd);
    print(widget.list);
    print(widget.list.length);

    super.initState( );

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.push(context,MaterialPageRoute(
              builder: (context) => BottomNavBar())),
          icon: Icon(
            Platform.isAndroid?Icons.arrow_back:Icons.arrow_back_ios,
          ),
        ),actions: <Widget>[
        !connect?
        SizedBox()
            : IconButton(icon: Icon(Icons.search,color: Theme.of(context).cursorColor,), onPressed: ()=>_getSearch()
        ),
      ],
        centerTitle: true,
        title: Text(
          title,
        ),
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body:!connect?
      Center(child: Icon(Icons.signal_wifi_off,size: 60,),)
          : Stack(
        children: <Widget>[
          StreamBuilder(
              stream:Firestore.instance.collection('annonces').where('adresse',arrayContainsAny:["Gouvernorat de $title",
                " $title",arabe,' $arabe',title," Gouvernorat de $title"]).snapshots(),
              builder:  (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(snapshot.hasError)
                  return Padding(
                    padding: const EdgeInsets.only(top:28.0),
                    child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                      Align(alignment:Alignment.topCenter,child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/lister.png'),
                      )),
                      Align(alignment:Alignment.center,child: Text('aucun result'))
                    ],),
                  );
                else if(!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                        Theme.of(context).accentColor,
                      ),
                    ),
                  );
                else if(snapshot.hasData&&snapshot.data.documents.length!=0)
                  return StreamBuilder(
                      stream:widget.groupe==2?Firestore.instance.collection('annonces').where('adresse',arrayContainsAny:["Gouvernorat de $title",
                        " $title",arabe,' $arabe',title," Gouvernorat de $title"]).where('perMonth',isGreaterThanOrEqualTo: widget.moisStart).
                      where('perMonth',isLessThanOrEqualTo: widget.moisEnd).orderBy('perMonth',descending: widget.groupe2).snapshots()
                          :widget.groupe==1
                          ?Firestore.instance.collection('annonces').where('adresse',arrayContainsAny:["Gouvernorat de $title",
                        " $title",arabe,' $arabe',title," Gouvernorat de $title"]).where('perNight',isGreaterThanOrEqualTo: widget.jourStart).
                      where('perNight',isLessThanOrEqualTo: widget.jourend).orderBy('perNight',descending: widget.groupe2).snapshots()
                          :Firestore.instance.collection('annonces').where('adresse',arrayContainsAny:["Gouvernorat de $title",
                        " $title",arabe,' $arabe',title," Gouvernorat de $title"]).snapshots(),
                      builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                        //print(snapshot.data.documents.length);
                        if(!snapshot.hasData)
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                Theme.of(context).accentColor,
                              ),
                            ),
                          );

                        else if(snapshot.data==null)
                          return Padding(
                            padding: const EdgeInsets.only(top:28.0),
                            child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                              Align(alignment:Alignment.topCenter,child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('assets/lister.png'),
                              )),
                              Align( alignment: Alignment.center,
                                  child: Text( tr( 'aucan' ),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ), ) )
                            ],),
                          );
                        else if(snapshot.hasData && snapshot.data.documents.length!=0)
                          return Container(

                            child: ListView.builder(
                              //margin: const EdgeInsets.only(bottom:60.0),
                              itemCount: snapshot.data.documents.length,
                              padding: const EdgeInsets.only( top: 8,bottom: 60),
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
                                Timestamp dt = snapshot.data.documents[index]['de'];
                                DateTime de = dt.toDate();
                                Timestamp t = snapshot.data.documents[index]['a'];
                                DateTime d = t.toDate();
                                print(startDate.difference(d).inDays);

                                if(dateStart.isAfter(de)&&dateend.isBefore(d))
                                  if(widget.type.length==0 && widget.list.length!=0) {
                                    if (widget.list.length == 2 &&
                                        (snapshot.data.documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list.first)==true ||
                                            snapshot.data.documents[index]['equipment']
                                                .toString( )
                                                .contains(
                                                widget.list.last )==true)) {

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

                                    }
                                    if (widget.list.length == 1 &&
                                        (snapshot.data.documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[0])==true)) {

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

                                    }
                                    if (widget.list.length == 3 &&
                                        (snapshot.data.documents[index]['equipment']
                                            .toString()
                                            .contains(
                                            widget.list.first)==true ||snapshot.data.documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[2])==true ||
                                            snapshot.data.documents[index]['equipment']
                                                .toString( )
                                                .contains(
                                                widget.list.last)==true)) {

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

                                    }
                                    if (widget.list.length == 4 &&
                                        (snapshot.data.documents[index]['equipment']
                                            .toString()
                                            .contains(
                                            widget.list.first ) ==true||snapshot.data.documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[2])==true ||snapshot.data.documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[3])==true ||
                                            snapshot.data.documents[index]['equipment']
                                                .toString( )
                                                .contains(
                                                widget.list.last )==true)) {

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

                                    }
                                    if (widget.list.length == 5 &&
                                        (snapshot.data.documents[index]['equipment']
                                            .toString()
                                            .contains(
                                            widget.list.first )==true ||snapshot.data.documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[2]) ==true||snapshot.data.documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[3] )==true ||snapshot.data.documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[4]) ==true||
                                            snapshot.data.documents[index]['equipment']
                                                .toString( )
                                                .contains(
                                                widget.list.last)==true)){

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

                                    }
                                    if(widget.list.length == 0) return Padding(
                                      padding: const EdgeInsets.only(top:28.0),
                                      child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                                        Align(alignment:Alignment.topCenter,child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset('assets/lister.png'),
                                        )),
                                        Align( alignment: Alignment.center,
                                            child: Text( tr( 'aucan' ),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ), ) )
                                      ],),
                                    );
                                    else return Padding(
                                      padding: const EdgeInsets.only(top:28.0),
                                      child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                                        Align(alignment:Alignment.topCenter,child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset('assets/lister.png'),
                                        )),
                                        Align( alignment: Alignment.center,
                                            child: Text( tr( 'aucan' ),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ), ) )
                                      ],),
                                    );
                                  }
                                  else if(widget.type.length!=0&& widget.list.length==0) {
                                    if (widget.type.length == 2 &&
                                        (snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) )==true ||
                                            snapshot.data.documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last.toString( ) )==true)) {

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

                                    }else if (widget.type.length == 1 &&
                                        (snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString())==true)) {

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

                                    }else if (widget.type.length == 3 &&
                                        (snapshot.data.documents[index]['type']
                                            .toString()
                                            .contains(
                                            widget.type.first.toString( ) )==true ||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) )==true ||
                                            snapshot.data.documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last.toString( ) )==true)) {

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

                                    }else if (widget.type.length == 4 &&
                                        (snapshot.data.documents[index]['type']
                                            .toString()
                                            .contains(
                                            widget.type.first.toString( ) ) ==true||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) )==true ||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[3].toString( ) )==true ||
                                            snapshot.data.documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last.toString( ) ))) {

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

                                    }else if (widget.type.length == 5 &&
                                        (snapshot.data.documents[index]['type']
                                            .toString()
                                            .contains(
                                            widget.type.first.toString( ) )==true ||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) ) ==true||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[3].toString( ) )==true ||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[4].toString( ) ) ==true||
                                            snapshot.data.documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last.toString( ) )==true)){

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

                                    }
                                    else if(widget.type.length==0) return Padding(
                                      padding: const EdgeInsets.only(top:28.0),
                                      child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                                        Align(alignment:Alignment.topCenter,child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset('assets/lister.png'),
                                        )),
                                        Align( alignment: Alignment.center,
                                            child: Text( tr( 'aucan' ),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ), ) )
                                      ],),
                                    );
                                    else return Padding(
                                        padding: const EdgeInsets.only(top:28.0),
                                        child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                                          Align(alignment:Alignment.topCenter,child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset('assets/lister.png'),
                                          )),
                                          Align( alignment: Alignment.center,
                                              child: Text( tr( 'aucan' ),
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ), ) )
                                        ],),
                                      );
                                  }
                                  else if(widget.type.length!=0 && widget.list.length!=0) {
                                    if (widget.type.length == 3 &&widget.list.length==5&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[4])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true
                                                ||snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 2 &&widget.list.length==5&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[4])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||

                                                snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 2 &&widget.list.length==4&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||

                                                snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 3 &&widget.list.length==2&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true ||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 4 &&widget.list.length==2&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true ||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[3].toString( ) )==true ||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 4 &&widget.list.length==5&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[4])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true ||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[3].toString( ) )==true ||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 4 &&widget.list.length==3&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true ||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[3].toString( ) )==true ||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 3 &&widget.list.length==4&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true
                                                ||snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 5 &&widget.list.length==4&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type[3].toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type[4].toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true
                                                    &&snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 5 &&widget.list.length==3&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type[3].toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type[4].toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true
                                                ||snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 5 &&widget.list.length==2&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type[3].toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type[4].toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true
                                                ||snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 5 &&widget.list.length==1&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type[3].toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type[4].toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true
                                                ||snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 4 &&widget.list.length==1&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains( widget.type[3].toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true
                                                ||snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 3 &&widget.list.length==1&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true)&&(
                                            snapshot.data.documents[index]['type'].toString().contains( widget.type.first.toString( ) )==true||
                                                snapshot.data.documents[index]['type'].toString().contains(widget.type[2].toString( ) )==true
                                                ||snapshot.data.documents[index]['type'].toString().contains( widget.type.last.toString( ) )==true)))
                                    {

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

                                    }
                                    else if (widget.type.length == 1 &&widget.list.length==5&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true ||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2] )==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3] )==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[4] )==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last )==true )&&(
                                            snapshot.data.documents[index]['type']
                                                .toString()
                                                .contains(
                                                widget.type.first.toString( ) )==true))) {

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

                                    }
                                    else if (widget.type.length == 1 &&widget.list.length==4&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true ||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2] )==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3] )==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last )==true )&&(
                                            snapshot.data.documents[index]['type']
                                                .toString()
                                                .contains(
                                                widget.type.first.toString( ) )==true))) {

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

                                    }
                                    else if (widget.type.length == 1 &&widget.list.length==3&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true ||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2] )==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last )==true )&&(
                                            snapshot.data.documents[index]['type']
                                                .toString()
                                                .contains(
                                                widget.type.first.toString( ) )==true))) {

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

                                    }
                                    else if (widget.type.length == 2 &&widget.list.length==3&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true ||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2] )==true||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last )==true )&&(
                                            snapshot.data.documents[index]['type']
                                                .toString()
                                                .contains(
                                                widget.type.first.toString( ) )==true ||
                                                snapshot.data.documents[index]['type']
                                                    .toString( )
                                                    .contains(
                                                    widget.type.last.toString( ) )==true))) {

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

                                    }
                                    else if (widget.type.length == 2 &&widget.list.length==1&&
                                        (snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true&&(
                                            snapshot.data.documents[index]['type']
                                                .toString()
                                                .contains(
                                                widget.type.first.toString( ) )==true ||
                                                snapshot.data.documents[index]['type']
                                                    .toString( )
                                                    .contains(
                                                    widget.type.last.toString( ) )==true))) {

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

                                    }
                                    else if (widget.type.length == 1 &&widget.list.length==2&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true ||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last )==true )&&
                                            snapshot.data.documents[index]['type']
                                                .toString()
                                                .contains(
                                                widget.type.first.toString( ) )==true)) {

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

                                    }
                                    else if (widget.type.length == 2 &&widget.list.length==2&&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true ||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last )==true )&&(
                                            snapshot.data.documents[index]['type']
                                                .toString()
                                                .contains(
                                                widget.type.first.toString( ) )==true ||
                                                snapshot.data.documents[index]['type']
                                                    .toString( )
                                                    .contains(
                                                    widget.type.last.toString( ) )==true))) {

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

                                    }
                                    else if (widget.type.length == 1 &&widget.list.length==1&&
                                        (snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ))==true&&
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)==true)) {

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

                                    }
                                    else if (widget.type.length == 3 &&widget.list.length == 3 &&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)||
                                            snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])
                                        )&&(snapshot.data.documents[index]['type']
                                            .toString()
                                            .contains(
                                            widget.type.first.toString( ) )==true ||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) )==true ||
                                            snapshot.data.documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last.toString( ) )==true))) {

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

                                    }
                                    else if (widget.type.length == 4 &&widget.list.length == 4 &&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)
                                            ||snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)
                                            ||snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3])
                                            ||snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])
                                        )&&(snapshot.data.documents[index]['type']
                                            .toString()
                                            .contains(
                                            widget.type.first.toString( ) ) ==true||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) )==true ||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[3].toString( ) )==true ||
                                            snapshot.data.documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last.toString( ))))) {

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

                                    }else if (widget.type.length == 5 &&widget.list.length == 5 &&
                                        ((snapshot.data.documents[index]['equipment'].toString().contains( widget.list.first)
                                            ||snapshot.data.documents[index]['equipment'].toString().contains( widget.list.last)
                                            ||snapshot.data.documents[index]['equipment'].toString().contains( widget.list[3])
                                            ||snapshot.data.documents[index]['equipment'].toString().contains( widget.list[4])
                                            ||snapshot.data.documents[index]['equipment'].toString().contains( widget.list[2])
                                        )&&(snapshot.data.documents[index]['type']
                                            .toString()
                                            .contains(
                                            widget.type.first.toString( ) )==true ||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) ) ==true||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[3].toString( ) )==true ||snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[4].toString( ) ) ==true||
                                            snapshot.data.documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last.toString( ) )==true))){

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

                                    }
                                    else if(widget.type.length == 0 &&widget.list.length == 0) return Padding(
                                      padding: const EdgeInsets.only(top:28.0),
                                      child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                                        Align(alignment:Alignment.topCenter,child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset('assets/lister.png'),
                                        )),
                                        Align(alignment:Alignment.center,child: Text('aucun result'))
                                      ],),
                                    );
                                    else return Padding(
                                        padding: const EdgeInsets.only(top:28.0),
                                        child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                                          Align(alignment:Alignment.topCenter,child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset('assets/lister.png'),
                                          )),
                                          Align(alignment:Alignment.center,child: Text('aucun result'))
                                        ],),
                                      );
                                  }
                                  else if(snapshot.data!=null)
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
                                  else return Padding(
                                      padding: const EdgeInsets.only(top:28.0),
                                      child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                                        Align(alignment:Alignment.topCenter,child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset('assets/lister.png'),
                                        )),
                                        Align( alignment: Alignment.center,
                                            child: Text( tr( 'aucan' ),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ), ) )
                                      ],),
                                    );
                                else return Padding(
                                  padding: const EdgeInsets.only(top:28.0),
                                  child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                                    Align(alignment:Alignment.topCenter,child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset('assets/lister.png'),
                                    )),
                                    Align( alignment: Alignment.center,
                                        child: Text( tr( 'aucan' ),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ), ) )
                                  ],),
                                );
                              },
                            ),
                          );

                        else return Padding(
                            padding: const EdgeInsets.only(top:28.0),
                            child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                              Align(alignment:Alignment.topCenter,child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('assets/lister.png'),
                              )),
                              Align( alignment: Alignment.center,
                                  child: Text( tr( 'aucan' ),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ), ) )
                            ],),
                          );
                      }

                  );
                else return Padding(
                    padding: const EdgeInsets.only(top:28.0),
                    child: ListView( physics: NeverScrollableScrollPhysics(),children:[
                      Align(alignment:Alignment.topCenter,child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/lister.png'),
                      )),
                      Align( alignment: Alignment.center,
                          child: Text( tr( 'aucan' ),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ), ) )
                    ],),
                  );

              }
          ),
          Positioned(
            right: MediaQuery.of(context).size.width / 8,
            bottom: 40,
            child: Container(

              width: MediaQuery.of(context).size.width / 1.5,
              height: MediaQuery.of(context).size.height / 16,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.teal,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMaps(title: title,groupe:widget.groupe,
                                moisStart:widget.moisStart,moisEnd:widget.moisEnd,
                                jourStart:widget.jourStart,jourend:widget.jourend,
                                // ignore: unrelated_type_equality_checks
                                groupe2: widget.groupe2==1?true:false,dateStart:dateStart,dateEnd:dateend,
                                list:widget.list,type:widget.type ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius:tr( "add_type" ) == "Type"? BorderRadius.only(
                                topLeft: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                              ):BorderRadius.only(
                                topRight: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              )

                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  Icons.map,
                                  color: Colors.white,
                                ),
                                Text(
                                  tr("Map"),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                  Expanded(
                      child: InkWell(
                        onTap: () {
                          FocusScope.of( context ).requestFocus(
                              FocusNode( ) );
                          // setState(() {
                          //   isDatePopupOpen = true;
                          // });

                          Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) => FiltersScreen(
                                  titel:title,map: 1,
                                  filter:(int groupe,moisStart,moisEnd,jourStart,jourEnd,bool groupe2,DateTime start,DateTime end,list,type){

                                  }),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(

                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              )

                          ),
                          child: Center(

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                ),
                                Text(
                                  tr("filtre"),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
  }
  _getSearch() async {
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: "AIzaSyDpa8n8zgXtd20x307hhdqji_Z-z9rN-Z8",
      onError: onError,
      mode: Mode.overlay,
      language: "fr",
      components: [Component(Component.country, "TN")],

    );

  }


  // ignore: missing_return
  Future<bool> _connection()async{

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile||connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        connect=true;
        if(validate.contains(title, ', Tunisie'))
          title=title.replaceAll(', Tunisie', '');
        if(validate.contains(title, '، Tunisie')) {
          title = title.replaceAll( '، Tunisie', '' );
          arabe=tr(title);
          print(title.toString());
          print(arabe);
        }
        else title=title;

      });
    } else setState(() {
      connect=false;
    });

  }






}