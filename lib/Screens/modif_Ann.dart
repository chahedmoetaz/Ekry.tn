import 'dart:io';
import 'dart:typed_data';
import 'package:blurhash/blurhash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/public.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_picker/flutter_map_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mlkit/mlkit.dart';
import 'package:tn/Filter_page/filter_liste.dart';
import 'package:tn/Filter_page/silver_view.dart';
import 'package:tn/Filter_page/silver_view_m.dart';
import 'package:tn/Widgets/Images_wid.dart';
import 'package:tn/Widgets/calendar_popup_view.dart';
import 'package:tn/Widgets/custom_alert_dialog.dart';
import 'package:tn/Widgets/custom_text_field.dart';
import 'package:tn/services/auth.dart';
import 'package:tn/services/validator.dart';
import 'package:validated/validated.dart' as validate;
import 'package:tn/provider/roomp.dart';


// ignore: must_be_immutable
class ModifAnn extends StatefulWidget {
  ModifAnn(this.id);
  String id;

  @override
  _ModifAnnState createState() => _ModifAnnState();
}

class _ModifAnnState extends State<ModifAnn> {
  bool charge=true;
  int _nP;

  Property _selectedProperty;

  Property type;



  DocumentSnapshot data;
  final TextEditingController _desc = new TextEditingController( );
  final TextEditingController _title = new TextEditingController( );

  int groupe;

  NumberOfRooms _numberOfRooms;

  double lat,lon;

  String result,exeption;

  FirebaseVisionLabelDetector detector = FirebaseVisionLabelDetector.instance;
  List<String> _imageStringList =List<String>.generate(6,(i) => '');
  List<String> _imagetest=[];
  List<File> _imageList=[];

  Future<File> _imageFile;

  int index=0;
  File file;
  List listee=[];
  List<PopularFilterListData> popularFilterListData =
      PopularFilterListData.popularList;

  String phone;

  bool blockk=false;

  VoidCallback onBackPress;

  String gouver,rue,country,localy,resultt;

  String blurHash;


  NumberOfRooms get numberOfRooms => _numberOfRooms;


  Property get selectedProperty => _selectedProperty;

  int _n ;
  double _nS;

  @override
  void initState() {
    popularFilterListData.forEach((element) {element.isSelected=false;});
    _getdata();
    super.initState();
  }
  bool _blackVisible= false;
  List<Object> images =[];
  double distValueJ=50;
  double distValueM = 300;
  LatLng inisial;
  Future<void> _getdata() async {
    await Firestore.instance.collection('annonces').document(widget.id).get().then((query) {

      data=query;

      setState(() {
        t = data.data['de'];

        aa = data.data['a'];
        _selectedProperty= Property.HOUSE;
        _title.text=data.data['titleTxt'];
        _desc.text=data.data['disc'];
        _nP=data.data['persones'];
        rue =data.data['adresse'][0] != null ? '${data.data['adresse'][0]}' : '';
        localy=data.data['adresse'][1];
        gouver=data.data['adresse'][2];
        country=data.data['adresse'][3];
        result='${data.data['adresse'][0] != null ? '${data.data['adresse'][0]},' : ''}, ${data.data['adresse'][1]},'
            ' ${data.data['adresse'][2]}, ${data.data['adresse'][3]}';
        _n=data.data['lits'];
        _nS=data.data['sbain'];
        lat=data.data['lang.lat'];
        lon=data.data['lang.long'];
        inisial=LatLng(lat,lon);
        data.data['chambres']=='+6'?_numberOfRooms=NumberOfRooms.MORE:data.data['chambres']==0?_numberOfRooms= NumberOfRooms.ONE :data.data['chambres']==1?_numberOfRooms= NumberOfRooms.TWO
            :data.data['chambres']==2?_numberOfRooms=NumberOfRooms.THREE :data.data['chambres']==3?_numberOfRooms=NumberOfRooms.FOUR:_numberOfRooms=NumberOfRooms.FIVE ;
        if(data.data['perMonth']==null){
          groupe=1;
          distValueJ=data.data['perNight']==null?50:data.data['perNight'];
        }
        else distValueM=data.data['perMonth']==null?300:data.data['perMonth'];
        charge=false;

        d = t.toDate();
        a = aa.toDate();
        listee.addAll(data.data['equipment']);
        phone=data.data['userPhone'];
        for (int i = 0;
        i <
            data.data['images'].length;
        i++) {
          if (data.data['images'][i] !=
              '')
            setState(() {
              _imageStringList.insert(i,
                  data.data['images'][i]);
              _imagetest.add(
                  data.data['images'][i]);
            });
          else Firestore.instance
              .collection( "annonces" )
              .document( widget.id )
              .updateData( {
            'images': FieldValue.arrayRemove( [data.data['images'][i]] ),
          });

        }
        print(_imageStringList.length);
        print(d.difference(a).inDays);

      });

    }).catchError((e)=>print(e));

  }




