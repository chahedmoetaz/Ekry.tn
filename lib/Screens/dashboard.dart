import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:tn/Recherche_pages/listFilter.dart';

import 'package:google_maps_webservice/places.dart';

import 'package:tn/Widgets/detail_annonce.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
final GlobalKey<ScaffoldState> homeScaffoldKey = new GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class _HomePageState extends State<HomePage> {
  String title;

  var collection=Firestore.instance.collection('annonces');



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: BoxDecoration(
                /*image: DecorationImage(
                    image: AssetImage('assets/background.jpg'),
                    fit: BoxFit.cover
                ),*/
              ),
              child: Container(
                decoration: BoxDecoration(
                    gradient:
                    LinearGradient(begin: Alignment.bottomRight, colors: [
                      Theme.of(context).accentColor.withOpacity(.9),
                      Theme.of(context).accentColor.withOpacity(.9),
                    ])),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      tr("home_msg"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(onTap:()=> handlePressButton(),
                      child: Container(
                        height: 40,width: MediaQuery.of(context).size.width-100,
                        decoration:BoxDecoration(borderRadius: BorderRadius.circular(16),color: Theme.of(context).primaryColor),
                        child: Row(children: <Widget>[
                          Icon(Icons.search,color:Colors.grey,),
                          Text(tr("tap_des"),style: TextStyle(color:Colors.grey,),),]),alignment: Alignment.centerLeft,padding: EdgeInsets.symmetric(horizontal: 20),
                      ),)
                    ,
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(

                    child: Text(
                      tr("home_pop"),
                      style: tr("home_pop")=="الوجهات الأكثر شعبية"?TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20):TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 200,

                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        makeItem(image: 'assets/Tunis.jpg', title:"Tunis" ),
                        makeItem(image: 'assets/nabeul.jpg', title: "Nabeul"),
                        makeItem(image: 'assets/sousse.jpg', title: "Sousse"),
                        makeItem(image: 'assets/monastir.jpg', title: "Monastir"),
                        makeItem(image: 'assets/mahdia.jpg', title: "Mahdia"),
                        makeItem(image: 'assets/sfax.jpg', title:"Sfax"),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(

                    child: Text(
                      tr("home_loc"),
                      style: tr("home_pop")=="الوجهات الأكثر شعبية"?TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20):TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: getPic(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget homeItem(Map<String, dynamic> data,) {

    return AspectRatio(
      aspectRatio: 1 / 1,
      child: InkWell(
        onTap: ()=>Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailAnnonce(annonceData:data,),
          ),
        ),
        child: Container(decoration: BoxDecoration(boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            offset: const Offset(3,4),
            blurRadius: 6,
          ),
        ],),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: Stack(
              children: <Widget>[
                Container(decoration: BoxDecoration(boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.9),
                    offset: const Offset(4,4),
                    blurRadius: 8,
                  ),
                ],
                  borderRadius: BorderRadius.circular(8),
                ),child: BlurHash(hash:data['blurhash'],image:data['images'][0],imageFit: BoxFit.cover,)),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget makeItem({image, title}) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Container(
        margin: EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image:
            DecorationImage(image: AssetImage(image), fit: BoxFit.cover)),
        child: InkWell(
          onTap: ()=> Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListFilter(title: '$title', list:[],type:[]),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.2),
                ])),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                tr(title),
                style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }


  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
  }

  Future<void> handlePressButton() async {

    // show input autocomplete with selected mode
    // then get the Prediction selected
    await PlacesAutocomplete.show(
      context: context,
      apiKey: "AIzaSyDpa8n8zgXtd20x307hhdqji_Z-z9rN-Z8",
      onError: onError,
      mode: Mode.fullscreen,
      language: "fr",
      components: [Component(Component.country, "TN")],
    );



  }

  // ignore: missing_return
  getPic() {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        // ignore: missing_return
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return new Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Theme
                      .of( context )
                      .accentColor,
                ),
              ),
            );
          } else if(snapshot.hasData||!snapshot.hasData)
            return StreamBuilder(
                stream: collection.orderBy(
                    'rating', descending: true ).snapshots(),
                builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData || snapshot.hasError)
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme
                              .of( context )
                              .accentColor,
                        ),
                      ),
                    );
                  else if (snapshot.data.documents.length == 0)
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme
                              .of( context )
                              .accentColor,
                        ),
                      ),
                    );
                  else
                    return
                      GridView.count(
                        physics: NeverScrollableScrollPhysics( ),
                        crossAxisCount: 2,
                        padding: EdgeInsets.only( right: 20 ),
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.78,
                        children: <Widget>[
                          homeItem( snapshot.data.documents[0].data, ),
                          homeItem( snapshot.data.documents[1].data ),
                          homeItem( snapshot.data.documents[2].data ),
                          homeItem( snapshot.data.documents[3].data )
                        ],

                      );
                }

            );
        }
    );

  }









}

