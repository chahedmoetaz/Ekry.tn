import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tn/Screens/singin-singup.dart';
import 'package:tn/chats/chat_with.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class DetailAnnonce extends StatefulWidget {
  const DetailAnnonce({
    Key key,
    this.annonceData,
  }) : super(key: key);

  final Map<String, dynamic> annonceData;

  @override
  _DetailAnnonceState createState() => _DetailAnnonceState();
}

class _DetailAnnonceState extends State<DetailAnnonce> {
  // ignore: non_constant_identifier_names
  final Set<Marker> _markers = {};

  GoogleMapController _mapController;

  LatLng initialPosition;
  BitmapDescriptor pinLocationIcon;
  List _listOfImages = [];

  String icon = 'assets/mapicon.png';

  String imageuser = '';

  String currentuser=null;

  SnackBar add,del;

  bool favorite=false;

  GoogleMapController get mapController => _mapController;

  Set<Marker> get markers => _markers;

  void addMarker(LatLng initialPosition) {
    _markers.clear();
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(initialPosition.toString()),
          position: initialPosition,
          draggable: false,
          onTap: () => onCameraMove(initialPosition),
          // ignore: deprecated_member_use
          icon: BitmapDescriptor.fromAsset(
            icon,
          )));
    });
  }

  // ! ON CREATE
  void onCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  void onCameraMove(LatLng locationCoords) {
    setState(() {
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: locationCoords, zoom: 15.5, bearing: 45.0, tilt: 45.0),
      ));
    });
  }

  @override
  void initState() {
    _getUser();
    getuserimage(widget.annonceData['userId']);
    super.initState();

    setState(() {
      initialPosition = LatLng(
          widget.annonceData["lang.lat"], widget.annonceData["lang.long"]);
      addMarker(initialPosition);
    });
  }
  static const _kFontFam = 'Room';
  static const _kFontPkg = null;

  @override
  Widget build(BuildContext context) {
    Timestamp t = widget.annonceData['de'];
    DateTime d = t.toDate();
    Timestamp aa = widget.annonceData['a'];
    DateTime a = aa.toDate();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        top: true,
        right: true,
        left: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                height: MediaQuery.of(context).size.height / 2,
                                color: Colors.grey,
                                child: ListView.builder(
                                    itemCount:
                                    widget.annonceData['images'].length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      _listOfImages = [];
                                      for (int i = 0;
                                      i <
                                          widget
                                              .annonceData['images'].length;
                                      i++) {
                                        if (widget.annonceData['images'][i] !=
                                            '')
                                          _listOfImages.add(NetworkImage(
                                              widget.annonceData['images'][i]));
                                      }
                                      return Stack(
                                        children: <Widget>[
                                          Container(
                                            child: _listOfImages.length == 1
                                                ? BlurHash(
                                              hash: widget.annonceData[
                                              'blurhash'],
                                              image: widget.annonceData[
                                              'images'][0],
                                              imageFit: BoxFit.cover,
                                            )
                                                : Carousel(
                                                boxFit: BoxFit.cover,
                                                images: _listOfImages,
                                                autoplay: false,
                                                indicatorBgPadding: 5.0,
                                                dotIncreasedColor:
                                                Theme.of(context)
                                                    .accentColor,
                                                dotPosition: DotPosition
                                                    .bottomCenter,
                                                dotBgColor:
                                                Theme.of(context)
                                                    .primaryColor,
                                                dotColor: Colors.grey,
                                                animationCurve:
                                                Curves.fastOutSlowIn,
                                                animationDuration: Duration(
                                                    milliseconds: 1000)),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ),
                                        ],
                                      );
                                    }),
                              ),
                            ),
                            Container(
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      iconSize: 30,
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: _LikeButton(),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ), //TapBa
                      SizedBox(
                        height: 10,
                      ), // r
                      Container(
                        padding: EdgeInsets.only(left: 24, right: 24),
                        color: Theme.of(context).primaryColor,
//                        height:( MediaQuery.of(context).size.width*0.5)/375.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.annonceData['titleTxt'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              '${widget.annonceData['adresse'][0] != null ? '${widget.annonceData['adresse'][0]},' : ''} ${widget.annonceData['adresse'][1]},'
                                  ' ${widget.annonceData['adresse'][2]}, ${widget.annonceData['adresse'][3]}',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),

                      ), //K
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 6,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    _getDetails(
                        context,
                        widget.annonceData['persones'].toString(),
                        Icons.people,
                        "persones"),SizedBox(width:10,),
                    _getDetails(
                        context,
                        widget.annonceData['chambres'].toString(),
                        IconData(0xf52b, fontFamily: _kFontFam, fontPackage: _kFontPkg),
                        "add_cham"),SizedBox(width:20,),
                    _getDetails(context, widget.annonceData['lits'].toString(),
                        Icons.hotel, "lit"),SizedBox(width:10,),
                    _getDetails(context, widget.annonceData['sbain'].toString(),
                        IconData(0xf2cd, fontFamily: _kFontFam, fontPackage: _kFontPkg), "sbain"),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              widget.annonceData['disc'].toString().isEmpty?
              SizedBox()
                  : Container(
                margin: EdgeInsets.symmetric(horizontal: 24),

                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tr("desc"),
                      style: tr("add_type") == "Type"
                          ? TextStyle(fontWeight: FontWeight.w700, fontSize: 22)
                          : TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 24),

                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.annonceData['disc'],
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
               height: MediaQuery.of(context).size.height /3,
                margin: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (widget.annonceData["equipment"].toString().contains('friends')||widget.annonceData["equipment"].toString().contains('anc'))?tr("equip"):tr("equipment"),
                      style: tr("add_type") == "Type"
                          ? TextStyle(fontWeight: FontWeight.w700, fontSize: 22)
                          : TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 24),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: GridView.count(
                        //semanticChildCount: widget.annonceData["equipment"].length,
                          physics: NeverScrollableScrollPhysics(),
                          semanticChildCount: 3,crossAxisSpacing: 3,childAspectRatio: 2,
                          crossAxisCount: 3,mainAxisSpacing: 3,
                          children: <Widget>[
                            for (int i = 0;
                            i < widget.annonceData["equipment"].length;
                            i++)
                              _getEquipment(
                                  context, widget.annonceData["equipment"][i]),
                          ]),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 5,
                margin: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tr("dispo"),
                      style: tr("add_type") == "Type"
                          ? TextStyle(fontWeight: FontWeight.w700, fontSize: 22)
                          : TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 24),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 6 - 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Wrap(
                            //crossAxisAlignment: WrapCrossAlignment.start,
                            alignment: WrapAlignment.spaceEvenly,direction: Axis.vertical,
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                '${tr(DateFormat('EEE').format(d))},${DateFormat('dd').format(d)} ${tr(DateFormat('MMM').format(d))}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              Text(
                                '${tr(DateFormat('EEE').format(a))},${DateFormat('dd').format(a)} ${tr(DateFormat('MMM').format(a))}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2,
                margin: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tr("loca"),
                      style: tr("add_type") == "Type"
                          ? TextStyle(fontWeight: FontWeight.w700, fontSize: 22)
                          : TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 24),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    initialPosition == null
                        ? Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Chargement de location",
                              style:
                              TextStyle(color: Colors.grey, fontSize: 18),
                            )
                          ],
                        ))
                        : Container(
                      height: MediaQuery.of(context).size.height /2.5,
                          child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target: initialPosition, zoom: 15),
                          onMapCreated: onCreated,
                          mapType: MapType.normal,
                          markers: Set.from(markers),

                    ),
                        ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.withOpacity(0.5),
                          child: ClipOval(
                            child: new SizedBox(
                                width: 180.0,
                                height: 180.0,
                                child: (imageuser == "")
                                    ? Image.asset(
                                  "assets/default.png",
                                )
                                    : CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    width: 30.0,

                                    height: 30.0,

                                    padding: EdgeInsets.all(10.0),

                                    child: CircularProgressIndicator(

                                      strokeWidth: 1.0,

                                      valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).accentColor),

                                    ),),
                                  imageUrl: imageuser,
                                  fit: BoxFit.fill,

                                )),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        widget.annonceData['by'],
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        padding: EdgeInsets.only(left: 20, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${widget.annonceData['perNight'] != null ?
                        widget.annonceData['perNight'].toString().replaceFirst('.0', '') : widget.annonceData['perMonth'].toString().replaceFirst('.0', '')} DT ',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      widget.annonceData["perNight"] != null
                          ? Text(
                        "${tr("pj")}",
                        style:
                        TextStyle(fontSize: 16, color: Colors.grey),
                      )
                          : Text(
                        "${tr("pm")}",
                        style:
                        TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  rating: widget.annonceData['rating'],
                  size: 20,
                  color: Theme.of(context).accentColor,
                  borderColor: Theme.of(context).accentColor,onRated: (index) {
                  if(currentuser!=null&&widget.annonceData['userId']!=currentuser && widget.annonceData['CommentBy'].toString().contains(currentuser)==false) {
                    setState( () {
                      widget.annonceData['rating'] = index;
                    } );
                    Firestore.instance.collection("annonces").document(widget.annonceData['annonceID']).updateData({
                      "CommentBy" : FieldValue.arrayUnion([currentuser]),
                      "rating": index>=widget.annonceData['rating']?widget.annonceData['rating']+0.1:widget.annonceData['rating']!=0.1?
                      widget.annonceData['rating']-0.1:widget.annonceData['rating'],
                      "reviews":widget.annonceData['reviews']+1
                    });
                  }
                },
                ),
              ],
            ),
            Container(
              height: 72,
              width: 150,
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.chat_bubble),
                          color: Colors.white,
                          onPressed: () {
                            print(widget.annonceData['userId']);
                            print(currentuser);
                            if(widget.annonceData['userId']!=currentuser && currentuser!=null)
                              Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                      builder: (context) => Chat(name: widget.annonceData['by'],

                                        peerId: widget.annonceData['userId'],

                                        peerAvatar: imageuser,

                                      )));
                            else if(currentuser==null) Navigator.push( context,
                                MaterialPageRoute( builder: (context) => MyHomePage( ) ) )
                                .then( (user) async {
                              _getUser();
                            } );
                          },
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.call),
                          color: Colors.white,
                          onPressed: () {
                            if(widget.annonceData['userId']!=currentuser) {
                              String _phone = widget.annonceData['userPhone'];
                              _makePhoneCall( 'tel:$_phone' );
                              print( widget.annonceData['userPhone'] );
                            }
                          },
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  _LikeButton() {
    return GestureDetector(onTap: (){
      !favorite?_add(currentuser,widget.annonceData['annonceID']):remove(currentuser,widget.annonceData['annonceID']);
    },
      child: Container(
        height: 35,alignment: Alignment.topRight,
        width: 35,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular( 16 ),
            color: Colors.white.withOpacity( .7 ) ),
        child: Align(alignment: Alignment.center,
          child: Icon(favorite?Icons.favorite:Icons.favorite_border,

            color: favorite? Colors.red:Colors.red,
          ),
        ),
      ),
    );

  }

  void getuserimage(annonceData) {
    Firestore.instance
        .collection('users')
        .document(annonceData)
        .get()
        .then((value) async {
      setState(() {
        imageuser = value['profilePictureURL'];
      });
    });
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _getUser() async {
    await FirebaseAuth.instance.currentUser().then((value) => {
      if(value.uid!=null){
        setState( () {
          currentuser = value.uid;
        } ),
        Firestore.instance.collection( 'users' ).where(
            'userID', isEqualTo: currentuser )
            .where(
            'favorites', arrayContains: widget.annonceData['annonceID'] )
            .getDocuments()
            .then( (value) =>
        {
          if(value.documents.length != 0)
            setState( () {
              favorite = true;
            } )
        } ),
      }
      else currentuser=''
    }
    );
  }

  _add(String currentuser, annonceid) async {
    print(currentuser);
    if(currentuser!=null)
      Firestore.instance.collection("users").document(currentuser).updateData({
        "favorites" : FieldValue.arrayUnion([annonceid])
      }).then((_) {
        setState(() {
          favorite=true;
          Fluttertoast.showToast(msg:tr('add_fav'),toastLength: Toast.LENGTH_SHORT
              ,backgroundColor: Theme.of(context).cursorColor,textColor: Theme.of(context).primaryColor,gravity: ToastGravity.BOTTOM);
        });

        print("success!");
      }).catchError((e)=>print('errerrr----'+e));
    else Navigator.push( context,
        MaterialPageRoute( builder: (context) => MyHomePage( ) ) )
        .then( (user) async {
      _getUser();
    } );
  }

  remove(String currentuser, annonceid) {
    print(currentuser);
    if(currentuser!=null)
      Firestore.instance.collection("users").document(currentuser).updateData({
        "favorites" : FieldValue.arrayRemove([annonceid])
      }).then((_) {
        setState(() {
          favorite=false;
          Fluttertoast.showToast(msg:tr('del_fav'),toastLength: Toast.LENGTH_SHORT
              ,backgroundColor: Theme.of(context).cursorColor,textColor: Theme.of(context).primaryColor,gravity: ToastGravity.BOTTOM);
        });

        print("success!");
      }).catchError((e)=>print('errerrr----'+e));
  }
}

Widget _getEquipment(BuildContext context, String s) {
  return Text(
    ' - ${tr(s)}',
    style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
    textAlign: TextAlign.start,
  );
}

Widget _getDetails(context, data, icon, text) {
  return Container(
      width: tr(text).length >= 14 ? 150 : 110,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              color: Theme.of(context).accentColor,
              size: MediaQuery.of(context).size.height / 7 - 30,
            ),
            Text(
              " $data ${tr(text)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ));
}
