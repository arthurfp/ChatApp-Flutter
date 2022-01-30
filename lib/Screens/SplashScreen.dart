import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/Constants/Constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  // START TIME
  startTime() async {
    var _duration = new Duration(seconds: 3); // timedelay to display splash screen
    return new Timer(_duration, navigationPage);
  }

  _homeNavigation() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void navigationPage() async {
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      if (user == null) {
        // Cheking if user is already login or not
        Navigator.of(context).pushReplacementNamed(INTROSLIDER); // Navigate to intro slider if user id is null
      } else {
        _homeNavigation(); // navigate to homepage if user id is not null
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: new Stack(fit: StackFit.expand, children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/images/splash_icon.jpg', // replace your Splashscreen icon
                height: 160.0,
                width: 160.0,
              ),
            ],
          )
        ]));
  }
}
