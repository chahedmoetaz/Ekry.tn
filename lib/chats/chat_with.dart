import 'dart:async';

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class Chat extends StatelessWidget {

  final String peerId;

  final String peerAvatar;
  final String name;

final bool change;


  Chat({Key key, @required this.peerId, @required this.peerAvatar, this.name, this.change,}) : super(key: key);


  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(backgroundColor: Theme.of(context).appBarTheme.color,leading: IconButton(onPressed: (){
       onback();
       Navigator.pop(context);
      },
        icon:Icon(
          Platform.isAndroid?Icons.arrow_back:Icons.arrow_back_ios,
        ),
      ),
elevation: Theme.of(context).appBarTheme.elevation,
        title: Text(

          name,

          style: TextStyle(color: Theme.of(context).cursorColor, fontWeight: FontWeight.bold),

        ),

        centerTitle: true,

      ),
      backgroundColor: Theme.of(context).backgroundColor,

      body: ChatScreen(

        peerId: peerId,

        peerAvatar: peerAvatar,
        change:change,
      ),

    );

  }

  void onback() async{
    await FirebaseAuth.instance.currentUser().then((value)async{
      await Firestore.instance.collection('users').document(value.uid).updateData({'chatting': null});


    });

  }

}



class ChatScreen extends StatefulWidget {

  final String peerId;

  final String peerAvatar;
  final bool change;

  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar, this.change, }) : super(key: key);



  @override

  State createState() => ChatScreenState(peerId: peerId, peerAvatar: peerAvatar,change:change);

}



class ChatScreenState extends State<ChatScreen> {
  DateTime d;

