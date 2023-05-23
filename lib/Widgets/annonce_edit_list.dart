
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tn/Screens/modif_Ann.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:tn/services/auth.dart';

class AnnonceEditList extends StatefulWidget {
  const AnnonceEditList(
      {Key key,
        this.id,
        this.callback,this.hash,this.annonceid,})
      : super(key: key);

  final VoidCallback callback;
  final String id;
  final String hash;
  final String annonceid;


  @override
  _AnnonceEditListState createState() => _AnnonceEditListState();
}

class _AnnonceEditListState extends State<AnnonceEditList> {
  String title;

  DateTime d;
  DateTime startDate=DateTime.now();

  Future<void> _getdata() async {
    await Firestore.instance.collection('annonces').document(widget.annonceid).get().then((query) {
      setState(() {
        title=query.data['titleTxt'];
        Timestamp t = query.data['a'];
        d = t.toDate();

      });
    });

    if(startDate.difference(d).inDays==(-1)||startDate.difference(d).inDays>=0){
      _showErrorAlert(content:'${tr('annonce')} $title',title:tr('verifdate'),modan: tr("btn_modif"));


    }

  }


  @override
  void initState() {
    _getdata();
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 24, right: 24, top: 8, bottom: 16),


          child:Container(
          margin: EdgeInsets.all( 12 ),
          height: MediaQuery
              .of( context )
              .size
              .height / 3,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all( Radius.circular( 16.0 ) ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity( 0.3 ),
                offset: const Offset( 4, 4 ),
                blurRadius: 16,
              ),
            ],
          ),
           child: Column(
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular( 16 ),
                        topRight: Radius.circular( 16 ),
                      ),
                  ),
                  child:  InkWell(onTap: () {
                    widget.callback();
                  },
                 child:widget.hash==null?
              Center(
          child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(
              Theme.of(context).accentColor,
        ),
        ),
    ):BlurHash(hash:widget.hash,image:widget.id,imageFit: BoxFit.fill,),
                ),
           )
              ),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme
                        .of( context )
                        .primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular( 16 ),
                      bottomRight: Radius.circular( 16 ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded( flex: 1, child: InkWell(
                        onTap: () =>Navigator.of( context ).push( MaterialPageRoute(
                            builder: (context) => ModifAnn(widget.annonceid))) ,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceAround,
                              children: <Widget>[
                                Icon( Icons.edit ),
                                Text( tr(
                                    "btn_modif"), style: TextStyle(
                                    fontWeight: FontWeight.w800 ), )
                              ] ),
                        ),
                      ), ),
                      Container( width: 2,
                        color: Colors.grey.withOpacity( 0.4 ), ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () => _showErrorAlert(title: tr("confsup"),content: '${tr("suprime")} ${tr('annonce')}  $title ?',modan: tr("annuler")),
                          child: Padding(
                            padding: const EdgeInsets.all( 8.0 ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceAround,
                              children: <Widget>[
                                Icon( Icons.delete_forever,
                                  color: Colors.red, ),
                                Text(
                                  tr(
                                      "suprime" ),
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w800 ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

    );
  }

  void _showErrorAlert({String title, String content,String modan}) {
    Platform.isIOS?
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CupertinoActionSheet(message: Text(content),

          title: Text(title),actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(modan,style: TextStyle(color: Colors.blue), ),
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
                delite(widget.annonceid)
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
        child: Text(modan,style: TextStyle(color: Colors.blue),),
        onPressed: (){ if(modan=='MODIFIER'||modan=='تعديل')
          Navigator.of( context ).push( MaterialPageRoute(
              builder: (context) => ModifAnn(widget.annonceid)));
          else
          Navigator.pop( context );
          },
      ),
      MaterialButton(
      child: Text(tr(
          "suprime" ),style: TextStyle(color: Colors.red),),
      onPressed: () =>{ Navigator.pop( context ),
      delite(widget.annonceid)},
    )
    ]));
  }

  delite(String name) async {

    try {
      await FirebaseStorage.instance.ref().child(
          'Annonces/$name').delete();
      Firestore.instance.collection( 'annonces' ).document( name ).delete( );

    }catch (e) {
      print( "Error in suprime up: $e" );
      String exception = Auth.getExceptionText( e );
      _showErrorAlert(
        title: tr("errinc"),
        content: exception,
      );
    }
  }



}
