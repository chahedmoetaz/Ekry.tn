import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:blurhash/blurhash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_picker/flutter_map_picker.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';
import 'package:provider/provider.dart';
import 'package:tn/Filter_page/filter_liste.dart';
import 'package:tn/Filter_page/silver_view.dart';
import 'package:tn/Filter_page/silver_view_m.dart';
import 'package:tn/Widgets/Images_wid.dart';
import 'package:tn/Widgets/calendar_popup_view.dart';
import 'package:tn/Widgets/custom_alert_dialog.dart';
import 'package:tn/Widgets/custom_flat_button.dart';
import 'package:tn/provider/add_map_provider.dart';
import 'package:tn/provider/roomp.dart';

import 'package:validated/validated.dart' as validate;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:easy_localization/public.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter/widgets.dart';

import 'package:tn/Screens/singin-singup.dart';
import 'package:tn/Widgets/annonce_edit_list.dart';

import 'package:tn/Widgets/custom_text_field.dart';
import 'package:tn/Widgets/detail_annonce.dart';

import 'package:tn/services/auth.dart';
import 'package:tn/services/validator.dart';


class Add extends StatefulWidget {

  @override
  _AddState createState() => _AddState( );
}


class _AddState extends State<Add> {

  final dbRef =  FirebaseDatabase.instance.reference().child("annonces");

  List<PopularFilterListData> popularFilterListData =
      PopularFilterListData.popularList;
  final TextEditingController _desc = new TextEditingController( );
  final TextEditingController _title = new TextEditingController( );

  LatLng inisial;

  List<String> listee=List();

  LatLng langlan;

  FirebaseVisionLabelDetector detector = FirebaseVisionLabelDetector.instance;

  String exeption;

  bool _blackVisible= false;

  String name;

  var lists;

  String userid;

  var items;

  String blurHash;

  File file;

  String gouver,rue,country,localy,resultt;

  bool blockk=false;

  NumberOfRooms get numberOfRooms => _numberOfRooms;
  Property _selectedProperty = Property.HOUSE;

  List<File> _imageList=List<File>();
  List<Object> images = List<Object>();
  Future<File> _imageFile;
  // image URL String list from Firebase storage.
  List<String> _imageStringList = List<String>.generate(6,(i) => '');

//  getter
  Property get selectedProperty => _selectedProperty;


  NumberOfRooms _numberOfRooms = NumberOfRooms.ONE;


  int groupe = 1;



  void f(int a) {
    setState( () {
      groupe = a;
    } );
  }

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add( const Duration( days: 7 ) );
  int _n = 0;
  int _nP = 0;
  double _nS = 0;

  void minus() {
    setState( () {
      if (_n != 0)
        _n--;
    } );
  }

  void minusS() {
    setState( () {
      if (_nS > 0)
        _nS -= 0.5;
    } );
  }

  void add() {
    setState( () {
      _n++;
    } );
  }

  void addS() {
    setState( () {
      _nS += 0.5;
    } );
  }

  void addP() {
    setState( () {
      _nP++;
    } );
  }

  void minusP() {
    setState( () {
      if (_nP != 0)
        _nP--;
    } );
  }

  double distValueJ = 50;
  double distValueM = 300;

