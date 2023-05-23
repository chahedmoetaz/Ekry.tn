import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:tn/Screens/singin-singup.dart';

class AnnonceListView extends StatefulWidget {
  const AnnonceListView(
      {Key key,
        this.annonceData,
        this.callback})
      : super(key: key);

  final VoidCallback callback;
  final DocumentSnapshot annonceData;


  @override
  _AnnonceListViewState createState() => _AnnonceListViewState();
}

class _AnnonceListViewState extends State<AnnonceListView> {
  bool favorite=false;

  @override
  void initState() {
    _getuser();
    super.initState();
  }
  String currentuser;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 24, right: 24, top: 8, bottom: 16),
      child: InkWell(

        onTap: () {
          widget.callback();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                offset: const Offset(2,4),
                blurRadius: 16,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    AspectRatio(
                        aspectRatio: 2,
                        child: BlurHash(hash:widget.annonceData['blurhash'],image:widget.annonceData['images'][0],imageFit: BoxFit.cover,)
                    ),
                    Container(
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 8, bottom: 8),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.start,alignment: WrapAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(
                                      widget.annonceData['titleTxt'],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
                                      ),
                                    ),
                                    Text(
                                      '${widget.annonceData['adresse'][0]!=null?'${widget.annonceData['adresse'][0]},':''} ${widget.annonceData['adresse'][1]},'
                                          ' ${widget.annonceData['adresse'][2]}, ${widget.annonceData['adresse'][3]}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey
                                              .withOpacity(0.8)),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(top: 4),
                                      child: Wrap(crossAxisAlignment: WrapCrossAlignment.center,
                                        children: <Widget>[
                                          SmoothStarRating(
                                            allowHalfRating: true,
                                            starCount: 5,
                                            rating: widget.annonceData['rating'],
                                            size: 20,
                                            color: Theme.of(context).accentColor,
                                            borderColor:Theme.of(context).accentColor,
                                          ),
                                          Text(
                                            ' ${widget.annonceData['reviews'].toString().replaceFirst('.0', '')} ${tr('rev')}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey
                                                    .withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15,top: 20),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${widget.annonceData['perNight']!=null
                                      ?widget.annonceData['perNight'].toString().replaceFirst('.0', ''):widget.annonceData['perMonth'].toString().replaceFirst('.0', '')} DT ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                                widget.annonceData['perNight']!=null
                                    ?Text(
                                  "${tr("pj")}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color:
                                      Colors.grey),
                                )
                                    :Text(
                                  "${tr("pm")}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color:
                                      Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: _LikeButton(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ignore: non_constant_identifier_names
  _LikeButton() {

        return GestureDetector( onTap: () {
              !favorite
                  ? _add( currentuser, widget.annonceData['annonceID'] )
                  : remove( currentuser, widget.annonceData['annonceID'] );
            },
              child: Padding(
                padding: const EdgeInsets.all( 8.0 ),
                child: Container(
                  height: 40,alignment: Alignment.topRight,
                  width: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular( 16 ),
                      color: Colors.transparent ),
                  child: Icon( favorite ? Icons.favorite : Icons.favorite_border,
                    color: favorite ? Colors.red : Colors.red,
                  ),
                ),
              ),
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
        });
        Fluttertoast.showToast(msg:tr('add_fav'),toastLength: Toast.LENGTH_SHORT
            ,backgroundColor: Theme.of(context).cursorColor,textColor: Theme.of(context).primaryColor,gravity: ToastGravity.BOTTOM);
        //Fluttertoast.showToast(msg: tr('add_fav'));
        print("success!");
      }).catchError((e)=>print('errerrr----'+e));
    else Navigator.push( context,
        MaterialPageRoute( builder: (context) => MyHomePage( ) ) )
        .then( (user) async {
      await _getuser();
    } );
  }

  remove(String currentuser, annonceid)async {
    print(currentuser);
    if(currentuser!=null)
     await Firestore.instance.collection("users").document(currentuser).updateData({
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

   _getuser() async{
    await FirebaseAuth.instance.currentUser().then((value) =>{
      if(value.uid!=null)
      currentuser=value.uid
    });
    if(currentuser!=null)
      await Firestore.instance.collection('users').where('userID',isEqualTo: currentuser)
        .where('favorites',arrayContains: widget.annonceData['annonceID']).getDocuments().then((value) => {
      if(value.documents.length!=0)
        setState(() {
          favorite=true;
        })

    });
    Timestamp t =widget.annonceData['a'];
    DateTime d = t.toDate();
    DateTime startDate = DateTime.now();
    if(startDate.difference(d).inDays>0)
    {

      await FirebaseStorage.instance.ref().child(
          'Annonces/${widget.annonceData['annonceID']}').delete();
     await Firestore.instance.
      collection("annonces").document(widget.annonceData['annonceID']).delete();

     await Firestore.instance.collection("users").document(currentuser).updateData({
            "favorites" : FieldValue.arrayRemove([widget.annonceData['annonceID']])
          });


    }
  }


}