  void f(int a) {
    setState( () {
      groupe = a;
    } );
  }

  var _p=EdgeInsets.symmetric(horizontal: 24);
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
  Timestamp aa,t;
  DateTime d,a;
  @override
  Widget build(BuildContext context) {


    return AbsorbPointer(
      absorbing: blockk ,ignoringSemantics: blockk,
      child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(leading:  IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Platform.isAndroid?Icons.arrow_back:Icons.arrow_back_ios,
            ),
          ),
            elevation: Theme.of(context).appBarTheme.elevation,title: Text( tr( "modifan" ),),centerTitle: true,
          ),
          body:charge?
          SpinKitRotatingCircle(
            color: Colors.teal,
            size: 50.0,
          )
              : WillPopScope(
            onWillPop: onBackPress,
            child: SafeArea(
              child:  Stack(
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
                                onPressed: addP,
                                child: new Icon(
                                  Icons.add, color: Theme
                                    .of( context )
                                    .primaryColor, ),
                                backgroundColor: Theme
                                    .of( context )
                                    .cursorColor, ),
                              new Text( '$_nP',
                                  style: new TextStyle(
                                      fontSize: 30.0 ) ),

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
                                onPressed: add,
                                child: new Icon(
                                  Icons.add, color: Theme
                                    .of( context )
                                    .primaryColor, ),
                                backgroundColor: Theme
                                    .of( context )
                                    .cursorColor, ),
                              new Text( '$_n',
                                  style: new TextStyle(
                                      fontSize: 30.0 ) ),

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
                                onPressed: addS,
                                child: new Icon(
                                  Icons.add, color: Theme
                                    .of( context )
                                    .primaryColor, ),
                                backgroundColor: Theme
                                    .of( context )
                                    .cursorColor, ),
                              new Text( '$_nS',
                                  style: new TextStyle(
                                      fontSize: 30.0 ) ),

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
                        margin: _p,
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
                                      '${tr(DateFormat('EEE').format(d))},${DateFormat('dd').format(d)} ${tr(DateFormat('MMM').format(d))}'
                                          ' - ${tr(DateFormat('EEE').format(a))},${DateFormat('dd').format(a)} ${tr(DateFormat('MMM').format(a))}',
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
                                    print( v );
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
                                  print( v );

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
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.all( 15 ),
                        child: InkWell(
                          onTap: ()
                          async {
                            print(_imageStringList.length);

                            if(_validateAnnonceData()) {
                              SystemChannels.textInput.invokeMethod( 'TextInput.hide' );
                              await updateAnnonce();

                            }else print(phone.toString());
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
                                tr(
                                    "btn_modif"),
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
          )
      ),
    );

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

  getPosition()  {

    return Container(
        margin: EdgeInsets.only( bottom: 10 ),
        padding: EdgeInsets.symmetric( horizontal: 24 ),
        child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () =>
                {

                  getPlace()
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



  getPlace() async {
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
        rue='';
        resultt=resultt.replaceAll(', Tunisie', '');
        gouver=resultt.substring(resultt.lastIndexOf(', '),resultt.length);
        resultt=resultt.replaceRange(resultt.lastIndexOf(','),resultt.length,'');
        localy=resultt;
        country="Tunisie";
      } );

    }
    else if (resiltt.address.contains( 'Unnamed Road' ) == false) {
      setState( () {
        result = resiltt.address;
        inisial=resiltt.latLng;
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
    else setState(() {
        result='';
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
                ||element.label.contains("Food")||element.label.contains("Blackboard") ||element.label.contains("Whiteboard") ||element.label.contains("Web Page")||element.label.contains("Paper")||element.label.contains("Selfie")||element.label.contains("Mouth"))
              truee=false;
            });
            print(truee);
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
    ):showDialog(context: context,builder: (contect)=>AlertDialog(shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0))),content:Text(content),title: Text(title),actions: <Widget>[FloatingActionButton(
      child: Text(tr("ok"),style: TextStyle(color: Colors.blue),),
      onPressed: () => Navigator.of(context).pop(),
    )]));
  }



  void _changeBlackVisible() {
    setState( () {
      _blackVisible = !_blackVisible;
    } );
  }

  void showDemoDialog({BuildContext context}) {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) =>
          CalendarPopupView(
            barrierDismissible: true,
            minimumDate: DateTime.now( ),
            //  maximumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
            initialEndDate: a,
            initialStartDate: d,
            onApplyClick: (DateTime startData, DateTime endData) {
              setState( () {
                if (startData != null && endData != null) {
                  d= startData;
                  a=endData;
                  print(d);
                  print(a);
                }
              } );
            },
            onCancelClick: () {},
          ),
    );
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
          for(int i=0;i<listee.length;i++)
            if(date.titleTxt==listee[i])
              date.isSelected=true;

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
                    child: Container(
                      margin: const EdgeInsets.all( 8.0 ),
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
                                    : 13, )
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

  imagess() {
    setState( () {
      _imageStringList.forEach((element) {images.add(element);});
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
      crossAxisCount: 3,mainAxisSpacing: 10,
      childAspectRatio: 1,semanticChildCount: 3,
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
                  height: 310,
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

                        images.replaceRange( index, index + 1, ['Add Image'] );
                        //_imageStringList.removeAt(index);
                        _imageList.removeAt(index);

                        // _imageStringList.removeAt(index);
                        //_imagetest.removeAt(index);


                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else if(images[index] !="Add Image"&&images[index] !='') {
          print('indeximage  :  $index');
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                Image.network(
                  images[index],
                  width: 300,
                  height: 310,
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


                      FirebaseStorage.instance.ref( ).child(
                          'Annonces/${widget.id}/image$index').delete( );
                      Firestore.instance
                          .collection( "annonces" )
                          .document( widget.id )
                          .updateData( {
                        'images': FieldValue.arrayRemove([_imageStringList[index]]),

                      } );
                      setState( () {
                        images.replaceRange( index, index + 1, ['Add Image'] );
                        _imageStringList.removeAt(index);
                        _imagetest.removeAt(index);
                      } );


                    },
                  ),
                ),
              ],
            ),
          );
        }
        else if(images[index] =="Add Image"||images[index] ==''){
          return Card(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _onAddImageClick(index);
              },
            ),
          );
        }
        else{
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
    else if (groupe == 2 &&((d.month != a.month ||
        d.year != a.year)&&a.difference(d).inDays>=28))
      print( "$distValueM" );

    else{
      if (alertString.trim() != '') {
        alertString = alertString+ '\n\n';
      }
      alertString = alertString+ tr('verifdate');
    }



    if (validate.contains( result, "Tunisie") == false  || inisial==null){
      if (alertString.trim() != '') {
        alertString = alertString+ '\n\n';
      }
      alertString = alertString+ tr('vadress');
    }
    if (_imageStringList.length == 0){
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


  updateAnnonce()async {
    setState(() {
      blockk=true;
    });
    _changeBlackVisible();
    try{

      await Firestore.instance.collection('annonces').document(data.data['annonceID']).updateData({
        'titleTxt': _title.text,

        'disc': _desc.text,
        'lits': _n,
        'sbain': _nS,
        'persones':_nP,
        if( groupe == 1)
          'perNight':distValueJ
        else
          'perMonth':  distValueM,

        'de':d,
        'a':a,
        'adresse':[rue!=''?rue:null,localy,gouver,country],
        'lang.lat':inisial.latitude,
        'lang.long':inisial.longitude,
        'type':selectedProperty.index,
        'chambres':numberOfRooms.index==5?'+6':numberOfRooms.index==0?1:numberOfRooms.index==1?2:numberOfRooms.index==2?3:numberOfRooms.index==3?4:5,
        'equipment':listee,
      });
      if(_imageList.length!=0)
        await _addAnnonceImagesToFirebaseStorage(widget.id);
      else {
        setState( () {
          blockk = false;
        } );
        //_changeBlackVisible( );
        Navigator.of( context ).pop( );
      }
    }catch(e){
      setState(() {
        blockk=false;
      });
      print( "Error in suprime up: $e" );
      String exception = Auth.getExceptionText( e );
      _showErrorAlert(
        title: tr("errinc"),
        content: exception,
        onPressed:()=> _changeBlackVisible(),
      );
    }
  }

  _addAnnonceImagesToFirebaseStorage(String id) {
    try {
      if (_imageList != null && _imageList.length > 0) {
        _uploadUserImages( _imageList[_uploadImagePosition], id,
            'image$_uploadImagePosition', _uploadImagePosition );
      }
    } catch (e) {
      print( e.message );
    }
  }
  int  _uploadImagePosition=0;
  Future<void> _uploadUserImages(File imageFile, String annonceId,
      String imageCount, int position,) async {
    try {
      String fileName = 'Annonces/$annonceId/$imageCount'; //userID+imageCount;
      StorageReference reference = FirebaseStorage.instance.ref( ).child(
          fileName );
      setState(() {
        file=_imageList[0];
      });
      StorageUploadTask uploadTask = reference.putFile( imageFile );
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      storageTaskSnapshot.ref.getDownloadURL( ).then( (downloadUrl) {
        _imageStringList[position] = downloadUrl;
        print(annonceId);
        setState(() {
          _imageStringList.add(downloadUrl);
        });
        _uploadImagePosition++;
        if (_uploadImagePosition < _imageList.length) {
          _uploadUserImages( _imageList[_uploadImagePosition], annonceId,
            'image$_uploadImagePosition', _uploadImagePosition,
          );
        }
        else _addImages(annonceId);
      }, onError: (err) {
        setState( () {
          print( err );
        } );
      } );
    } catch (e) {
      print( e.message );
    }
  }

  Future<void> _addImages(String annonceId) async {
    await Firestore.instance.collection("users").getDocuments().then((querySnapshot) {

      querySnapshot.documents.forEach((result) async {
        if(_imageStringList[0]!=data.data[0]) {
          Uint8List bytes = await file.readAsBytes( );
          await BlurHash.encode( bytes, 4, 3 ).then( (value) =>
              setState( () {
                print( value );
                blurHash = value;
              } ) );
        }
        await Firestore.instance
            .collection("annonces").document(annonceId).updateData({
          'images':FieldValue.arrayUnion(_imageStringList),
          if(blurHash!=null)
            'blurhash':blurHash,

        });
      });
      _changeBlackVisible();
      Navigator.pop(context);
      // ignore: unnecessary_statements



    }).catchError((e)=>{
      _changeBlackVisible(),
      setState((){
        blockk=false;
      }),
      Fluttertoast.showToast(msg: tr('err_add_an'),toastLength: Toast.LENGTH_SHORT
          ,backgroundColor: Theme.of(context).backgroundColor,textColor: Theme.of(context).cursorColor,gravity: ToastGravity.BOTTOM),

    });
  }



}




