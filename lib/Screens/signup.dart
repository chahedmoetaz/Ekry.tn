import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/public.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tn/Widgets/custom_alert_dialog.dart';
import 'package:tn/Widgets/custom_flat_button.dart';
import 'package:tn/Widgets/custom_text_field.dart';
import 'package:tn/Widgets/emailSInPage.dart';
import 'package:tn/services/auth.dart';
import 'package:tn/services/validator.dart';
import 'package:tn/util/user.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUp extends StatefulWidget {
  SignUp({this.firebaseUser});
  final FirebaseUser firebaseUser;
  @override
  State<StatefulWidget> createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>( );

  bool _autoValidate = false;
  final TextEditingController _fullname = new TextEditingController( );
  final TextEditingController _number = new TextEditingController( );
  final TextEditingController _email = new TextEditingController( );
  final TextEditingController _password = new TextEditingController( );
  CustomTextField _nameField;
  CustomTextField _phoneField;
  CustomTextField _emailField;
  CustomTextField _passwordField;
  bool _blackVisible = false;
  VoidCallback onBackPress;


Timer _timer;

  Stream<QuerySnapshot> snap;

  @override
  void initState() {

        super.initState( );

       onBackPress = () {
      Navigator.of( context ).pop( );
    };

    _nameField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _fullname,
      hint: tr("name"),
      validator: Validator.validateName,
    );
    _phoneField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _number,
      hint: tr("tel"),
      validator: Validator.validateNumber,
      inputType: TextInputType.number,
    );
    _emailField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _email,
      hint: tr("mailadress"),
      inputType: TextInputType.emailAddress,
      validator: Validator.validateEmail,
    );
    _passwordField = CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: tr("password"),
      validator: Validator.validatePassword,
    );
  }



  @override
  Widget build(BuildContext context) {
    var data=EasyLocalizationProvider.of(context).data;
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top:70.0, left: 10.0, right: 10.0 ),
                      child: Text(
                        tr("new"),
                        softWrap: true,
                        textAlign:data.locale.languageCode=="ar"?TextAlign.right:TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          decoration: TextDecoration.none,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "OpenSans",
                        ),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding:
                            EdgeInsets.only(
                                left: 15.0,
                                right: 15.0 ),
                            child: _nameField,
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only( top: 10.0,
                                left: 15.0,
                                right: 15.0 ),
                            child: _phoneField,
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only( top: 10.0,
                                left: 15.0,
                                right: 15.0 ),
                            child: _emailField,
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only( top: 10.0,
                                left: 15.0,
                                right: 15.0 ),
                            child:
                            _passwordField,

                          ),
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
                          )
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 40.0 ),
                      child: CustomFlatButton(
                        title: tr("signup"),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () {

                            _signUp(
                                  fullname: _fullname.text.trim( ),
                                  email: _email.text.trim( ),
                                  number: _number.text!=null?_number.text:"",
                                  password: _password.text.trim( ) );

                        },
                        splashColor: Colors.black12,
                        borderColor: Theme.of(context).accentColor,
                        borderWidth: 0,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: new RawMaterialButton(
                            onPressed: () {
                              signUpWithFacebook( );
                            },
                            child: Text( 'f',
                              style: TextStyle( color: Colors.white,
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold ), ),
                            shape: new CircleBorder( ),
                            elevation: 2.0,
                            fillColor: Colors.blue[900],
                            padding: const EdgeInsets.all( 8.0 ),
                          ),
                          margin: EdgeInsets.only(
                              left: 10, right: 10, bottom: 14 ),
                        ),
                        Container(
                          child: new RawMaterialButton(
                            onPressed: () {
                              signInWithGoogle( );
                            },
                            child: Image.asset( 'assets/google_logo.png',
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40, ),
                            shape: new CircleBorder( ),
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all( 22.0 ),
                          ),
                          margin: EdgeInsets.only(
                              left: 10, right: 10, bottom: 14 ),
                        ),
                      ],
                    )
                  ],
                ),
                Positioned(
                  top:24,
                  left:20,
                  child: IconButton(
                    icon: Icon(Icons.clear,size: 30,),
                    onPressed: onBackPress,
                  ),
                ),
              ],
            ),
            Offstage(
              offstage: !_blackVisible,
              child: GestureDetector(
                onTap: () {},
                child: AnimatedOpacity(
                  opacity: _blackVisible ? 1.0 : 0.0,
                  duration: Duration( milliseconds: 400 ),
                  curve: Curves.ease,
                  child: Container(
                    height: MediaQuery
                        .of( context )
                        .size
                        .height,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeBlackVisible() {
    setState( () {
      _blackVisible = !_blackVisible;
    } );
  }


  void _showErrorAlert({String title, String content, VoidCallback onPressed}) {
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
    );
  }



  Future<void> signUpWithFacebook() async{

    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _changeBlackVisible();
      FacebookLogin facebookLogin = new FacebookLogin();
      facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
      FacebookLoginResult result = await facebookLogin.logIn(['email', 'public_profile']);

      switch (result.status) {

        case FacebookLoginStatus.loggedIn:
          Auth.signInWithFacebok(result.accessToken.token).then((firebaseUser) {
              User user = new User(
                firstName: firebaseUser.displayName,
                userID: firebaseUser.uid,
                email: firebaseUser.email,
                phoneNumber: firebaseUser.phoneNumber??'',
                profilePictureURL: firebaseUser.photoUrl,
              );
              Auth.addUser(user);
              Navigator.of(context).pop();
              onBackPress();

          });
          break;
        case FacebookLoginStatus.cancelledByUser:
        case FacebookLoginStatus.error:
        _changeBlackVisible();
        Auth.signOut( );
      }
    } catch (e) {

      String exception = Auth.getExceptionText(e);
      _showErrorAlert(
        title: tr('loginf'),
        content: exception,
        onPressed: _changeBlackVisible,
      );
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn( );

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn
        .signIn( );
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(
        credential );
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken( ) != null);

    final FirebaseUser currentUser = await _auth.currentUser( );
    assert(user.uid == currentUser.uid);

  try {
    if (currentUser != null) {
      // Check is already sign up
      final QuerySnapshot result =
      await Firestore.instance.collection( 'users' ).where(
          'userID', isEqualTo: currentUser.uid ).getDocuments( );
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        await Auth.getCurrentFirebaseUser( ).then( (firebaseUser)  {
          User user = new User(
            firstName: firebaseUser.displayName,
            userID: firebaseUser.uid,
            email: firebaseUser.email ,
            profilePictureURL: firebaseUser.photoUrl,
            phoneNumber: firebaseUser.phoneNumber??''
          );
          Auth.addUser( user );

        } );
      }
    }
  }catch(e){String exception = Auth.getExceptionText( e );
  _showErrorAlert(
    title:tr("loginf"),
    content: exception,
    onPressed: _changeBlackVisible,
  );}
    Navigator.of(context).pop();
    onBackPress ();
    return 'signInWithGoogle succeeded: $user';
  }

  void signOutGoogle() async {
    await googleSignIn.signOut( );

    print( "User Sign Out" );
  }


  void _signUp({String fullname,
    String number,
    String email,
    String password,
    BuildContext context}) async {
    if (Validator.validateName( fullname ) &&
        Validator.validateEmail( email ) &&

        Validator.validatePassword( password )) {
      try {
        SystemChannels.textInput.invokeMethod( 'TextInput.hide' );
        _changeBlackVisible( );
       if(number!='')
        await Firestore.instance.collection('users').where("phoneNumber",isEqualTo: number).getDocuments().then((value) async {
          if(value.documents.isNotEmpty) {
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

            _number.clear();
            _changeBlackVisible( );
          }
          else await  _sendEmailLink( email, fullname, number, password );
        });
       else await  _sendEmailLink( email, fullname, number, password );

      } catch (e) {
        print( "Error in sign up: $e" );
        String exception = Auth.getExceptionText( e );
        _showErrorAlert(
          title: tr("signupf"),
          content: exception,
          onPressed: _changeBlackVisible,
        );
      }
    }
  }




  // ignore: missing_return
  Future<void> _sendEmailLink(email, fullname, number, password) async {
    SystemChannels.textInput.invokeMethod( 'TextInput.hide' );
    int r=0;
    FirebaseAuth _auth = FirebaseAuth.instance;

     await _auth.createUserWithEmailAndPassword(email: email, password: password).then((uid) async {
      FirebaseUser user=uid.user;

      if(user!=null){
      await user.sendEmailVerification();
        try {
          // Tell user we sent an email
          PlatformAlertDialog(
            title: tr("cheackm"),
            content: "${tr("sentmail")} $email",
            defaultActionText: tr("ok"),
          ).show( context );
          if(_auth.currentUser()!=null)
           _timer=Timer.periodic(Duration(seconds: 5), (timer) async {
              await _auth.currentUser()..reload();
              var user = await FirebaseAuth.instance.currentUser();
              if (user.isEmailVerified) {
                Auth.getCurrentFirebaseUser().then( (firebaseUser) {
                  User user = new User(
                    firstName: fullname,
                    userID: firebaseUser.uid,
                    email: email,
                    profilePictureURL: '',
                    password: password,
                    phoneNumber: number,
                  );

                     Auth.addUser( user );


                  Navigator.of( context ).pop( );
                  onBackPress ();
                } );

                setState(() {
                  _timer.cancel();
                  timer.cancel();
                });
              }
              if(r>=13) {
                CustomAlertDialog(
                  content: tr("longc"),
                  title: tr("longtime"),
                  onPressed: _changeBlackVisible,
                );
                timer.cancel();
                user.delete();uid.user.delete();
                _auth.signOut();
                _password.clear();
                _email.clear();
                _changeBlackVisible();
                _timer.cancel();
              }


            });

        } on PlatformException catch (e) {
          uid.user.delete();user.delete();_auth.signOut();
          PlatformExceptionAlertDialog(
            title: tr("cantl"),
            exception: e,
          ).show( context );
        }
      }else user.delete();
      }).catchError((e){
        String exception = tr("errmmail");
        _showErrorAlert(
          title:tr("loginf"),
          content: exception,
          onPressed: _changeBlackVisible,
        );
        _email.clear();

      });

  }


}

