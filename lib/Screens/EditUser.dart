import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';

import 'package:image_picker/image_picker.dart';
import 'package:tn/Widgets/custom_flat_button.dart';

import 'dart:io';

import 'package:tn/Widgets/custom_text_field.dart';
import 'package:tn/services/auth.dart';
import 'package:tn/services/validator.dart';
import 'package:tn/util/user.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  ProfilePage(this.firebaseUser);
  String firebaseUser;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  File _image;
  final TextEditingController _name = new TextEditingController();

  final TextEditingController _password = new TextEditingController();
  final TextEditingController _passwordconfirm = new TextEditingController();
  CustomTextField _nameField;

  CustomTextField _passwordField;
  CustomTextField _passwordcoField;
  final TextEditingController _phoneNumber = new TextEditingController();
  CustomTextField _phoneField;
  TextEditingController phoneController = TextEditingController();


  bool connect=false;

  String blurHash;


  Future<void> getdata() async {
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection('/users').where('userID', isEqualTo: user.uid).getDocuments().then((query) {
      setState(() {
        _phoneNumber.text = query.documents[0].data['phoneNumber'].toString( );
        _name.text=query.documents[0].data['firstName'].toString();
      });
    });


  }
  _connection()async{

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile||connectivityResult == ConnectivityResult.wifi) {
     setState(() {
       connect=true;getdata();
     });    } else setState(() {
       connect=false;
     });

  }

