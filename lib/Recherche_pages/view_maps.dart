import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tn/Recherche_pages/listFilter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'package:tn/Filter_page/filter_screen.dart';

import 'package:tn/Widgets/detail_annonce.dart';
import 'package:validated/validated.dart' as validate;

class ViewMaps extends StatefulWidget {

  final String title;
  final bool groupe2;
  final int groupe,jourend,moisEnd,jourStart,moisStart;
  final DateTime dateEnd,dateStart;
  final  List<int> type;
  final  List<String> list;
  const ViewMaps({this.title,this.groupe,this.moisEnd, this.moisStart, this.jourStart,
    this.jourend,this.dateEnd, this.dateStart,this.groupe2,this.type,this.list});

  @override
  _ViewMapsState createState() => _ViewMapsState( title);
}

class _ViewMapsState extends State<ViewMaps> {
  bool loading = false;

  LatLng _initialPosition;

  final Set<Marker> _markers = {};


  bool locationServiceActive=false;

  bool err=false;

  String icon = 'assets/mapicon.png';

  double _posbottom=180;

  DateTime dateStart,dateend;


  Set<Marker> get markers => _markers;

  initState(){
    if(widget.dateStart==null||widget.dateEnd==null){
      dateStart = DateTime.now();
      dateend = DateTime.now().add(const Duration(days: 1));
    }
    else {
      dateStart=widget.dateStart;
      dateend=widget.dateEnd;
    }
    if(validate.contains( title, ", Tunisie" ) == false)
    title='$title, Tunisie';
    sendRequest(title);
    super.initState();

  }

