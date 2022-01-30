import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/Constants/Constant.dart';
import 'package:chatapp/CommonComponents/BottomBar/bootom_navigation_bar.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:chatapp/CommonComponents/CommonImage.dart';
import 'package:chatapp/Screens/homepage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilepage extends StatefulWidget {
  final String currentUserId;
  Profilepage({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => _MainScreenState(currentUserId: currentUserId);
}

class _MainScreenState extends State<Profilepage> {
  _MainScreenState({Key key, @required this.currentUserId});

  final String currentUserId;
  var Auth = FirebaseAuth.instance;

  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0);
  FirebaseUser currentUser;
  bool isProfilepageSelected = true;
  bool authenticated = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      setState(() {
// call setState to rebuild the view
        this.currentUser = user;
      });
    });
  }

  // BACK BUTTON
  back() {
    Navigator.pop(
        context,
        MaterialPageRoute(
            builder: (context) => Homepage(
                  currentUserId: currentUserId,
                )));
  }

  // CHECk FINGERPRINT

  void _checkBiometric() async {
    // check for biometric availability
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      print("error biometrics $e");
    }

    print("biometric stuff is available: $canCheckBiometrics");

    // enumerate biometric technologies
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } catch (e) {
      print("error enumerate biometrics $e");
    }

    print("following biometrics are available");
    print(availableBiometrics);
    if (availableBiometrics.isNotEmpty) {
      availableBiometrics.forEach((ab) {
        print("\ttech: $ab");
      });
    } else {
      print("no biometrics are available");
    }
    // authenticate with biometrics
    try {
      authenticated = await auth.authenticateWithBiometrics(
        localizedReason: 'please do the biometrix',
        useErrorDialogs: true,
        stickyAuth: false,
      );
    } catch (e) {
      print("error using biometric auth: $e");
    }
    setState(() {
      authenticated = authenticated;
    });
    print("authenticated: $authenticated");
  }

// GET USER EMAIL

  String _email() {
    if (currentUser != null) {
      if (currentUser.email != null) {
        return currentUser.email;
      } else {
        return "Email Id Not Found";
      }
    } else {
      return "Email Id Not Found";
    }
  }

// GET USER DISPLAYNAME

  String _displayname() {
    if (currentUser != null) {
      if (currentUser.displayName != null) {
        return currentUser.displayName;
      } else {
        return "Name Not Found";
      }
    } else {
      return "Name Not Found";
    }
  }

// GET USER MOBILE NUMBER

  String _phoneNumber() {
    if (currentUser != null) {
      if (currentUser.phoneNumber != null) {
        return currentUser.phoneNumber;
      } else {
        return "Phone Number Not Found";
      }
    } else {
      return "Phone Number Not Found";
    }
  }

// GET USER PROFILEPIC

  String _profilePic() {
    if (currentUser != null) {
      if (currentUser.photoUrl != null) {
        return currentUser.photoUrl;
      } else {
        return logo1;
      }
    } else {
      return logo1;
    }
  }

// GET USER ID

  String _uId() {
    if (currentUser != null) {
      return currentUser.uid;
    } else {
      return "no current user";
    }
  }

// BOTTOM MENU PRESSED

  void onBottomIconPressed(int index) {
    if (index == 0 || index == 1) {
      setState(() {
        isProfilepageSelected = true;
      });
    } else {
      setState(() {
        isProfilepageSelected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
// LOGIN BUTTON LAYOUT

    final loginButton = Material(
      borderRadius: BorderRadius.circular(10.0),
      color: bgcolors,
      child: MaterialButton(
        height: 10,
        padding: edgeInsets,
        onPressed: () {
          _logOut();
        },
        child: Text("Sign out",
            textAlign: TextAlign.center, style: TextStyle(color: colors, fontSize: 18.0, fontWeight: FontWeight.w400)),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            authenticated == true
                ? SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(color: colors),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ClipOval(
                              child: Image.network(
                                _profilePic(),
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Row(children: <Widget>[
                              Text(
                                'Name : ',
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                _displayname(),
                                style: TextStyle(color: bgcolors, fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ]),
                            SizedBox(
                              height: 16.0,
                            ),
                            Row(children: <Widget>[
                              Text(
                                'UserID : ',
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                _uId(),
                                style: TextStyle(color: bgcolors, fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ]),
                            SizedBox(
                              height: 16.0,
                            ),
                            Row(children: <Widget>[
                              Text(
                                'Email : ',
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                _email(),
                                style: TextStyle(color: bgcolors, fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ]),
                            SizedBox(
                              height: 16.0,
                            ),
                            Row(children: <Widget>[
                              Text(
                                'Phone : ',
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                _phoneNumber(),
                                style: TextStyle(color: bgcolors, fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ]),
                            SizedBox(
                              height: 30.0,
                            ),
                            loginButton,
                          ],
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(),
            Positioned(
                bottom: 0,
                right: 0,
                child: BottomNavigation(
                  onIconPresed: onBottomIconPressed,
                )),
          ],
        ),
      ),
    );
  }

// LOGOUT FROM FIREBASE

  void _logOut() async {
    Auth.signOut();
    Navigator.of(context).pushReplacementNamed(LOGIN_SCREEN);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('id', '');
  }
}