@override
  void initState() {
  _connection();

    super.initState();


  }

  @override
  Widget build(BuildContext context) {

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    _nameField = new CustomTextField(

      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _name,
      hint: tr("name"),
      validator: Validator.validateName,
    );


    _passwordField = CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: tr("cpassword"),
      validator: Validator.validatePassword,
    );
    _passwordcoField = CustomTextField(

      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _passwordconfirm,
      obscureText: true,
      hint: tr("confpass"),
      validator:Validator.validatePassword,

    );



      _phoneField= new CustomTextField(
        baseColor: Colors.grey,
        borderColor: Colors.grey[400],
        errorColor: Colors.red,
        controller: _phoneNumber,
        hint: tr("tel"),
        validator: Validator.validateNumber,
        inputType: TextInputType.number,
      );



    uploadPic(File image)async {

      String fileName = image.path;
      String imageName = fileName
          .substring(fileName.lastIndexOf("/"), fileName.lastIndexOf("."))
          .replaceAll("/", "");
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('users/$imageName');

      final StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);
      final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      final String url = (await downloadUrl.ref.getDownloadURL());
      await Auth.updateProfilePic(url).catchError((e)=>print(e));
      Navigator.pop(context);



    }
    void _pickImage() async {
      final imageSource = Platform.isIOS
          ? await showCupertinoDialog<bool>(
          context: context,
          builder: (context) =>
              CupertinoAlertDialog(
                content: Text(tr("source")),
                actions: <Widget>[
                  MaterialButton(
                    child: Text(tr("camera")),
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  MaterialButton(
                    child: Text(tr("galery")),
                    onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  )
                ],
              )
      )
          :await showDialog<ImageSource>(
          context: context,
          builder: (context) =>
              AlertDialog(elevation: 24.0,
                title: Text(tr("source")),
                actions: <Widget>[
                  FlatButton(
                    child: Text(tr("camera")),
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  FlatButton(
                    child: Text(tr("galery")),
                    onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  )
                ],
              )
      );

      if(imageSource != null) {
        // ignore: deprecated_member_use
        File image =await ImagePicker.pickImage(source: imageSource,imageQuality: 90,maxHeight: 150,maxWidth: 150);
        if(image != null) {
          setState(() => _image = image);
          print('--------------Image Path--------------------------------');
          print('Image Path ${_image.path}');
          print('Image Path $_image');
          print('Image Path ${_image.toString()}');
          print('--------------Image Path--------------------------------');
        }
      }
    }

    Future<void> updateName(String name) async {
      var userInfo=new UserUpdateInfo();
      userInfo.displayName=name;
      await FirebaseAuth.instance.currentUser().then((val){
        FirebaseAuth.instance.currentUser().then((user) {
          Firestore.instance.collection( 'users' )
              .where( 'userID', isEqualTo: user.uid )
              .getDocuments()
              .then( (doc) =>
              Firestore.instance.document( '/users/${user.uid}' )
                  .updateData( {'firstName': name} )
                  .then( (val) {
                Navigator.pop(context);
                print( 'update name' );

              } )
                  .catchError( (e) => print( e ) )
          ).catchError( (e) => print( e ) );
        }).catchError((e)=>print(e));

      }).catchError((e)=>print(e));

    }
    Future<void> updatePhone(String number) async {
print(_phoneNumber.text);
print(number);

      await Firestore.instance.collection('users').where("phoneNumber",isEqualTo: _phoneNumber.text)
          .getDocuments().then((value) async {

        if(value.documents.isNotEmpty){
          Fluttertoast.showToast( msg: tr( 'phonexx' ),
              toastLength: Toast.LENGTH_SHORT
              ,
              backgroundColor: Theme
                  .of( context )
                  .backgroundColor,
              textColor: Theme
                  .of( context )
                  .cursorColor,
              gravity: ToastGravity.BOTTOM );

          _phoneNumber.clear();

        }else{
          await FirebaseAuth.instance.currentUser().then((val){

            FirebaseAuth.instance.currentUser().then((user) {
              Firestore.instance.collection( 'users' )
                  .where( 'userID', isEqualTo: user.uid )
                  .getDocuments()
                  .then( (doc) =>
                  Firestore.instance.document( 'users/${user.uid}' )
                      .updateData( {'phoneNumber': number} )
                      .then( (val) {
                    Navigator.pop(context);
                    Fluttertoast.showToast( msg: tr( 'updatephone' ),
                        toastLength: Toast.LENGTH_SHORT
                        ,
                        backgroundColor: Theme
                            .of( context )
                            .backgroundColor,
                        textColor: Theme
                            .of( context )
                            .cursorColor,
                        gravity: ToastGravity.BOTTOM );

                    print( 'update Phone number' );


                  } )
                      .catchError( (e) => print('het((ii--$e' ) )
              ).catchError( (e) => print('hethii--$e' ) );
            }).catchError((e)=>print('het)))))ii--$e' ));

          }).catchError((e)=>print('heth:::::::--$e' ));

        }

      }).catchError((e)=>print('heth-------:::::--$e' ));

    }
    Future<void> updatePassword(String password) async {

      await FirebaseAuth.instance.currentUser().then((val){
        val.updatePassword(password);
        FirebaseAuth.instance.currentUser().then((user) {
          Firestore.instance.collection( '/users' )
              .where( 'userID', isEqualTo: user.uid )
              .getDocuments()
              .then( (doc) =>
              Firestore.instance.document( '/users/${user.uid}' )
                  .updateData( {'password': password} )
                  .then( (val) {
                Navigator.pop(context);
                print( 'update password' );

              } )
                  .catchError( (e) => print( e ) )
          ).catchError( (e) => print( e ) );
        }).catchError((e)=>print(e));

      }).catchError((e)=>print(e));

    }


    return
     Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(leading:  IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Platform.isAndroid?Icons.arrow_back:Icons.arrow_back_ios,
        ),
      ),
        elevation: 0.0,
      ),
      body:!connect?Center(child: Icon(Icons.signal_wifi_off,size: 60,)):StreamBuilder(
        stream: Auth.getUser(widget.firebaseUser),
         builder: (BuildContext context, AsyncSnapshot<User> snapshot) {

    if (!snapshot.hasData) {

    return Center(
    child: CircularProgressIndicator(
    valueColor: new AlwaysStoppedAnimation<Color>(
    Theme.of(context).accentColor,
    ),
    ),
    );}else
       return ListView(
        children: <Widget>[
          Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey,
                  child: ClipOval(
                    child: new SizedBox(
                        width: 180.0,
                        height: 180.0,
                        child: InkWell(
                          onTap:()=>_pickImage(),
                          child: (_image != null) ? Image.file(
                            _image,
                            fit: BoxFit.fill,
                          ) : (snapshot.data.profilePictureURL=="")
                              ? Image.asset( "assets/default.png" ,)
                              :
                          Image.network(
                            snapshot.data.profilePictureURL, fit: BoxFit.fill, ),
                        )
                    ),
                  ),
                ),
              ),


          Container(
            padding: EdgeInsets.symmetric( horizontal: 20 ),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _nameField,
                  _phoneField,

                  _passwordField,
                  _passwordcoField,
                  FlutterPasswordStrength(
                      radius: 16,
                      height: 10,
                      width: MediaQuery
                          .of( context )
                          .size
                          .width / 2,
                      password: _password.text,
                      strengthCallback: (strength) {
                        debugPrint( strength.toString( ) );
                      }
                  ),

                  Container(
                    padding: EdgeInsets.all( 30 ),
                    child: GestureDetector(
                      onTap: () {
                        if (!_formKey.currentState.validate( )) {
                          return;
                        }
                        _formKey.currentState.save( );
                        print( _name );

                        print( _phoneNumber );
                        print( _password );
                      },

                      child:Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0),
                        child: CustomFlatButton(
                          title: tr("btn_modif"),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          textColor: Colors.white,
                          onPressed: () {
                            print( 'clikk' );
                            if(_image!=null) {
                             uploadPic( _image );

                            }
                            // ignore: unrelated_type_equality_checks
                            if(snapshot.data.firstName!=_name.text.trim() && Validator.validateName(_name.text))
                              updateName(_name.text);
                            if(snapshot.data.phoneNumber!=_phoneNumber.text.trim() && Validator.validateNumber(_phoneNumber.text))
                              updatePhone(_phoneNumber.text);
                            if(snapshot.data.password!=_password.text.trim()&&
                                _passwordconfirm.text==_password.text&&Validator.validatePassword( _password.text )&&
                                _password.text.isNotEmpty&&_passwordconfirm.text.isNotEmpty){
                              updatePassword(_password.text);
                            }else if(_password.text.isNotEmpty&&_passwordconfirm.text.isNotEmpty)
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text(tr('errpasswork')) ));

                          },
                          splashColor: Colors.black12,
                          borderColor: Color.fromRGBO(59, 89, 152, 1.0),
                          borderWidth: 0,
                          color: Colors.teal,
                        ),
                      ),
                  ),
                  )
                ],
              ),
            ),
          ),
        ],
      );

    }
        ),
      );
  }





}

