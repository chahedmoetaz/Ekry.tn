import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:page_transition/page_transition.dart';

import 'package:provider/provider.dart';
import 'package:tn/onboarding/flutter_onboarding.dart';
import 'package:tn/onboarding/sk_onboarding_screen.dart';

import 'package:tn/provider/add_map_provider.dart';

import 'package:tn/provider/app_provider.dart';
import './nav_bar.dart';
Future<Null> main() async{
  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_)=>AddProvider(),),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: EasyLocalization(child: MyApp(),),
    ),
  );
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool first=false;

  final pages = [
    SkOnboardingModel(
        title: 'Simplifiez votre recherche immobilière',
        description:
        '',
        titleColor: Colors.black,
        descripColor: const Color(0xFF929794),
        imagePath: 'assets/recherche.png'),
    SkOnboardingModel(
        title: 'Consultez plusieurs annonces',
        description:
        '',
        titleColor: Colors.black,
        descripColor: const Color(0xFF929794),
        imagePath: 'assets/lister.png'),
    SkOnboardingModel(
        title: ' Découvrez votre futur quartier',
        description:
        '',
        titleColor: Colors.black,
        descripColor: const Color(0xFF929794),
        imagePath: 'assets/map.png'),
    SkOnboardingModel(
        title: 'Contactez le propriétaire en 1 clic ',
        description:
        'Pour ne pas rater le logement de vos rêves  ',
        titleColor: Colors.black,
        descripColor: const Color(0xFF929794),
        imagePath: 'assets/chat.png'),
    SkOnboardingModel(
        title: 'Mettez votre bien à louer',
        description:
        '',
        titleColor: Colors.black,
        descripColor: const Color(0xFF929794),
        imagePath: 'assets/Ajouter.png'),
  ];


  _getd()async{
    SharedPreferences prefs = await SharedPreferences.getInstance( );
    if(prefs.get('first')!=null)
      setState(() {
        first=true;
      });
  }
@override
  void initState() {
    _getd();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var data=EasyLocalizationProvider.of(context).data;


    return EasyLocalizationProvider(
      data:data,
      child: Consumer<AppProvider>(
          builder: (BuildContext context, AppProvider appProvider, Widget child) {


            return MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
             GlobalWidgetsLocalizations.delegate,//tba// del bar
                EasyLocalizationDelegate(locale: data.locale,path: 'assets/locale')
              ],
              locale: data.locale,
              supportedLocales:[Locale('fr','FR'),Locale('ar','FR'),],
              theme: appProvider.theme,
              home:first ?
              AnimatedSplashScreen(
                  duration: 2000,
                backgroundColor:Colors.teal,
                  splash: Image.asset('assets/splash.png',height: 80,width: 80,),
                  nextScreen: BottomNavBar(),
                  splashTransition: SplashTransition.rotationTransition,
                  pageTransitionType: PageTransitionType.scale,

              )

                  :SKOnboardingScreen(
                bgColor: Colors.white,
                themeColor: Colors.teal,
                pages: pages,
                skipClicked: (value) {
                 _save();
                  BottomNavBar();
                  },
                getStartedClicked: (value) {
                 _save();
                 BottomNavBar();
                },
              ),
            );
          }
      ),
    );
  }

  _save()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('first', 'ff');
    setState(() {
      first=true;
    });
  }


 
}