  DocumentSnapshot tt;



  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar,t, this.change});
 bool change;
  String _currentuser;

  String peerId;

  String peerAvatar;

  var listMessage;

  String groupChatId;
  File imageFile;

  bool isLoading;

  bool isShowSticker;

  String imageUrl;



  final TextEditingController textEditingController = TextEditingController();

  final ScrollController listScrollController = ScrollController();

  final FocusNode focusNode = FocusNode();



  bool exists=true;

  @override

  void initState() {

     FirebaseAuth.instance.currentUser().then((value){
       setState(() {
         _currentuser=value.uid;
         readLocal();
       });


     });

    super.initState();

    focusNode.addListener(onFocusChange);




    isLoading = false;

    isShowSticker = false;

    imageUrl = '';

  }



  void onFocusChange() {

    if (focusNode.hasFocus) {

      // Hide sticker when keyboard appear

      setState(() {

        isShowSticker = false;

      });

    }

  }



  readLocal() async {
    print(_currentuser);
    print(peerId);

    if(change==false)
        groupChatId ='$peerId-$_currentuser';

    else
      groupChatId = '$_currentuser-$peerId';


setState(() {

});
  }




  Future getImage() async {

    // ignore: deprecated_member_use
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 90,maxHeight: 200,maxWidth: 200);

    if (imageFile != null) {

      setState(() {

        isLoading = true;

      });

      uploadFile();

    }

  }






  Future uploadFile() async {

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    String name = 'Chat/$fileName';
    StorageReference reference = FirebaseStorage.instance.ref().child(name);

    StorageUploadTask uploadTask = reference.putFile(imageFile);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {

      imageUrl = downloadUrl;

      setState(() {

        isLoading = false;

        onSendMessage(imageUrl, 1);

      });

    }, onError: (err) {

      setState(() {

        isLoading = false;

      });

      Fluttertoast.showToast(msg: tr('not_image'));

    });

  }



  void onSendMessage(String content, int type) {

    // type: 0 = text, 1 = image, 2 = sticker

    if (content.trim() != '') {

      textEditingController.clear();



      var documentReference = Firestore.instance

          .collection('messages')

          .document(groupChatId)

          .collection(groupChatId)

          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.collection( 'users' )
          .document( _currentuser )
          .updateData( {'chattingWith': FieldValue.arrayUnion( [peerId] ),'chatting': peerId} );
      Firestore.instance.collection( 'users' )
          .document( peerId )
          .updateData( {'chattingWith': FieldValue.arrayUnion( [_currentuser] )} );

      Firestore.instance.runTransaction((transaction) async {

        await transaction.set(

          documentReference,

          {

            'idFrom': _currentuser,

            'idTo': peerId,

            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),

            'content': content,

            'type': type

          },

        );

      });

      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    } else {

      Fluttertoast.showToast(msg: tr('mess_vide'));

    }

  }



  Widget buildItem(int index, DocumentSnapshot document) {

    if (document['idFrom'] == _currentuser) {

      // Right (my message)

      return Row(

        children: <Widget>[

          document['type'] == 0

          // Text

              ? Container(

            child: Text(

              document['content'],

              style: TextStyle(color:  Theme.of(context).primaryColor),

            ),

            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),

            width: 200.0,

            decoration: BoxDecoration(color:Theme.of(context).accentColor, borderRadius: BorderRadius.circular(8.0)),

            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),

          )

              :

          Container(

            child: FlatButton(

              child: Material(

                child: CachedNetworkImage(

                  placeholder: (context, url) => Container(

                    child: CircularProgressIndicator(

                      valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).accentColor),

                    ),

                    width: 200.0,

                    height: 200.0,

                    padding: EdgeInsets.all(70.0),

                    decoration: BoxDecoration(

                      color:  Theme.of(context).accentColor,

                      borderRadius: BorderRadius.all(

                        Radius.circular(8.0),

                      ),

                    ),

                  ),

                  errorWidget: (context, url, error) => Material(

                    child: Icon(Icons.broken_image,size: 40,),

                    borderRadius: BorderRadius.all(

                      Radius.circular(8.0),

                    ),

                    clipBehavior: Clip.hardEdge,

                  ),

                  imageUrl: document['content'],

                  width: 200.0,

                  height: 200.0,

                  fit: BoxFit.cover,

                ),

                borderRadius: BorderRadius.all(Radius.circular(8.0)),

                clipBehavior: Clip.hardEdge,

              ),

              onPressed: () {

                Navigator.push(

                    context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));

              },

              padding: EdgeInsets.all(0),

            ),

            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),

          )

          // Sticker


        ],

        mainAxisAlignment: MainAxisAlignment.end,

      );

    } else {
d=DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']));
      // Left (peer message)

      return Container(

        child: Column(

          children: <Widget>[

            Row(

              children: <Widget>[

                isLastMessageLeft(index)

                    ? Material(

                  child: peerAvatar == ''
                      ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(

                        Radius.circular(18.0),

                      ),
                    ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset( "assets/default.png", width: 35.0,

                        height: 35.0,

                        fit: BoxFit.cover, )
                  )
                      :  CachedNetworkImage(

                    placeholder: (context, url) => Container(

                      child: CircularProgressIndicator(

                        strokeWidth: 1.0,

                        valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).accentColor),

                      ),

                      width: 35.0,

                      height: 35.0,

                      padding: EdgeInsets.all(10.0),

                    ),

                   imageUrl: peerAvatar,

                    width: 35.0,

                    height: 35.0,

                    fit: BoxFit.cover,

                  ),

                  borderRadius: BorderRadius.all(

                    Radius.circular(18.0),

                  ),

                  clipBehavior: Clip.hardEdge,

                )

                    : Container(width: 35.0),

                document['type'] == 0

                    ? Container(

                  child: Text(

                    document['content'],

                    style: TextStyle(color: Theme.of(context).cursorColor),

                  ),

                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),

                  width: 200.0,

                  decoration: BoxDecoration(color:Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(8.0)),

                  margin: EdgeInsets.only(left: 10.0),

                )

                    : Container(

                  child: FlatButton(

                    child: Material(

                      child: CachedNetworkImage(

                        placeholder: (context, url) => Container(

                          child: CircularProgressIndicator(

                            valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).cursorColor),

                          ),

                          width: 200.0,

                          height: 200.0,

                          padding: EdgeInsets.all(70.0),

                          decoration: BoxDecoration(

                            color:  Theme.of(context).primaryColor,

                            borderRadius: BorderRadius.all(

                              Radius.circular(8.0),

                            ),

                          ),

                        ),

                        errorWidget: (context, url, error) => Material(

                          child: Icon(Icons.broken_image,size: 40,),

                          borderRadius: BorderRadius.all(

                            Radius.circular(8.0),

                          ),

                          clipBehavior: Clip.hardEdge,

                        ),

                        imageUrl: document['content'],

                        width: 200.0,

                        height: 200.0,

                        fit: BoxFit.cover,

                      ),

                      borderRadius: BorderRadius.all(Radius.circular(8.0)),

                      clipBehavior: Clip.hardEdge,

                    ),

                    onPressed: () {

                      Navigator.push(context,

                          MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));

                    },

                    padding: EdgeInsets.all(0),

                  ),

                  margin: EdgeInsets.only(left: 10.0),

                )


              ],

            ),



            // Time

            isLastMessageLeft(index)

                ? Container(

              child: Text('${DateFormat('dd').format(d)},${tr(DateFormat('MMM').format(d))} ${DateFormat('kk:mm').format(d)}',

                style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.italic),

              ),

              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),

            )

                : Container()

          ],

          crossAxisAlignment: CrossAxisAlignment.start,

        ),

        margin: EdgeInsets.only(bottom: 10.0),

      );

    }

  }


  bool isLastMessageLeft(int index) {

    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] == _currentuser) || index == 0) {

      return true;

    } else {

      return false;

    }

  }


  bool isLastMessageRight(int index) {

    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] != _currentuser) || index == 0) {

      return true;

    } else {

      return false;

    }

  }



  Future<bool> onBackPress() {

    if (isShowSticker) {

      setState(() {

        isShowSticker = false;

      });

    } else {

      Firestore.instance.collection('users').document(_currentuser).updateData({'chatting': null});

      Navigator.pop(context);

    }



    return Future.value(false);

  }



  @override

  Widget build(BuildContext context) {

    return WillPopScope(

      child: Stack(

        children: <Widget>[

          Column(

            children: <Widget>[

              // List of messages

              buildListMessage(),


              // Input content

              buildInput(),

            ],

          ),



          // Loading

          buildLoading()

        ],

      ),

      onWillPop: onBackPress,

    );

  }


  Widget buildLoading() {

    return Positioned(

      child: isLoading ?Container(

        child: Center(

          child: CircularProgressIndicator(

            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),

          ),

        ),

        color: Theme.of(context).primaryColor.withOpacity(0.8),

      ): Container(),

    );

  }



  Widget buildInput() {

    return Container(

      child: Row(

        children: <Widget>[

          // Button send image

          Material(

            child: Container(

              margin: EdgeInsets.symmetric(horizontal: 1.0),

              child: IconButton(

                icon: Icon(Icons.image),

                onPressed: getImage,

                color:  Theme.of(context).accentColor,

              ),

            ),

            color: Theme.of(context).primaryColor,

          ),

          // Edit text

          Flexible(

            child: Container(

              child: TextField(

                style: TextStyle(color:  Theme.of(context).cursorColor, fontSize: 15.0),

                controller: textEditingController,

                decoration: InputDecoration.collapsed(

                  hintText: tr('tap_msg'),

                  hintStyle: TextStyle(color:  Colors.grey),

                ),

                focusNode: focusNode,

              ),

            ),

          ),



          // Button send message

          Material(

            child: Container(

              margin: EdgeInsets.symmetric(horizontal: 8.0),

              child: IconButton(

                icon: Icon(Icons.send),

                onPressed: () => onSendMessage(textEditingController.text, 0),

                color:  Theme.of(context).accentColor,

              ),

            ),

            color: Theme.of(context).primaryColor,

          ),

        ],

      ),

      width: double.infinity,

      height: 50.0,

      decoration: BoxDecoration(border: Border(top: BorderSide(color:  Theme.of(context).cursorColor, width: 0.5)), color: Theme.of(context).primaryColor),

    );

  }



  Widget buildListMessage() {

    return Flexible(

      child: groupChatId == ''

          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).accentColor)))

          : StreamBuilder(

        stream: Firestore.instance

            .collection('messages')

            .document(groupChatId)

            .collection(groupChatId)

            .orderBy('timestamp', descending: true)

            .limit(20)

            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return Center(

                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).primaryColor)));

          } else {

            listMessage = snapshot.data.documents;

            return ListView.builder(

              padding: EdgeInsets.all(10.0),

              itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),

              itemCount: snapshot.data.documents.length,

              reverse: true,

              controller: listScrollController,

            );

          }

        },

      ),

    );

  }



}





class FullPhoto extends StatelessWidget {

  final String url;



  FullPhoto({Key key, @required this.url}) : super(key: key);



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(leading:  Icon(
        Platform.isAndroid?Icons.arrow_back:Icons.arrow_back_ios,
      ),

        title: Text(

          tr('photo'),

          style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),

        ),

        centerTitle: true,

      ),

      body: FullPhotoScreen(url: url),

    );

  }

}



class FullPhotoScreen extends StatefulWidget {

  final String url;



  FullPhotoScreen({Key key, @required this.url}) : super(key: key);



  @override

  State createState() => FullPhotoScreenState(url: url);

}



class FullPhotoScreenState extends State<FullPhotoScreen> {

  final String url;



  FullPhotoScreenState({Key key, @required this.url});



  @override

  void initState() {

    super.initState();

  }



  @override

  Widget build(BuildContext context) {

    return Container(child: PhotoView(imageProvider: NetworkImage(url)));

  }

}