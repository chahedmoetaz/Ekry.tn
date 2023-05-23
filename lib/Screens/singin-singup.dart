
import 'package:easy_localization/public.dart';
import 'package:flutter/material.dart';
import 'package:tn/Screens/signin.dart';
import 'package:tn/Screens/signup.dart';
import 'package:tn/Widgets/custom_flat_button.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: new ListView(physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            height: 60,
            child: Stack(
              children: [
                Positioned(
                  top:24,
                  left:20,
                  child: IconButton(
                    icon: Icon(Icons.clear,size: 30,),
                    onPressed: ()=>Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          Image.asset('assets/connect.png'),
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
            child: CustomFlatButton(
              title: tr("login"),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignIn()),
                );
              },
              splashColor: Colors.black12,
              borderColor: Theme.of(context).accentColor,
              borderWidth: 0,
              color: Theme.of(context).accentColor,
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
            child: CustomFlatButton(
              title: tr("signup"),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Theme.of(context).cursorColor.withOpacity(0.5),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUp()),
                );
              },
              splashColor: Colors.black12,
              borderColor: Theme.of(context).accentColor,
              borderWidth: 2,
            ),
          ),
        ],
      ),
    );
  }
}