  String result="Numero, Rue, Code Postal Ville - Tunisie";
  void showDemoDialog({BuildContext context}) {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) =>
          CalendarPopupView(
            barrierDismissible: true,
            minimumDate: DateTime.now( ),
            //  maximumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
            initialEndDate: endDate.toLocal( ),
            initialStartDate: startDate.toLocal( ),
            onApplyClick: (DateTime startData, DateTime endData) {
              setState( () {
                if (startData != null && endData != null) {
                  startDate = startData;
                  endDate = endData;
                }
              } );
            },
            onCancelClick: () {},
          ),
    );
  }

  var _p = EdgeInsets.symmetric( horizontal: 15 );



  bool _b;

  TextEditingController _phone = TextEditingController( );

  bool usernull;

  final Future<FirebaseUser> user = Auth.getCurrentFirebaseUser( );

  String phone;

  bool always=false;

  @override
  void initState() {
    _visible();
    super.initState();

  }

  Future<bool> _visible() async {

    FirebaseUser user = await FirebaseAuth.instance.currentUser( );

    if (user == null)
      setState( () {
        usernull = true;
      } );
    else {
      setState( () {

        usernull = false;
      } );

      await Firestore.instance.collection( 'users' ).where(
          'userID', isEqualTo: user.uid ).getDocuments( ).then( (query) {
        setState(() {
          phone = query.documents[0].data['phoneNumber'].toString();
          userid=user.uid;
        });

        if (phone != '')
          setState( () {

            _b = true;
            _a = true;

            always = true;
          } );
        else if (phone=='')
          setState( () {
            _b = false;
            _a = true;
            always = true;
          } );
        else if(query==null) setState(() {
          Auth.signOut();
          usernull = true;
        });
      } );
    }
    return always;
  }

  VoidCallback onBackPress;
  bool _a;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Theme
            .of( context )
            .backgroundColor,
        body: usernull == true
            ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/connect.png'),
            CustomFlatButton(
              title: tr( "user_body_conn" ),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Colors.white,
              onPressed: () =>
                  Navigator.push( context,
                      MaterialPageRoute( builder: (context) => MyHomePage( ) ) )
                      .then( (user)  {
                     _visible();
                  } ),
              splashColor: Colors.black12,
              borderColor: Theme.of(context).accentColor,
              borderWidth: 0,
              color: Theme.of(context).accentColor,
            ),

          ],
        )
            : always==false?
        SpinKitRotatingCircle(
          color: Colors.teal,
          size: 50.0,
        )
            : _b == false ?
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(40)),
              Image.asset( "assets/add.png" ),
              Padding(padding: EdgeInsets.all(5)),
              Padding(
                padding: _p,
                child:tr( "add_type" ) == "Type"? Wrap(direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: <Widget>[
                    Container(
                      height: 40, width: 40,
                      child: Image.asset( "assets/flag.png" ),
                    ),
                    Text( "+216", textAlign: TextAlign.end,
                        style: TextStyle( fontSize: 20, ) ),

                    Container(
                      width: MediaQuery
                          .of( context )
                          .size
                          .width / 2,
                      child: CustomTextField(
                        baseColor: Colors.grey,
                        borderColor: Colors.grey[400],
                        errorColor: Colors.red,
                        controller: _phone,

                        hint: tr( 'tel' ),
                        validator: Validator.validateNumber,
                        inputType: TextInputType.number,
                      ),
                    ),
                  ],

                ):Wrap(direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: <Widget>[
                    Container(
                      width: MediaQuery
                          .of( context )
                          .size
                          .width / 2,
                      child: CustomTextField(
                        baseColor: Colors.grey,
                        borderColor: Colors.grey[400],
                        errorColor: Colors.red,
                        controller: _phone,

                        hint: tr( 'tel' ),
                        validator: Validator.validateNumber,
                        inputType: TextInputType.number,
                      ),
                    ),
                    Text( "216+", textAlign: TextAlign.end,
                        style: TextStyle( fontSize: 20, ) ),
                    Container(
                      height: 40, width: 40,
                      child: Image.asset( "assets/flag.png" ),
                    ),



                  ],

                ),
              ),
              Padding(padding: EdgeInsets.all(5)),
              CustomFlatButton(
                title: tr( "save" ),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: Colors.white,
                onPressed: () {
                  _sendCodeToPhoneNumber( );
                },
                splashColor: Colors.black12,
                borderColor: Theme.of(context).accentColor,
                borderWidth: 0,
                color: Theme.of(context).accentColor,
              ),

            ],
          ),
        ) :
        _a==false?
        WillPopScope(
          onWillPop: onBackPress,
          child: AbsorbPointer(
            absorbing: blockk ,ignoringSemantics: blockk,
            child: SafeArea(
              child: Stack(
                children: [
                  Offstage(
                    offstage: !_blackVisible,
                    child: GestureDetector(
                      onTap: () {},
                      child: AnimatedOpacity(
                        opacity: _blackVisible ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.ease,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  ListView(
                    children: <Widget>[
                      Stack(
                        children: [
                          Align(alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(Icons.clear,size: 30,),
                              onPressed: ()=>{onBackPress,setState((){
                                _a=true;

                              })},
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  alignment: Alignment.topCenter,
                                  child: Text( tr( "add_ann" ),
                                      style:
                                      TextStyle( fontSize: 22,
                                          fontWeight: FontWeight.w700 ) ) ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "add_type" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only( top: 5 ),
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "add_st" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.grey )
                              : TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: Colors.grey ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      getHome( context ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "persones" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only( top: 5 ),
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "add_sp" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.grey )
                              : TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: Colors.grey ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric( vertical: 10 ),
                        height: 30,
                        child: new Center(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly,
                            children: <Widget>[
                              new FloatingActionButton(
                                onPressed: minusP,
                                child: new Icon(
                                    const IconData( 0xe15b,
                                        fontFamily: 'MaterialIcons' ),
                                    color: Theme
                                        .of( context )
                                        .primaryColor
                                ),
                                backgroundColor: Theme
                                    .of( context )
                                    .cursorColor, ),
                              new Text( '$_nP',
                                  style: new TextStyle(
                                      fontSize: 30.0 ) ),
                              new FloatingActionButton(
                                onPressed: addP,
                                child: new Icon(
                                  Icons.add, color: Theme
                                    .of( context )
                                    .primaryColor, ),
                                backgroundColor: Theme
                                    .of( context )
                                    .cursorColor, ),

                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "add_cham" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only( top: 5 ),
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "add_sc" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.grey )
                              : TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: Colors.grey ),
                        ),
                      ),
                      getRoom( context ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "lit" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric( vertical: 10 ),
                        height: 30,
                        child: new Center(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly,
                            children: <Widget>[
                              new FloatingActionButton(
                                onPressed: minus,
                                child: new Icon(
                                    const IconData( 0xe15b,
                                        fontFamily: 'MaterialIcons' ),
                                    color: Theme
                                        .of( context )
                                        .primaryColor
                                ),
                                backgroundColor: Theme
                                    .of( context )
                                    .cursorColor, ),
                              new Text( '$_n',
                                  style: new TextStyle(
                                      fontSize: 30.0 ) ),
                              new FloatingActionButton(
                                onPressed: add,
                                child: new Icon(
                                  Icons.add, color: Theme
                                    .of( context )
                                    .primaryColor, ),
                                backgroundColor: Theme
                                    .of( context )
                                    .cursorColor, ),

                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "sbain" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric( vertical: 10 ),
                        height: 30,
                        child: new Center(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly,
                            children: <Widget>[
                              new FloatingActionButton(
                                onPressed: minusS,
                                child: new Icon(
                                    const IconData( 0xe15b,
                                        fontFamily: 'MaterialIcons' ),
                                    color: Theme
                                        .of( context )
                                        .primaryColor
                                ),
                                backgroundColor: Theme
                                    .of( context )
                                    .cursorColor, ),
                              new Text( '$_nS',
                                  style: new TextStyle(
                                      fontSize: 30.0 ) ),
                              new FloatingActionButton(
                                onPressed: addS,
                                child: new Icon(
                                  Icons.add, color: Theme
                                    .of( context )
                                    .primaryColor, ),
                                backgroundColor: Theme
                                    .of( context )
                                    .cursorColor, ),

                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        margin: EdgeInsets.only( top: 20, bottom: 10 ),
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "equip" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),
                      Container(
                        padding: _p,
                        child: Column(
                          children: getPList( ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),


                      Container(
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "add_img" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only( top: 5, bottom: 10 ),
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "add_ei" ),
                          style: tr( "add_ei" ) == "Type"
                              ? TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.grey )
                              : TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: Colors.grey ),
                        ),
                      ),
                      Container( width: MediaQuery
                          .of( context )
                          .size
                          .width, height: MediaQuery
                          .of( context )
                          .size
                          .height / 3 + 50,
                        child:imagess(),
                      ),

                      Container(
                        margin: EdgeInsets.only( top: 15, bottom: 5 ),
                        padding: _p,

                        child: Text(
                          tr( "loca" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),

                      getPosition(),

                      Container(
                        margin: EdgeInsets.symmetric( vertical: 10 ),
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "dispo" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),

                      Container(

                        margin: EdgeInsets.all( 10 ),
                        padding: _p,
                        child: InkWell(
                            onTap: () {
                              FocusScope.of( context ).requestFocus(
                                  FocusNode( ) );
                              // setState(() {
                              //   isDatePopupOpen = true;
                              // });
                              showDemoDialog( context: context );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .start
                              ,
                              children: <Widget>[
                                Icon(
                                  Icons.calendar_today, size: 30, ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center,
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        tr( "edate" ),
                                        style: tr(
                                            "add_type" ) == "Type"
                                            ? TextStyle(
                                            fontWeight: FontWeight
                                                .w700, fontSize: 18 )
                                            : TextStyle(
                                            fontWeight: FontWeight
                                                .w800, fontSize: 22 ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      '${tr(DateFormat('EEE')
                                          .format(startDate))},${DateFormat('dd')
                                          .format(startDate)} ${tr(DateFormat('MMM')
                                          .format(startDate))} - ${tr(DateFormat('EEE')
                                          .format(endDate))},${DateFormat('dd')
                                          .format(endDate)} ${tr(DateFormat('MMM')
                                          .format(endDate))}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )

                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only( top: 20, bottom: 10 ),
                        padding: _p,

                        child: Text(
                          tr( "add_titre" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),
                      Container(
                          padding: _p,

                          margin: EdgeInsets.symmetric( horizontal: 10 ),
                          child:CustomTextField(
                            baseColor: Colors.grey,
                            borderColor: Colors.grey[400],
                            errorColor: Colors.red,
                            controller: _title,
                            hint: tr("add_title"),
                            validator: Validator.validateName,
                            inputType: TextInputType.text,
                          )
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        margin: EdgeInsets.only( top: 20, bottom: 10 ),
                        padding: _p,
                        alignment: tr( "add_type" ) == "Type"
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          tr( "desc" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),
                      Container(
                        padding: _p,

                        margin: EdgeInsets.symmetric( horizontal: 10 ),


                        child: CustomTextField(
                          baseColor: Colors.grey,
                          borderColor: Colors.grey[400],
                          errorColor: Colors.grey[400],
                          controller: _desc,
                          hint: '${tr("desc")} ...',
                          inputType: TextInputType.multiline,
                          validator: Validator.validateEmail,
                        )
                        ,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: _p,

                        child: Text(
                          tr( "prix" ),
                          style: tr( "add_type" ) == "Type"
                              ? TextStyle( fontWeight: FontWeight.w700,
                              fontSize: 20 )
                              : TextStyle( fontWeight: FontWeight.w800,
                              fontSize: 22 ),
                        ),
                      ),

                      Container(
                        padding: _p,

                        child: Container(
                          margin: EdgeInsets.only( top: 10 ),
                          padding: _p,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment
                                .start,
                            children: <Widget>[
                              Text( tr( "pj" ),
                                style: tr( "add_type" ) ==
                                    "Type"
                                    ? TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.grey )
                                    : TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Colors.grey ),
                              ),
                              Radio( value: 1,
                                  groupValue: groupe,
                                  onChanged: (v) {
                                    f( v );

                                  } ),
                              Text( tr( "pm" ),
                                style: tr( "add_type" ) ==
                                    "Type"
                                    ? TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.grey )
                                    : TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Colors.grey ),
                              ),
                              Radio( value: 2,
                                groupValue: groupe,
                                onChanged: (v) {


                                  f( v );
                                }, ),

                            ],
                          ),
                        ),
                      ),

                      groupe == 1
                          ?
                      SliderView(
                        distValue: distValueJ,
                        onChangedistValue: (double value) {
                          distValueJ = value;
                        },
                      )
                          : SliderViewM(
                        distValue: distValueM,
                        onChangedistValue: (double value) {
                          distValueM = value;
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.all( 15 ),
                        child: InkWell(
                          onTap: ()
                          async {

                            if(_validateAnnonceData()) {
                              SystemChannels.textInput.invokeMethod( 'TextInput.hide' );
                              await _AddAnnonce();

                            }
                          },
                          child: Container(
                            padding: _p,
                            height: 60,
                            width: MediaQuery
                                .of( context )
                                .size
                                .width - 50,
                            decoration: BoxDecoration(
                                color: Theme
                                    .of( context )
                                    .accentColor,
                                borderRadius: BorderRadius.circular(
                                    15 ) ),
                            child: Center(
                              child: Text(
                                tr( "add_btn" ),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600 ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            :
        Scaffold(
            backgroundColor: Theme
                .of( context )
                .backgroundColor,
            appBar: AppBar(leading: SizedBox(),
              title: Text( tr( "add_edit" ) ),
              centerTitle: true,
              backgroundColor: Theme
                  .of( context )
                  .appBarTheme
                  .color,
              elevation: Theme
                  .of( context )
                  .appBarTheme
                  .elevation,),
            body:StreamBuilder(
              stream: Firestore.instance.collection('annonces')
                  .where('userId',isEqualTo: userid).orderBy('annonceID').snapshots(),
              builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(snapshot.hasError)
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                        Theme.of(context).accentColor,
                      ),
                    ),
                  );
                else if(!snapshot.hasData||snapshot.data.documents.length==0)
                  return Stack(
                    children: [
                      Align(
                          alignment:Alignment.topCenter,child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/Ajouter.png'),
                      )),
                      Padding(
                        padding: const EdgeInsets.only(bottom:25.0),
                        child: Align(
                            alignment:Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all( 15 ),
                              child: CustomFlatButton(
                                title: tr( "add_btn" ),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                textColor: Colors.white,
                                onPressed: () =>
                                    setState( () {
                                      _imageStringList =
                                      List<String>.generate(
                                          6, (i) => '' );
                                      listee.clear();
                                      images.clear();
                                      _imageList.clear( );
                                      distValueJ = 50;
                                      distValueM = 300;
                                      groupe=1;
                                      _selectedProperty = Property.HOUSE;
                                      _numberOfRooms=NumberOfRooms.ONE;
                                      _a = false;
                                    } ),
                                splashColor: Colors.black12,
                                borderColor: Theme
                                    .of( context )
                                    .accentColor,
                                borderWidth: 0,
                                color: Theme
                                    .of( context )
                                    .accentColor,
                              ),
                            )
                        ),
                      )
                    ],
                  );
                else {

                  return Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom:50.0),
                        child: ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            Timestamp t = snapshot.data.documents[index]['a'];
                            DateTime d = t.toDate();
                            print(startDate.difference(d).inDays);

                            return  AnnonceEditList(
                              callback:  () {Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailAnnonce(annonceData: snapshot.data.documents[index].data,),
                                ),
                              );},
                              annonceid:snapshot.data.documents[index]['annonceID'],
                              hash:snapshot.data.documents[index]['blurhash'],
                              id: snapshot.data.documents[index]['images'][0],
                            );
                          },
                        ),
                      ),
                      Align(
                          alignment:Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all( 15 ),
                            child: CustomFlatButton(
                              title: tr( "add_aut" ),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              textColor: Colors.white,
                              onPressed: () =>
                                  setState( () {
                                    popularFilterListData.forEach((element) {element.isSelected=false;});
                                    _imageStringList =
                                    List<String>.generate(
                                        6, (i) => '' );
                                    listee.clear();
                                    images.clear();
                                    _imageList.clear( );
                                    distValueJ = 50;
                                    distValueM = 300;
                                    groupe=1;
                                    _selectedProperty = Property.HOUSE;
                                    _numberOfRooms=NumberOfRooms.ONE;
                                    _a = false;
                                  } ),
                              splashColor: Colors.black12,
                              borderColor: Theme
                                  .of( context )
                                  .accentColor,
                              borderWidth: 0,
                              color: Theme
                                  .of( context )
                                  .accentColor,
                            ),
                          )
                      )
                    ],
                  );
                }
              },
            )
        )
    );
  }






  /// Sends the code to the specified phone number.

  Future<void> _sendCodeToPhoneNumber() async {
    await Firestore.instance.collection( '/users' ).where(
        "phoneNumber", isEqualTo: _phone.text )
        .getDocuments( ).then( (value) async {
      if (value.documents.isNotEmpty) {
        Fluttertoast.showToast(msg: tr('phonexx'),toastLength: Toast.LENGTH_SHORT
            ,backgroundColor: Theme.of(context).backgroundColor,textColor: Theme.of(context).cursorColor,gravity: ToastGravity.BOTTOM);

        _phone.clear( );
      } else {
        setState( () {
          _b = true;

          always = true;
        } );
        await FirebaseAuth.instance.currentUser( ).then( (val) {
          FirebaseAuth.instance.currentUser( ).then( (user) {
            Firestore.instance.collection( '/users' )
                .where( 'userID', isEqualTo: user.uid )
                .getDocuments()
                .then( (doc) =>
                Firestore.instance.document( '/users/${user.uid}' )
                    .updateData( {'phoneNumber': _phone.text} )
                    .then( (val) {

                })
                    .catchError( (e) => print( e ) )
            ).catchError( (e) => print( e ) );
          } ).catchError( (e) => print( e ) );
        } ).catchError( (e) => print( e ) );
      }
    } );
    print( "phone:${_phone.text}" );
  }

  getHome(BuildContext context) {
    changePropertyType(Property type) {
      setState( () {
        _selectedProperty = type;
      } );
    }
    // ignore: non_constant_identifier_names
    PropertyType(String image, String title) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular( 10 ),
            boxShadow: [
              BoxShadow(
                  color: selectedProperty == Property.HOUSE &&
                      title == tr( "Maison" )
                      || selectedProperty == Property.Appartement &&
                          title == tr( "Appartement" )
                      || selectedProperty == Property.studio &&
                          title == tr("Studio")
                      || selectedProperty == Property.Villa &&
                          title == tr( "Villa" )

                      || selectedProperty == Property.bungalow &&
                          title == tr( "Bungalow" )
                      ? Theme
                      .of( context )
                      .accentColor : Colors.grey[400],
                  offset: Offset( 5, 5 ), blurRadius: 1 ),
            ] ),
        height: 240,
        width: 220,
        child: Padding(
          padding: const EdgeInsets.all( 4 ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset( "assets/$image" ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ),
      );
    }
    return Container(
        height: 260,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all( 10 ),
              child: GestureDetector(
                  onTap: () {
                    changePropertyType( Property.HOUSE );
                  },
                  child: PropertyType(
                    "maison.png",
                    tr( "Maison" ),
                  ) ),
            ),
            Padding(
              padding: const EdgeInsets.all( 10 ),
              child: GestureDetector(
                  onTap: () {
                    changePropertyType( Property.Appartement );
                  },
                  child: PropertyType(
                    "appartement.png",

                    tr( "Appartement" ),
                  ) ),
            ),
            Padding(
              padding: const EdgeInsets.all( 10 ),
              child: GestureDetector(
                  onTap: () {
                    changePropertyType( Property.Villa );
                  },
                  child: PropertyType(
                    "villa.png",

                    tr( "Villa" ),
                  ) ),
            ),

            Padding(
              padding: const EdgeInsets.all( 10 ),
              child: GestureDetector(
                  onTap: () {
                    changePropertyType( Property.studio );
                  },
                  child: PropertyType(
                    "studio.png",

                    tr( "studio" ),
                  ) ),
            ),
            Padding(
              padding: const EdgeInsets.all( 10 ),
              child: GestureDetector(
                  onTap: () {
                    changePropertyType( Property.bungalow );
                  },
                  child: PropertyType(
                    "bungalow.png",

                    tr( "bungalow" ),
                  ) ),
            ),
          ],
        ) );
  }


  List<Widget> getPList() {

    List<Widget> noList = <Widget>[];
    int count = 0;
    const int columnCount = 2;

    for (int i = 0; i < popularFilterListData.length / columnCount; i++) {

      List<Widget> listUI = <Widget>[];

      for (int i = 0; i < columnCount; i++) {
        try {
          final  PopularFilterListData date = popularFilterListData[count];

          listUI.add( Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(
                        Radius.circular( 4.0 ) ),
                    onTap: () {
                      setState( () {

                        date.isSelected = !date.isSelected;
                        if(date.isSelected==true){
                          setState(() {
                            date.isSelected=true;
                          });
                          listee.add(date.titleTxt);

                        }
                        else {listee.removeWhere((element)=>
                        element==date.titleTxt);
                        setState(() {
                          date.isSelected=false;
                        });
                        }
                      } );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all( 8.0 ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            date.isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: date.isSelected
                                ? Colors.teal
                                : Colors.grey.withOpacity( 0.6 ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                              tr(
                                  date.titleTxt ),
                              style: tr( "add_type" ) == "Type"
                                  ? TextStyle( fontWeight: FontWeight.w400,
                                fontSize: date.titleTxt.length >= 14
                                    ? 15
                                    : 14, )
                                  : TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 17 ),
                              textAlign: TextAlign.end
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ) );
          count += 1;
        } catch (e) {
          print( e );
        }

      }

      noList.add( Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: listUI,
      ) );
    }

    return noList;
  }

  getRoom(BuildContext context) {
    changeNumberOfRooms(NumberOfRooms number) {
      setState( () {
        _numberOfRooms = number;
      } );
    }
    // ignore: non_constant_identifier_names
    Rooms(int number) {
      return Container(
        decoration: BoxDecoration(
            color: numberOfRooms == NumberOfRooms.ONE && number == 1 ||
                numberOfRooms == NumberOfRooms.TWO && number == 2
                || numberOfRooms == NumberOfRooms.THREE && number == 3 ||
                numberOfRooms == NumberOfRooms.FOUR && number == 4 ||
                numberOfRooms == NumberOfRooms.FIVE && number == 5 ||
                numberOfRooms == NumberOfRooms.MORE && number == 6
                ? Theme
                .of( context )
                .accentColor : Colors.grey[200],
            borderRadius: BorderRadius.circular( 8 )
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB( 18, 10, 18, 10 ),
          child: Text( number == 6 ? '+' : number.toString( ), style: TextStyle(
            color: numberOfRooms == NumberOfRooms.ONE && number == 1 ||
                numberOfRooms == NumberOfRooms.TWO && number == 2 ||
                numberOfRooms == NumberOfRooms.THREE && number == 3 ||
                numberOfRooms == NumberOfRooms.FOUR && number == 4 ||
                numberOfRooms == NumberOfRooms.FIVE && number == 5 ||
                numberOfRooms == NumberOfRooms.MORE && number == 6 ? Colors
                .white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w400, ), ),
        ),
      );
    }


    return Padding(
      padding: const EdgeInsets.all( 10 ),
      child: Container(
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all( 4.0 ),
              child: GestureDetector(
                  onTap: () {
                    changeNumberOfRooms( NumberOfRooms.ONE );
                  },
                  child: Rooms( 1 ) ),
            ),

            Padding(
              padding: const EdgeInsets.all( 4.0 ),
              child: GestureDetector(
                  onTap: () {
                    changeNumberOfRooms( NumberOfRooms.TWO );
                  },
                  child: Rooms( 2 ) ),
            ),

            Padding(
              padding: const EdgeInsets.all( 4.0 ),
              child: GestureDetector(
                  onTap: () {
                    changeNumberOfRooms( NumberOfRooms.THREE );
                  },
                  child: Rooms( 3 ) ),
            ),

            Padding(
              padding: const EdgeInsets.all( 4.0 ),
              child: GestureDetector(
                  onTap: () {
                    changeNumberOfRooms( NumberOfRooms.FOUR );
                  },
                  child: Rooms( 4 ) ),
            ),

            Padding(
              padding: const EdgeInsets.all( 4.0 ),
              child: GestureDetector(
                  onTap: () {
                    changeNumberOfRooms( NumberOfRooms.FIVE );
                  },
                  child: Rooms( 5 ) ),
            ),
            Padding(
              padding: const EdgeInsets.all( 4.0 ),
              child: GestureDetector(
                  onTap: () {
                    changeNumberOfRooms( NumberOfRooms.MORE );
                  },
                  child: Rooms( 6 ) ),
            ),


          ],
        ),
      ),
    );
  }

  int _uploadImagePosition = 0;
  Future<void> _uploadUserImages(File imageFile, String annonceId,
      String imageCount, int position, FirebaseUser firebaseUser) async {
    try {
      String fileName = 'Annonces/$annonceId/$imageCount'; //userID+imageCount;
      StorageReference reference = FirebaseStorage.instance.ref().child(
          fileName );
      setState(() {
        file=_imageList[0];
      });
      StorageUploadTask uploadTask = reference.putFile( imageFile );
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      storageTaskSnapshot.ref.getDownloadURL( ).then( (downloadUrl) {
        _imageStringList[position] = downloadUrl;

        setState(() {
          _imageStringList.add(downloadUrl);
        });
        _uploadImagePosition++;
        if (_uploadImagePosition < _imageList.length) {
          _uploadUserImages( _imageList[_uploadImagePosition], annonceId,
              'image$_uploadImagePosition', _uploadImagePosition,
              firebaseUser );
        }
        else _addImages(firebaseUser,annonceId);
      }, onError: (err) {
        setState( () {
          print( err );
        } );
      } );
    } catch (e) {
      print( e.message );
    }
  }


  Future<void> _addAnnonceImagesToFirebaseStorage(String documentID,FirebaseUser user) async {
    try {
      if (_imageList != null && _imageList.length > 0) {
        _uploadUserImages( _imageList[_uploadImagePosition], documentID,
            'image$_uploadImagePosition', _uploadImagePosition, user );
      }
    } catch (e) {
      print( e.message );
    }
  }

  bool isFinishedUpload = false;

  getPosition()  {
    final appState = Provider.of<AddProvider>( context );



    inisial=appState.initialPosition;

    return Container(
        margin: EdgeInsets.only( bottom: 10 ),
        padding: EdgeInsets.symmetric( horizontal: 24 ),
        child: appState.initialPosition == null
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
                appState.locationServiceActive == false ?
                Text( tr(
                    "serviceloc" ), style: TextStyle( color: Colors
                    .grey, fontSize: 18 ), ) : Container( ),
              ],
            )
        )
            : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () =>
                {

                  getPlace( inisial)
                },
                child: Icon( Icons.map ), ),
              SizedBox( height: 10, ),
              validate.contains( result, "Tunisie" ) == false
                  ? Wrap( crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  children: <Widget>[
                    Image.asset(
                      "assets/flag.png", height: 25, width: 30, ),
                    Text( tr(
                        "dispo_tunisie" ),
                      style: TextStyle( color: Colors.red,
                          fontSize: 18 ),
                    )
                  ] )
                  :result.isEmpty?Text(' Numero, Rue, Code Postal Ville - Tunisie',
                style: TextStyle( color: Colors.grey, fontSize: 18 ), ): Text( result,
                style: TextStyle( color: Colors.grey, fontSize: 18 ), )
            ]
        )
    );
  }



  getPlace(LatLng inisial) async {
    PlacePickerResult resiltt = await Navigator.push(
        context, MaterialPageRoute( builder: (context) =>
        PlacePickerScreen(
          googlePlacesApiKey: "AIzaSyDpa8n8zgXtd20x307hhdqji_Z-z9rN-Z8",
          initialPosition: inisial,
          mainColor: Colors.teal,
          mapStrings: tr( "add_type" ) == "Type"
              ? MapPickerStrings.english( )
              : MapPickerStrings.arabe( ),
          placeAutoCompleteLanguage: "fr",
        ) ) );

    if (resiltt.address.contains( 'Unnamed Road' ) == true) {
      setState( () {
        result = resiltt.address.replaceAll( 'Unnamed Road, ', '' );
        resultt=result;
        rue=null;
        resultt=resultt.replaceAll(', Tunisie', '');
        gouver=resultt.substring(resultt.lastIndexOf(', ')+1,resultt.length);
        resultt=resultt.replaceRange(resultt.lastIndexOf(','),resultt.length,'');
        localy=resultt;
        country="Tunisie";
      } );


    }
    else if (resiltt.address.contains( 'Unnamed Road' ) == false) {
      setState( () {
        result = resiltt.address;
        langlan=resiltt.latLng;
        resultt=result;
        country="Tunisie";
        resultt=resultt.replaceAll(', Tunisie', '');
        gouver=resultt.substring(resultt.lastIndexOf(', ')+1,resultt.length);
        resultt=resultt.replaceRange(resultt.lastIndexOf(','),resultt.length,'');
        localy=resultt.substring(resultt.lastIndexOf(', ')+1,resultt.length);
        resultt=resultt.replaceRange(resultt.lastIndexOf(','),resultt.length,'');
        rue=resultt;

      } );

    }
    else setState((){
      result= 'Numero, Rue, Code Postal Ville - Tunisie';
      });
  }


  imagess() {
    setState( () {

      images.add( "Add Image" );
      images.add( "Add Image" );
      images.add( "Add Image" );
      images.add( "Add Image" );
      images.add( "Add Image" );
      images.add( "Add Image" );
    } );

    return Column(
      children: <Widget>[
        Expanded(
          child: buildGridView( ),
        ),
      ],

    );
  }

  Widget buildGridView() {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 3,semanticChildCount: 2,
      childAspectRatio: 1,
      children: List.generate(images.length, (index) {
        if (images[index] is ImageUploadModel) {
          ImageUploadModel uploadModel = images[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                Image.file(
                  uploadModel.imageFile,
                  width: 300,
                  height: 300,
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      size: 20,
                      color: Colors.red,
                    ),
                    onTap: () {
                      setState(() {
                        images.replaceRange(index, index + 1, ['Add Image']);
                        _imageList.removeLast();

                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Card(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _onAddImageClick(index);
              },
            ),
          );
        }
      }),
    );
  }

  Future _onAddImageClick(int index) async {
    setState(() {
      // ignore: deprecated_member_use
      _imageFile =ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 85,maxHeight: 300,maxWidth: 300);
      getFileImage(index);
    });
  }

  void getFileImage(int index) async {
//    var dir = await path_provider.getTemporaryDirectory();
    await _imageFile.then((file){
      setState(() {
        print(file);

        if(file!=null) {
          bool truee=true;
          detector.detectFromBinary(file?.readAsBytesSync()).then((value){
            value.forEach((element) {if(element.label.contains("ScreenShot")||element.label.contains("Screenshot")||element.label.contains("Mobile phone")
                ||element.label.contains("Food")||element.label.contains("Fun")||element.label.contains("Bus")||element.label.contains("bus")
                ||element.label.contains("Dog")||element.label.contains("Cat")||element.label.contains("Car")||element.label.contains("car") ||element.label.contains("Web Page")
                ||element.label.contains("Paper")||element.label.contains("Selfie")||element.label.contains("Mouth"))
              truee=false;
            });

            if(truee==false){
              exeption=tr("vimage");
              _showErrorAlert(
                title:tr("eimage"),
                content: exeption,
                onPressed: _changeBlackVisible,
              );

            }
            else {
              print(value[0].label);
              _imageList.add(file);
              setState(() {
                ImageUploadModel imageUpload = new ImageUploadModel( );
                imageUpload.isUploaded = false;
                imageUpload.uploading = false;
                imageUpload.imageFile = file;
                imageUpload.imageUrl = '';
                images.replaceRange( index, index + 1, [imageUpload] );
              });
            }
          });

        }
      });
    });
  }


  void _showErrorAlert({String title, String content, VoidCallback onPressed}) {
    Platform.isIOS?
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          content: content,
          title: title,
          onPressed: onPressed,
        );
      },
    ):showDialog(context: context,builder: (contect)=>AlertDialog(content:Text(content),title: Text(title),actions: <Widget>[FlatButton(
      child: Text(tr("ok"),),
      onPressed: () => Navigator.of(context).pop(),
    )]));
  }


  bool _validateAnnonceData() {
    String alertString = '';


    if (_title.text.trim() == '') {

      if (alertString.trim() != '') {
        alertString = alertString+ '\n\n';
      }
      alertString = alertString+ tr('vtitle');

    }


    if (groupe == 1)
      print( "$distValueJ" );
    else if (groupe == 2 &&((startDate.month != endDate.month ||
        startDate.year != endDate.year)&&endDate.difference(startDate).inDays>=28))
      print( "$distValueM" );

    else{
      if (alertString.trim() != '') {
        alertString = alertString+ '\n\n';
      }
      alertString = alertString+ tr('verifdate');
    }

    if (validate.contains( result, "Tunisie") == false  || langlan==null){
      if (alertString.trim() != '') {
        alertString = alertString+ '\n\n';
      }
      alertString = alertString+ tr('vadress');
    }
    if (_imageList.length == 0){
      if (alertString.trim() != '') {
        alertString = alertString+ '\n\n';
      }
      alertString = alertString+ tr('pimage');
    }



    if (alertString.trim() != '') {
      showDialogWithText(alertString);
      return false;
    }else {
      return true;
    }
  }

  showDialogWithText(String textMessage) {
    Platform.isIOS
        ?showCupertinoDialog(context: context, builder: (context){
      return CupertinoAlertDialog(
        content: Text(textMessage),
      );
    }
    ):showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(textMessage),
          );
        }
    );
  }

  // ignore: non_constant_identifier_names
  Future<void> _AddAnnonce() async {
    try{

      _changeBlackVisible();
      await _Add();

    } catch (e) {
      print( "Error in Add: $e" );
      String exception = Auth.getExceptionText( e );
      _showErrorAlert(
        title: tr("signupf"),
        content: exception,
        onPressed: _changeBlackVisible,
      );
    }
  }

  // ignore: non_constant_identifier_names
  _Add() async {
    setState(() {
      blockk=true;
    });
    try{
      final firestoreInstance = Firestore.instance;
      await FirebaseAuth.instance.currentUser().then((firebaseUser) async {

        await firestoreInstance.collection('/users').where('userID', isEqualTo: firebaseUser.uid).getDocuments().then((value) => {

          name=value.documents[0].data['firstName'],

        });
        try{
          firestoreInstance
              .collection("annonces")
              .add({
            'titleTxt': _title.text,
            'by': name,
            'userId': userid,
            'disc': _desc.text,
            'lits': _n,
            'sbain': _nS,
            'persones':_nP,
            if(groupe == 1)
              'perNight': distValueJ
            else
              'perMonth':  distValueM,
            'reviews': 0,
            'rating': 0.01,
            'de':startDate,
            'a':endDate,
            'adresse':[rue!=''?rue:null,localy,gouver,country],
            'lang.lat':langlan.latitude,
            'lang.long':langlan.longitude,
            'type':selectedProperty.index,
            'chambres':numberOfRooms.index==5?'+6':numberOfRooms.index==0?1:numberOfRooms.index==1?2:numberOfRooms.index==2?3:numberOfRooms.index==3?4:5,
            'equipment':listee,
            'userPhone':phone,


          }).then((value) async {

            await _addAnnonceImagesToFirebaseStorage(value.documentID,firebaseUser );

          });
          //Auth.addAnnonce(annonce);
        }catch (e) {

          String exception = Auth.getExceptionText( e );
          _showErrorAlert(
            title: tr("errinc"),
            content: exception,
            onPressed:()=> _changeBlackVisible(),
          );
        }
      }).catchError((e)=>{

        _changeBlackVisible(),
        Fluttertoast.showToast(msg: tr('err_add_an'),toastLength: Toast.LENGTH_SHORT
            ,backgroundColor: Theme.of(context).backgroundColor,textColor: Theme.of(context).cursorColor,gravity: ToastGravity.BOTTOM),});

    }catch (e) {

      String exception = Auth.getExceptionText( e );
      _showErrorAlert(
        title: tr("errinc"),
        content: exception,
        onPressed:()=> _changeBlackVisible(),
      );
    }
  }

  Future<void> _addImages(FirebaseUser firebaseUser, String annonceId) async {
    await Firestore.instance.collection("users").getDocuments().then((querySnapshot) {

      querySnapshot.documents.forEach((result) async {
        Uint8List bytes=await file.readAsBytes();
        await BlurHash.encode(bytes, 4, 3).then((value) => setState((){

          blurHash=value;
        }));
        Firestore.instance
            .collection("annonces").document(annonceId).updateData({
          'images':FieldValue.arrayUnion(_imageStringList),
          'blurhash':blurHash,
          'annonceID':annonceId,
        }).then((_){
          // ignore: unnecessary_statements
          onBackPress;
          _changeBlackVisible();
          setState(() {

            _a=true;blockk=false;

          });

        });
        Fluttertoast.showToast(msg: tr('add_an'),toastLength: Toast.LENGTH_SHORT
            ,backgroundColor: Theme.of(context).backgroundColor,textColor: Theme.of(context).cursorColor,gravity: ToastGravity.BOTTOM);
      });
    }).catchError((e)=>{

      _changeBlackVisible(),
      setState((){
        _a=true;blockk=false;
      }),
      Fluttertoast.showToast(msg: tr('err_add_an'),toastLength: Toast.LENGTH_SHORT
          ,backgroundColor: Theme.of(context).backgroundColor,textColor: Theme.of(context).cursorColor,gravity: ToastGravity.BOTTOM),

      FirebaseStorage.instance.ref().child(
          'Annonces/$annonceId').delete(),
      Firestore.instance.
      collection("annonces").document(annonceId).delete(),

    });
  }
  void _changeBlackVisible() {
    setState( () {
      _blackVisible = !_blackVisible;
    } );
  }


}







