import 'dart:async';

import 'package:chatapp/Constants/Constant.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Screens/IntroductionScreen.dart';
import 'package:chatapp/Screens/LoginScreen.dart';
import 'package:chatapp/Screens/MobilePhone.dart';
import 'package:chatapp/Screens/RegistrationScreen.dart';
import 'package:chatapp/Screens/ResetPassword.dart';
import 'package:chatapp/Screens/SplashScreen.dart';

Future main() async {
  runApp(new MaterialApp(
    title: 'ChatApp',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        primaryColor: Color(0xff3e474d), accentColor: Color(0xffefefef), accentColorBrightness: Brightness.dark),
    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      SPLASH_SCREEN: (BuildContext context) => new SplashScreen(),
      INTROSLIDER: (BuildContext context) => new IntroductionScreen(),
      LOGIN_SCREEN: (BuildContext context) => new LoginScreen(),
      REGISTRATION_SCREEN: (BuildContext context) => new RegistrationScreen(),
      PHONENUMBER: (BuildContext context) => new MobilePhone(),
      RESETPASSWORD: (BuildContext context) => new ResetPassword(),
    },
  ));
}
