
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tn/Widgets/custom_alert_dialog.dart';
import 'package:tn/Widgets/custom_flat_button.dart';
import 'package:tn/Widgets/custom_text_field.dart';
import 'package:tn/Widgets/emailSInPage.dart';
import 'package:tn/services/auth.dart';
import 'package:tn/services/validator.dart';
import 'package:tn/util/user.dart';


class SignIn extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => _SignIn();
}

class _SignIn extends State<SignIn> {

  final TextEditingController  _emailTextController = TextEditingController();
  final TextEditingController  _passwordTextController = TextEditingController();
  CustomTextField _emailField;
  CustomTextField _passwordField;
  bool _blackVisible = false;
  VoidCallback onBackPress;

  @override
  void initState() {
    super.initState();
    onBackPress = () {
      Navigator.of(context).pop();
    };

    _emailField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _emailTextController,
      hint: tr("mailadress"),
      inputType: TextInputType.emailAddress,
      validator: Validator.validateEmail,
    );
    _passwordField = CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _passwordTextController,
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
                          top: 70.0, bottom: 10.0, left: 20.0, right: 10.0),
                      child: Text(
                        tr("signin"),
                        softWrap: true,
                        textAlign: data.locale.languageCode=="ar"?TextAlign.right:TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          decoration: TextDecoration.none,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "OpenSans",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                           bottom: 10.0, left: 15.0, right: 15.0),
                      child: _emailField,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                           left: 15.0, right: 15.0),
                      child: _passwordField,
                    ),
                    Center(
                      child: InkWell(
                        onTap: (){
                          if(_emailTextController.text.isNotEmpty && Validator.validateEmail( _emailTextController.text ))
                          resetPassword(_emailTextController.text);
                          else PlatformAlertDialog(
                            title: tr('loginf'),
                            content: tr("invmail"),
                            defaultActionText:tr("try"),
                          ).show( context );
                          },
                        child: Text(tr('fpass'),style: TextStyle(fontSize: 15,color: Colors.grey,fontWeight: FontWeight.w700),),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 40.0),
                      child: CustomFlatButton(
                        title: tr("login"),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () {
                          _emailLogin(
                              email: _emailTextController.text,
                              password: _passwordTextController.text,
                              context: context);
                        },
                        splashColor: Colors.black12,
                        borderColor: Theme.of(context).accentColor,
                        borderWidth: 0,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        tr("ou"),
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(

                          decoration: TextDecoration.none,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                           horizontal: 40.0),
                      child: CustomFlatButton(
                        title: tr("flogin"),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () {
                          _facebookLogin(context: context);
                        },
                        splashColor: Colors.black12,
                        borderColor: Color.fromRGBO(59, 89, 152, 1.0),
                        borderWidth: 0,
                        color: Color.fromRGBO(59, 89, 152, 1.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40.0),
                      child: CustomFlatButton(
                        title: tr("glogin"),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () {
                          signInWithGoogle();
                        },
                         color: Colors.red,
                        borderColor: Colors.black,
                        splashColor: Colors.black12,
                        borderWidth: 0,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top:24,
                  left:20,
                  child: IconButton(
                    icon: Icon(Icons.clear,size: 30,),
                    onPressed: ()=>Navigator.of(context).pop(),
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
                  duration: Duration(milliseconds: 400),
                  curve: Curves.ease,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
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
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }

  void _emailLogin(
      {String email, String password, BuildContext context}) async {
    if (Validator.validateEmail(email) &&
        Validator.validatePassword(password)) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        _changeBlackVisible();
        await Auth.signIn(email, password)
            .then((uid){
              Navigator.of(context).pop();
              onBackPress();
            } );
      } catch (e) {
        print("Error in email sign in: $e");
        String exception = Auth.getExceptionText(e);
        _showErrorAlert(
          title: tr("loginf"),
          content: exception,
          onPressed: _changeBlackVisible,
        );
      }
    }
  }
  void _facebookLogin({BuildContext context}) async {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _changeBlackVisible();
      FacebookLogin facebookLogin = new FacebookLogin();
      facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
      FacebookLoginResult result = await facebookLogin.logIn(['email', 'public_profile']);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
        await  Auth.signInWithFacebok(result.accessToken.token).then((uid) {
            Auth.getCurrentFirebaseUser().then((firebaseUser) {
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
          });
          break;
        case FacebookLoginStatus.cancelledByUser:
        case FacebookLoginStatus.error:
        _changeBlackVisible();
        Auth.signOut( );
      }
    } catch (e) {
      print("Error in facebook sign in: $e");
      String exception = Auth.getExceptionText(e);
      _showErrorAlert(
        title: tr("loginf"),
        content: exception,
        onPressed: _changeBlackVisible,
      );
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

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
          await Auth.getCurrentFirebaseUser( ).then( (firebaseUser) {
            User user = new User(
              firstName: firebaseUser.displayName,
              userID: firebaseUser.uid,
              email: firebaseUser.email,phoneNumber: firebaseUser.phoneNumber??'',
              profilePictureURL: firebaseUser.photoUrl,
            );
            Auth.addUser( user );

          } );


        }
      } else {
        _changeBlackVisible();
        Auth.signOut();
        print( 'No user id' );
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


    Future<void> resetPassword(String email) async {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((v)=>PlatformAlertDialog(
        title: tr("cheackm"),
        content: "${tr("sentmail")} $email",
        defaultActionText: tr("ok"),
      ).show( context )).catchError((e){
        PlatformAlertDialog(
          defaultActionText: tr("try"),
          title: tr("probconn"),
          content: "${tr("cantl")} $email",

        ).show( context );
        _emailTextController.clear();

      });
    }

}