  // ignore: non_constant_identifier_names
  Future<void> AddMarker(Map<String, dynamic> data) async {

    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(data['annonceID']),
          position: LatLng(data['lang.lat'], data['lang.long']),
          draggable: false,
          infoWindow: InfoWindow(
            title:  '${data['perNight'] != null ?
            data['perNight'].toString().replaceFirst('.0', '') : data['perMonth'].toString().replaceFirst('.0', '')} DT ',
            onTap: ()=>onCameraMove(LatLng(data['lang.lat'],data['lang.long'],)),
          ),
          onTap: () => onCameraMove(LatLng(data['lang.lat'], data['lang.long'])),
          // ignore: deprecated_member_use
          icon: BitmapDescriptor.fromAsset(
            icon,
          )));
      _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
        ..addListener(_onScroll(LatLng(data['lang.lat'], data['lang.long'])));
    });

  }
  int prevPage;
  _onScroll(LatLng latLng) {
    if (_pageController.page.toInt() != prevPage) {
      prevPage = _pageController.page.toInt();
      onCameraMove(latLng);
    }
  }
  void onCameraMove(LatLng local) {
    setState(() {
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: local,
            zoom: 17.0,
            bearing: 45.0,
            tilt: 45.0
        ),));
    });

  }
  // ignore: non_constant_identifier_names
  void CameraMove(CameraPosition position) {
    setState(() {
      _initialPosition = position.target;

    });
  }

  void sendRequest(String intendedLocation) async {
    print(intendedLocation);
    List<Placemark> placemark =
    await Geolocator( ).placemarkFromAddress( intendedLocation )
        .catchError((e){
      print('errr ----'+e);

      setState(() {
        err=true;
      });
    });
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;

    setState(() {
      _initialPosition = LatLng( latitude, longitude );
      print(_initialPosition.toString());
      locationServiceActive=true;

    });


  }


  String title;


  GoogleMapController _mapController;

  GoogleMapController get mapController => _mapController;

  _ViewMapsState(this.title);
  PageController _pageController;

  PageController get pageController=>_pageController;
  @override
  void dispose() {
    sendRequest(title);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of( context ).push( MaterialPageRoute(
              builder: (context) => ListFilter(title:title.replaceAll(', Tunisie', ''),groupe:widget.groupe,
                  moisStart:widget.moisStart,moisEnd:widget.moisEnd,
                  jourStart:widget.jourStart,jourend:widget.jourend,
                  // ignore: unrelated_type_equality_checks
                  groupe2: widget.groupe2==1?true:false,dateStart:dateStart,dateEnd:dateend,
                  list:widget.list==null?[]:widget.list,type:widget.type==null?[]:widget.type ) ) ),
          icon: Icon(
            Platform.isAndroid?Icons.arrow_back:Icons.arrow_back_ios,
          ),
        ),
        centerTitle: true,
        title: Text(
          title,
        ),actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search,color: Theme.of(context).cursorColor,),
          onPressed: ()=>getSearch(),
        )
      ],
        backgroundColor: Theme
            .of( context )
            .backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body:locationServiceActive == false
          ? Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SpinKitRotatingCircle(
                    color: Colors.teal,
                    size: 50.0,
                  )
                ],
              ),
              SizedBox( height: 10, ),
              Text( tr("charge"),
                style: TextStyle( color: Colors.grey, fontSize: 18 ), ),
              SizedBox( height: 10, ),
              Visibility(visible: err,child: Text( tr("noconnc"),
                style: TextStyle( color: Colors.grey, fontSize: 20 ), ))
            ],
          )
      )
          :Stack(
        children: <Widget>[

          _buildMap(),
          Positioned(
            right: MediaQuery
                .of( context )
                .size
                .width / 7,
            bottom: _posbottom,
            child: Container(
              width: MediaQuery
                  .of( context )
                  .size
                  .width / 1.5,
              height: MediaQuery
                  .of( context )
                  .size
                  .height / 16,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity( 0.2 ),
                  borderRadius: BorderRadius.circular( 8 ),
                  border: Border.all( color: Colors.teal ) ),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: InkWell(
                        onTap: ()=> Navigator.of( context ).push( MaterialPageRoute(
                            builder: (context) => ListFilter(title:title.replaceAll(', Tunisie', ''),groupe:widget.groupe,
                                moisStart:widget.moisStart,moisEnd:widget.moisEnd,
                                jourStart:widget.jourStart,jourend:widget.jourend,
                                // ignore: unrelated_type_equality_checks
                                groupe2: widget.groupe2==1?true:false,dateStart:dateStart,dateEnd:dateend,
                                list:widget.list==null?[]:widget.list,type:widget.type==null?[]:widget.type ) ) ),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: tr( "add_type" ) == "Type"? BorderRadius.only(
                                topLeft: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                              ):BorderRadius.only(
                                topRight: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              )
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  Icons.line_weight,
                                  color: Colors.white,
                                ),
                                Text(
                                  tr( "liste" ),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800 ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ) ),
                  Expanded(
                      child: InkWell(
                        onTap:() {
                          FocusScope.of( context ).requestFocus(
                              FocusNode( ) );
                          // setState(() {
                          //   isDatePopupOpen = true;
                          // });

                          Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) => FiltersScreen(titel: title,map:2),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular( 8 ),
                                bottomRight: Radius.circular( 8 ),
                              ) ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                ),
                                Text(
                                  tr( "filtre" ),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800 ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ) ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 1.0,
            child: Container(
              height: 200.0,
              width: MediaQuery
                  .of( context )
                  .size
                  .width - 50,
              child: StreamBuilder(
                  stream:widget.groupe==1
                      ?Firestore.instance.collection('annonces').where('adresse',arrayContainsAny:["Gouvernorat de ${title.replaceAll(', Tunisie', '')}",
                    " ${title.replaceAll(', Tunisie', '')}",title.replaceAll(', Tunisie', '')," Gouvernorat de ${title.replaceAll(', Tunisie', '')}"]).where('perNight',isGreaterThanOrEqualTo: widget.jourStart).
                  where('perNight',isLessThanOrEqualTo: widget.jourend).orderBy('perNight',descending: widget.groupe2).snapshots()
                      :widget.groupe==2?Firestore.instance.collection('annonces').where('adresse',arrayContainsAny:["Gouvernorat de ${title.replaceAll(', Tunisie', '')}",
                    " ${title.replaceAll(', Tunisie', '')}",title.replaceAll(', Tunisie', '')," Gouvernorat de ${title.replaceAll(', Tunisie', '')}"]).where('perMonth',isGreaterThanOrEqualTo: widget.moisStart).
                  where('perMonth',isLessThanOrEqualTo: widget.moisEnd).orderBy('perMonth',descending: widget.groupe2).snapshots()
                      :Firestore.instance.collection('annonces').where('adresse',arrayContainsAny:["Gouvernorat de ${title.replaceAll(', Tunisie', '')}",
                    " ${title.replaceAll(', Tunisie', '')}",title.replaceAll(', Tunisie', '')," Gouvernorat de ${title.replaceAll(', Tunisie', '')}"]).snapshots(),
                  builder:(_, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(!snapshot.hasData||snapshot.hasError)
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            Theme.of(context).accentColor,
                          ),
                        ),
                      );
                    else if(snapshot.data.documents.length!=0) {
                      return PageView.builder(
                          controller: pageController,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            Timestamp dt = snapshot.data.documents[index]['de'];
                            DateTime de = dt.toDate();
                            Timestamp t = snapshot.data.documents[index]['a'];
                            DateTime d = t.toDate();
                            if(dateStart.isAfter(de)&&dateend.isBefore(d)) {
                              if (widget.type.length == 0 &&
                                  widget.list.length != 0) {
                                if (widget.list.length == 2 &&
                                    (snapshot.data.documents[index]['equipment']
                                        .toString( )
                                        .contains(
                                        widget.list.first ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list.last ) == true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                if (widget.list.length == 1 &&
                                    (snapshot.data.documents[index]['equipment']
                                        .toString( )
                                        .contains(
                                        widget.list.first ) == true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                if (widget.list.length == 3 &&
                                    (snapshot.data.documents[index]['equipment']
                                        .toString( )
                                        .contains(
                                        widget.list.first ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[2] ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list.last ) == true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                if (widget.list.length == 4 &&
                                    (snapshot.data.documents[index]['equipment']
                                        .toString( )
                                        .contains(
                                        widget.list.first ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[2] ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[3] ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list.last ) == true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                if (widget.list.length == 5 &&
                                    (snapshot.data.documents[index]['equipment']
                                        .toString( )
                                        .contains(
                                        widget.list.first ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[2] ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[3] ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list[4] ) == true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains(
                                            widget.list.last ) == true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                if (widget.list.length == 0) {
                                  _posbottom = 40;
                                  return SizedBox( );
                                }
                                else {
                                  _posbottom = 40;
                                  return SizedBox( );
                                }
                              }
                              else if (widget.type.length != 0 &&
                                  widget.list.length == 0) {
                                if (widget.type.length == 2 &&
                                    (snapshot.data.documents[index]['type']
                                        .toString( )
                                        .contains(
                                        widget.type.first.toString( ) ) ==
                                        true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                } else if (widget.type.length == 1 &&
                                    (snapshot.data.documents[index]['type']
                                        .toString( )
                                        .contains(
                                        widget.type.first.toString( ) ) ==
                                        true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                } else if (widget.type.length == 3 &&
                                    (snapshot.data.documents[index]['type']
                                        .toString( )
                                        .contains(
                                        widget.type.first.toString( ) ) ==
                                        true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                } else if (widget.type.length == 4 &&
                                    (snapshot.data.documents[index]['type']
                                        .toString( )
                                        .contains(
                                        widget.type.first.toString( ) ) ==
                                        true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[3].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                } else if (widget.type.length == 5 &&
                                    (snapshot.data.documents[index]['type']
                                        .toString( )
                                        .contains(
                                        widget.type.first.toString( ) ) ==
                                        true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[3].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[4].toString( ) ) ==
                                            true &&
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last
                                                    .toString( ) ) == true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 0) {
                                  _posbottom = 40;
                                  return SizedBox( );
                                }
                                else {
                                  _posbottom = 40;
                                  return SizedBox( );
                                }
                              }
                              else if (widget.type.length != 0 &&
                                  widget.list.length != 0) {
                                if (widget.type.length == 3 &&
                                    widget.list.length == 5 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true &&
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true &&
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] ) ==
                                            true &&
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[4] ) ==
                                            true &&
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true &&
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true
                                            && snapshot.data
                                            .documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 2 &&
                                    widget.list.length == 5 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[4] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||

                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains( widget.type.last
                                                .toString( ) ) == true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 2 &&
                                    widget.list.length == 4 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||

                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains( widget.type.last
                                                .toString( ) ) == true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 3 &&
                                    widget.list.length == 2 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains( widget.type.last
                                                .toString( ) ) == true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 4 &&
                                    widget.list.length == 2 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[3].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains( widget.type.last
                                                .toString( ) ) == true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 4 &&
                                    widget.list.length == 5 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[4] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[3].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains( widget.type.last
                                                .toString( ) ) == true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 4 &&
                                    widget.list.length == 3 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[3].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains( widget.type.last
                                                .toString( ) ) == true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 3 &&
                                    widget.list.length == 4 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true
                                            || snapshot.data
                                            .documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 5 &&
                                    widget.list.length == 4 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[3].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[4].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true
                                            || snapshot.data
                                            .documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 5 &&
                                    widget.list.length == 3 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[3].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[4].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true
                                            || snapshot.data
                                            .documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 5 &&
                                    widget.list.length == 2 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[3].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[4].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true
                                            || snapshot.data
                                            .documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 5 &&
                                    widget.list.length == 1 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[3].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[4].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true
                                            || snapshot.data
                                            .documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 4 &&
                                    widget.list.length == 1 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[3].toString( ) ) ==
                                                true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true
                                            || snapshot.data
                                            .documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 3 &&
                                    widget.list.length == 1 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type[2].toString( ) ) ==
                                                true
                                            || snapshot.data
                                            .documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 1 &&
                                    widget.list.length == 5 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[4] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 1 &&
                                    widget.list.length == 4 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 1 &&
                                    widget.list.length == 3 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 2 &&
                                    widget.list.length == 3 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] ) ==
                                            true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last
                                                    .toString( ) ) == true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 2 &&
                                    widget.list.length == 1 &&
                                    (snapshot.data.documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last
                                                    .toString( ) ) == true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 1 &&
                                    widget.list.length == 2 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) &&
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 2 &&
                                    widget.list.length == 2 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ==
                                        true ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ==
                                            true) && (
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.first.toString( ) ) ==
                                            true ||
                                            snapshot.data
                                                .documents[index]['type']
                                                .toString( )
                                                .contains(
                                                widget.type.last
                                                    .toString( ) ) == true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 1 &&
                                    widget.list.length == 1 &&
                                    (snapshot.data.documents[index]['type']
                                        .toString( )
                                        .contains(
                                        widget.type.first.toString( ) ) ==
                                        true &&
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.first ) ==
                                            true)) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 3 &&
                                    widget.list.length == 3 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first ) ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last ) ||
                                        snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] )
                                    ) && (snapshot.data.documents[index]['type']
                                        .toString( )
                                        .contains(
                                        widget.type.first.toString( ) ) ==
                                        true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 4 &&
                                    widget.list.length == 4 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first )
                                        || snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last )
                                        || snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] )
                                        || snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] )
                                    ) && (snapshot.data.documents[index]['type']
                                        .toString( )
                                        .contains(
                                        widget.type.first.toString( ) ) ==
                                        true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[3].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) )))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                } else if (widget.type.length == 5 &&
                                    widget.list.length == 5 &&
                                    ((snapshot.data
                                        .documents[index]['equipment']
                                        .toString( )
                                        .contains( widget.list.first )
                                        || snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list.last )
                                        || snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[3] )
                                        || snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[4] )
                                        || snapshot.data
                                            .documents[index]['equipment']
                                            .toString( )
                                            .contains( widget.list[2] )
                                    ) && (snapshot.data.documents[index]['type']
                                        .toString( )
                                        .contains(
                                        widget.type.first.toString( ) ) ==
                                        true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[2].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[3].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type[4].toString( ) ) ==
                                            true ||
                                        snapshot.data.documents[index]['type']
                                            .toString( )
                                            .contains(
                                            widget.type.last.toString( ) ) ==
                                            true))) {
                                  AddMarker( snapshot.data
                                      .documents[index]
                                      .data );

                                  return _annonceList( snapshot.data
                                      .documents[index]
                                      .data );
                                }
                                else if (widget.type.length == 0 &&
                                    widget.list.length == 0) {
                                  _posbottom = 40;
                                  return SizedBox( );
                                }
                                else {
                                  _posbottom = 40;
                                  return SizedBox( );
                                }
                              }
                              else if (snapshot.data != null) {
                                AddMarker( snapshot.data
                                    .documents[index]
                                    .data );

                                return _annonceList( snapshot.data
                                    .documents[index]
                                    .data );
                              }
                              else {
                                _posbottom = 40;
                                return SizedBox( );
                              }
                            }
                            AddMarker(snapshot.data
                                .documents[index]
                                .data );

                            return _annonceList( snapshot.data
                                .documents[index]
                                .data );


                          }

                      );
                    }
                    else   if(snapshot.data==null) {

                      _posbottom = 40;
                      return SizedBox();

                    }
                    else {

                      _posbottom = 40;
                      return SizedBox();

                    }
                  }
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMap() {
    return
      GoogleMap(
        initialCameraPosition: CameraPosition(target:_initialPosition, zoom: 12.0 ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        onCameraMove: CameraMove,

        mapType: MapType.normal,

        markers: Set.from(markers),
      );
  }

  _annonceList(index) {

    return GestureDetector(
        onDoubleTap: ()=>{Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailAnnonce(annonceData: index,),
          ),
        )},

        onTap:() =>onCameraMove(LatLng(index['lang.lat'], index['lang.long']))
        ,
        child: Stack( children: [

          Center(
              child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  height: 125.0,
                  width: 350.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular( 10.0 ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          offset: Offset( 0.0, 4.0 ),
                          blurRadius: 10.0,
                        ),
                      ] ),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular( 10.0 ),
                          color: Theme.of(context).primaryColor ),
                      child: Row( children: [
                        Container(
                          width: 130.0,
                          decoration:BoxDecoration(
                            borderRadius: tr( "add_type" ) == "Type"?  BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ):BorderRadius.only(
                              topRight: Radius.circular(7),
                              bottomRight: Radius.circular(7),
                            ),
                          ),child: BlurHash(hash:index['blurhash'],image:index['images'][0],imageFit: BoxFit.cover,), ),
                        SizedBox( width: 5.0 ),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,

                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                index['titleTxt'],
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700 ),
                              ),
                              Text(
                                '${index['perNight']!=null
                                    ?index['perNight'].toString().replaceFirst('.0', ''):index['perMonth'].toString().replaceFirst('.0', '')} DT ',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600 ),
                              ),
                              SmoothStarRating(
                                allowHalfRating: true,
                                starCount: 5,
                                rating:1.2,
                                size: 20,
                                color: Theme
                                    .of( context )
                                    .accentColor,
                                borderColor: Theme
                                    .of( context )
                                    .accentColor,
                              ),
                            ] )
                      ] ) ) ) )
        ] ) );
  }




  void onCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });

  }
  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
  }
  getSearch() async {
    var location;

    location =
        Location(_initialPosition.latitude, _initialPosition.longitude);

    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: "AIzaSyDpa8n8zgXtd20x307hhdqji_Z-z9rN-Z8",
      onError: onError,
      mode: Mode.overlay,
      language: "fr",
      components: [Component(Component.country, "TN")],
      location: location,
    );

  }



}
